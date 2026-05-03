package com.bloodbank.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.json.JSONObject;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.*;
import com.google.api.core.ApiFuture;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet(name = "EmergencyNotificationServlet", urlPatterns = {"/api/emergency-broadcast"})
public class EmergencyNotificationServlet extends HttpServlet {

    // 🧵 Dedicated thread pool for heavy dispatch operations
    private static final ExecutorService dispatchPool = Executors.newCachedThreadPool();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String bankIdParam = request.getParameter("bankId");
        String bloodGroup = request.getParameter("bloodGroup");
        String radiusParam = request.getParameter("radiusKm");
        String message = request.getParameter("message");

        JSONObject result = new JSONObject();

        try (PrintWriter out = response.getWriter()) {
            if (bankIdParam == null || bankIdParam.trim().isEmpty() || bloodGroup == null || bloodGroup.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("error", "bankId and bloodGroup are required");
                out.print(result.toString());
                return;
            }

            double radiusKm = radiusParam != null ? Double.parseDouble(radiusParam) : 10.0;

            // 🚀 SUBMIT TO POOL IMMEDIATELY
            dispatchPool.submit(() -> {
                try {
                    Firestore db = FirebaseConfig.getFirestore();
                    
                    // 1) Lookup bank coordinates (moved to async)
                    DocumentSnapshot bankDoc = db.collection("blood_banks").document(bankIdParam).get().get();
                    if (!bankDoc.exists() || !"APPROVED".equals(bankDoc.getString("status"))) {
                        System.err.println("❌ Async Dispatch Aborted: Invalid bank " + bankIdParam);
                        return;
                    }

                    Double bankLat = bankDoc.getDouble("latitude");
                    Double bankLng = bankDoc.getDouble("longitude");

                    // 2) Insert alert record (moved to async)
                    Map<String, Object> alertData = new HashMap<>();
                    alertData.put("bank_id", bankIdParam);
                    alertData.put("blood_group", bloodGroup);
                    alertData.put("radius_km", radiusKm);
                    alertData.put("message", message != null ? message : "Urgent need for " + bloodGroup + " blood");
                    alertData.put("created_at", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                    
                    DocumentReference alertRef = db.collection("emergency_alerts").document();
                    alertRef.set(alertData).get();
                    String alertId = alertRef.getId();

                    performAsyncDispatch(db, bankDoc, bankLat != null ? bankLat : 0, bankLng != null ? bankLng : 0, 
                                       bloodGroup, radiusKm, message, alertId, bankIdParam);
                                       
                } catch (Exception e) {
                    System.err.println("❌ Async Dispatch Pipeline Error: " + e.getMessage());
                    e.printStackTrace();
                }
            });

            // ⚡ RETURN INSTANTLY
            result.put("status", "QUEUED");
            result.put("message", "Emergency broadcast queued for processing.");
            response.setStatus(HttpServletResponse.SC_ACCEPTED);
            out.print(result.toString());

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("error", "Invalid numeric parameter");
            try { response.getWriter().print(result.toString()); } catch (IOException ignored) {}
        }
    }

    private void performAsyncDispatch(Firestore db, DocumentSnapshot bankDoc, double bankLat, double bankLng, 
                                     String bloodGroup, double radiusKm, String message, String alertId, String bankIdParam) throws Exception {
        
        System.out.println("🚀 [ASYNC] Starting optimized donor filter for alert: " + alertId);

        // 1) Find eligible donors
        QuerySnapshot usersSnapshot = db.collection("users")
                .whereEqualTo("blood_group", bloodGroup)
                .whereEqualTo("status", "APPROVED")
                .get().get();

        List<QueryDocumentSnapshot> users = usersSnapshot.getDocuments();
        if (users.isEmpty()) {
            System.out.println("ℹ️ No approved donors found for group " + bloodGroup);
            return;
        }

        // 2) BATCH FETCH Device Tokens (Solve N+1)
        List<DocumentReference> tokenRefs = new ArrayList<>();
        Map<String, QueryDocumentSnapshot> userMap = new HashMap<>();
        for (QueryDocumentSnapshot user : users) {
            tokenRefs.add(db.collection("device_tokens").document(user.getId()));
            userMap.put(user.getId(), user);
        }

        List<DocumentSnapshot> tokenDocs = db.getAll(tokenRefs.toArray(new DocumentReference[0])).get();
        
        List<String> fcmTokens = new ArrayList<>();
        List<String> donorEmails = new ArrayList<>();
        LocalDateTime threeMonthsAgo = LocalDateTime.now().minusMonths(3);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        for (DocumentSnapshot tokenDoc : tokenDocs) {
            if (!tokenDoc.exists()) continue;
            
            String userId = tokenDoc.getId();
            QueryDocumentSnapshot userDoc = userMap.get(userId);
            if (userDoc == null) continue;

            Double devLat = tokenDoc.getDouble("last_latitude");
            Double devLng = tokenDoc.getDouble("last_longitude");
            if (devLat == null || devLng == null) continue;

            // Haversine
            double dLat = Math.toRadians(devLat - bankLat);
            double dLng = Math.toRadians(devLng - bankLng);
            double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                    Math.cos(Math.toRadians(bankLat)) * Math.cos(Math.toRadians(devLat)) *
                    Math.sin(dLng / 2) * Math.sin(dLng / 2);
            double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            double distanceKm = 6371 * c;

            if (distanceKm <= radiusKm) {
                // Keep email list based on distance/group
                String donorEmail = userDoc.getString("email");
                if (donorEmail != null) donorEmails.add(donorEmail);

                // 🎯 OPTIMIZATION: Check eligibility using denormalized last_donation_date
                String lastDonationStr = userDoc.getString("last_donation_date");
                boolean canDonate = true;
                
                if (lastDonationStr != null && !lastDonationStr.isEmpty()) {
                    try {
                        LocalDateTime lastDonation = LocalDateTime.parse(lastDonationStr, formatter);
                        if (lastDonation.isAfter(threeMonthsAgo)) {
                            canDonate = false;
                        }
                    } catch (Exception ignored) {}
                }

                if (canDonate) {
                    String token = tokenDoc.getString("device_token");
                    if (token != null) fcmTokens.add(token);
                }
            }
        }

        // 3) Push notifications
        String title = "Emergency need for " + bloodGroup + " blood";
        String bodyText = message != null && !message.isEmpty() ? message : "Nearby blood bank requires " + bloodGroup + " donors urgently.";
                
        if (!fcmTokens.isEmpty()) {
            com.bloodbank.util.FcmClient.sendEmergencyAlertToDevices(fcmTokens, title, bodyText, alertId, bankIdParam, bloodGroup);
        }

        // 4) Email notifications
        String bankName = bankDoc.getString("bank_name");
        if (!donorEmails.isEmpty()) {
            com.bloodbank.util.EmailService.sendEmergencyBroadcastEmail(donorEmails, bloodGroup, bankName != null ? bankName : "Nearby Blood Bank", bodyText);
        }

        // 5) Newsletter Trigger
        com.bloodbank.util.NewsletterService.triggerPersonalizedAlert(bloodGroup, bankDoc.getString("city"), bankName != null ? bankName : "Nearby Blood Bank");

        System.out.println("✅ [ASYNC] Optimized Dispatch complete for alert " + alertId + ". Notified " + donorEmails.size() + " donors.");
    }
}

