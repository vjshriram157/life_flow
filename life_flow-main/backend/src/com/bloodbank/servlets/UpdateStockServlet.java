package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.*;
import com.google.api.core.ApiFuture;
import com.bloodbank.util.EmailService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "UpdateStockServlet", urlPatterns = {"/UpdateStockServlet"})
public class UpdateStockServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (userId == null || !"BANK".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // Resolve Bank ID from User Email
            DocumentSnapshot userDoc = db.collection("users").document(userId).get().get();
            String bankId = null;
            if (userDoc.exists()) {
                String email = userDoc.getString("email");
                ApiFuture<QuerySnapshot> bankQuery = db.collection("blood_banks").whereEqualTo("email", email).get();
                List<QueryDocumentSnapshot> bankDocs = bankQuery.get().getDocuments();
                if (!bankDocs.isEmpty()) {
                    bankId = bankDocs.get(0).getId();
                }
            }

            if (bankId == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard/bank/home.jsp?error=bank_not_found");
                return;
            }

            if ("update_inventory".equals(action)) {
                String bloodGroup = request.getParameter("bloodGroup");
                String unitsStr = request.getParameter("units");
                long units = Long.parseLong(unitsStr);

                // Update blood_stock collection
                ApiFuture<QuerySnapshot> stockQuery = db.collection("blood_stock")
                        .whereEqualTo("blood_bank_id", bankId)
                        .whereEqualTo("blood_group", bloodGroup)
                        .get();
                
                List<QueryDocumentSnapshot> stockDocs = stockQuery.get().getDocuments();
                if (!stockDocs.isEmpty()) {
                    // Update existing
                    DocumentReference stockRef = stockDocs.get(0).getReference();
                    stockRef.update("units", units).get();
                } else {
                    // Create new
                    Map<String, Object> newStock = new HashMap<>();
                    newStock.put("blood_bank_id", bankId);
                    newStock.put("blood_group", bloodGroup);
                    newStock.put("units", units);
                    db.collection("blood_stock").add(newStock).get();
                }
                
                response.sendRedirect(request.getContextPath() + "/dashboard/bank/home.jsp?success=inventory_updated");

            } else if ("manual_emergency".equals(action)) {
                String bloodGroup = request.getParameter("bloodGroup");
                String message = request.getParameter("message");
                
                Map<String, Object> alert = new HashMap<>();
                alert.put("bank_id", bankId);
                alert.put("blood_group", bloodGroup);
                alert.put("message", message);
                alert.put("status", "ACTIVE_MANUAL"); // Mark as manually pushed active alert
                alert.put("created_at", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
                alert.put("radius_km", 10.0); // Default radius

                db.collection("emergency_alerts").add(alert).get();
                
                // AUTOMATIC EMAIL TRIGGER (Option A)
                String facilityName = userDoc.getString("full_name") != null ? userDoc.getString("full_name") : "LifeFlow Certified Facility";
                
                ApiFuture<QuerySnapshot> donorQuery = db.collection("users")
                        .whereEqualTo("role", "DONOR")
                        .whereEqualTo("status", "APPROVED")
                        .whereEqualTo("blood_group", bloodGroup).get();
                
                List<String> bccEmails = new java.util.ArrayList<>();
                for (QueryDocumentSnapshot donorDoc : donorQuery.get().getDocuments()) {
                    String email = donorDoc.getString("email");
                    if (email != null && !email.trim().isEmpty()) {
                        bccEmails.add(email);
                    }
                }
                
                if (!bccEmails.isEmpty()) {
                    EmailService.sendEmergencyBroadcastEmail(bccEmails, bloodGroup, facilityName, message);
                }
                
                response.sendRedirect(request.getContextPath() + "/dashboard/bank/home.jsp?success=alert_sent_with_emails");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/bank/home.jsp?error=" + e.getMessage());
        }
    }
}
