package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "AdminApprovalServlet", urlPatterns = {"/AdminApprovalServlet"})
public class AdminApprovalServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔐 Admin session check
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String action = request.getParameter("action"); // approve | reject
        String userId = request.getParameter("id");

        if (action == null || userId == null || userId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        String newStatus = "approve".equalsIgnoreCase(action) ? "APPROVED" : "REJECTED";

        try {
            Firestore db = FirebaseConfig.getFirestore();

            // 1️⃣ Update user status
            System.out.println("[DEBUG] Updating status for user: " + userId + " to " + newStatus);
            db.collection("users").document(userId).update("status", newStatus).get();

            // 2️⃣ If approved user → trigger email logic
            if ("APPROVED".equalsIgnoreCase(newStatus)) {
                DocumentSnapshot userDoc = db.collection("users").document(userId).get().get();

                if (userDoc.exists()) {
                    String role = userDoc.getString("role");
                    String email = userDoc.getString("email");
                    String fullName = userDoc.getString("full_name");
                    
                    System.out.println("[DEBUG] Approval for: " + fullName + " (" + email + ") as " + role);

                    if ("BANK".equalsIgnoreCase(role)) {
                        String city = userDoc.getString("city");
                        String phone = userDoc.getString("phone");

                        // 🌍 Auto-geocode bank city
                        double[] coords = geocodeAddress(city);

                        double latitude = coords != null ? coords[0] : 0.0;
                        double longitude = coords != null ? coords[1] : 0.0;

                        Map<String, Object> bankData = new HashMap<>();
                        bankData.put("bank_name", fullName);
                        bankData.put("email", email);
                        bankData.put("phone", phone);
                        bankData.put("city", city);
                        bankData.put("status", "APPROVED");
                        if (coords != null) {
                            bankData.put("latitude", latitude);
                            bankData.put("longitude", longitude);
                        }

                        db.collection("blood_banks").add(bankData).get();

                        // 📢 Newsletter Trigger: Notify all about Network Expansion
                        com.bloodbank.util.NewsletterService.triggerNewHospitalAlert(fullName, city);
                    }
                    
                    // 📧 Send Welcome Email (Only if not already sent) - ASYNC
                    Boolean emailSent = userDoc.getBoolean("welcome_email_sent");
                    
                    if (emailSent == null || !emailSent) {
                        if (email != null && !email.isEmpty()) {
                            final String finalEmail = email;
                            final String finalName = fullName;
                            final String finalRole = role;
                            final String finalUserId = userId;
                            
                            // Send in background thread to avoid blocking the Admin UI
                            new Thread(() -> {
                                try {
                                    System.out.println("[ASYNC] Dispatching welcome email to: " + finalEmail);
                                    com.bloodbank.util.EmailService.sendWelcomeEmail(finalEmail, finalName, finalRole);
                                    
                                    // Mark as sent in Firestore AFTER successful send
                                    Firestore dbAsync = com.bloodbank.util.FirebaseConfig.getFirestore();
                                    dbAsync.collection("users").document(finalUserId).update("welcome_email_sent", true).get();
                                    System.out.println("[ASYNC] Successfully updated welcome_email_sent for " + finalEmail);
                                } catch (Exception e) {
                                    System.err.println("[ASYNC ERROR] Failed to send welcome email: " + e.getMessage());
                                    e.printStackTrace();
                                }
                            }).start();
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminPendingApprovals.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        // 🔁 Back to approvals page
        response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminPendingApprovals.jsp?success=Approved successfully");
    }

    // 🌍 Geocode city using OpenStreetMap (Nominatim)
    private double[] geocodeAddress(String query) {
        if (query == null || query.trim().isEmpty()) return null;
        try {
            String url =
                    "https://nominatim.openstreetmap.org/search?q=" +
                    URLEncoder.encode(query, "UTF-8") +
                    "&format=json&limit=1";

            try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
                HttpGet request = new HttpGet(url);
                request.setHeader("User-Agent", "LifeFlowBloodBank/1.0");

                try (CloseableHttpResponse response = httpClient.execute(request)) {
                    if (response.getCode() == 200) {
                        String jsonStr = EntityUtils.toString(response.getEntity());
                        JSONArray arr = new JSONArray(jsonStr);
                        if (arr.length() > 0) {
                            JSONObject obj = arr.getJSONObject(0);
                            return new double[]{
                                    obj.getDouble("lat"),
                                    obj.getDouble("lon")
                            };
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
