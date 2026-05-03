package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;

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
import java.util.Map;

@WebServlet(name = "PeerRequestServlet", urlPatterns = {"/api/peer-request"})
public class PeerRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;
        
        if (role == null || userId == null || !"DONOR".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only authenticated donors can create peer requests.");
            return;
        }

        String action = request.getParameter("action");
        try {
            Firestore db = FirebaseConfig.getFirestore();
            if ("create".equals(action)) {
                String patientName = request.getParameter("patientName");
                String bloodGroup = request.getParameter("bloodGroup");
                String hospitalCity = request.getParameter("hospitalCity");
                String bankId = request.getParameter("bankId");
                String urgency = request.getParameter("urgency");
                String notes = request.getParameter("notes");
                
                String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

                if (patientName != null && !patientName.trim().isEmpty() && bloodGroup != null) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("donor_id", userId);
                    data.put("requester_name", patientName);
                    data.put("blood_group", bloodGroup);
                    data.put("bank_id", bankId != null ? bankId : "");
                    data.put("hospital_city", hospitalCity != null ? hospitalCity : "");
                    data.put("urgency", urgency != null ? urgency : "Normal");
                    data.put("notes", notes != null ? notes : "");
                    data.put("status", "PENDING");
                    data.put("created_at", date);
                    
                    db.collection("peer_requests").add(data).get();

                    try {
                        com.google.api.core.ApiFuture<com.google.cloud.firestore.QuerySnapshot> usersFuture = db.collection("users")
                                .whereEqualTo("role", "DONOR")
                                .whereEqualTo("status", "APPROVED")
                                .whereEqualTo("blood_group", bloodGroup).get();

                        java.util.List<com.google.cloud.firestore.QueryDocumentSnapshot> users = usersFuture.get().getDocuments();
                        java.util.List<String> emails = new java.util.ArrayList<>();
                        for (com.google.cloud.firestore.QueryDocumentSnapshot doc : users) {
                            if (!doc.getId().equals(userId)) {
                                String email = doc.getString("email");
                                if (email != null && !email.trim().isEmpty()) {
                                    emails.add(email);
                                }
                            }
                        }

                        com.bloodbank.util.EmailService.sendPeerRequestBroadcastEmail(emails, patientName, bloodGroup, hospitalCity != null ? hospitalCity : "Unspecified", urgency != null ? urgency : "Normal", notes);
                    } catch (Exception notificationEx) {
                        System.err.println("Failed to broadcast peer request notifications: " + notificationEx.getMessage());
                    }

                    response.sendRedirect(request.getContextPath() + "/dashboard/donor/home.jsp?success=Request+successfully+broadcasted!");
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard/donor/home.jsp?error=Missing+required+fields");
                }
            } else if ("complete".equals(action)) {
                String requestId = request.getParameter("requestId");
                if (requestId != null && !requestId.trim().isEmpty()) {
                    db.collection("peer_requests").document(requestId).update("status", "COMPLETED").get();
                    response.sendRedirect(request.getContextPath() + "/dashboard/donor/requestBlood.jsp?success=Request+marked+as+completed");
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard/donor/requestBlood.jsp?error=Invalid+request");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard/donor/home.jsp?error=Invalid+action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/donor/home.jsp?error=System+error");
        }
    }
}
