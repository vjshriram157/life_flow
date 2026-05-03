package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.WriteResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminUserManagementServlet", urlPatterns = {"/AdminUserManagementServlet"})
public class AdminUserManagementServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔐 Admin session check
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String userId = request.getParameter("userId");
        String role = request.getParameter("role");
        String email = request.getParameter("email");

        if (action == null || userId == null || userId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?error=Missing parameters");
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();

            if ("delete".equalsIgnoreCase(action)) {
                // Delete user from users collection
                db.collection("users").document(userId).delete().get();

                // If BLOOD BANK, perform cascading delete
                if ("BANK".equalsIgnoreCase(role) && email != null && !email.isEmpty()) {
                    ApiFuture<QuerySnapshot> futureBank = db.collection("blood_banks").whereEqualTo("email", email).get();
                    List<QueryDocumentSnapshot> bankDocs = futureBank.get().getDocuments();
                    for (QueryDocumentSnapshot bDoc : bankDocs) {
                        bDoc.getReference().delete().get();
                    }
                }

                response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?success=Profile deleted successfully");
                return;

            } else if ("edit".equalsIgnoreCase(action)) {
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String city = request.getParameter("city");
                String bloodGroup = request.getParameter("bloodGroup"); // Optional for banks

                Map<String, Object> updates = new HashMap<>();
                if (fullName != null) updates.put("full_name", fullName);
                if (phone != null) updates.put("phone", phone);
                if (city != null) updates.put("city", city);
                if (bloodGroup != null && !bloodGroup.isEmpty()) updates.put("blood_group", bloodGroup);

                // Update users collection
                db.collection("users").document(userId).update(updates).get();

                // If BLOOD BANK, mirror updates
                if ("BANK".equalsIgnoreCase(role) && email != null && !email.isEmpty()) {
                    ApiFuture<QuerySnapshot> futureBank = db.collection("blood_banks").whereEqualTo("email", email).get();
                    List<QueryDocumentSnapshot> bankDocs = futureBank.get().getDocuments();
                    
                    Map<String, Object> bankUpdates = new HashMap<>();
                    if (fullName != null) bankUpdates.put("bank_name", fullName);
                    if (phone != null) {
                        bankUpdates.put("phone", phone);
                        bankUpdates.put("contact_number", phone); // Fallbacks
                    }
                    if (city != null) bankUpdates.put("city", city);

                    for (QueryDocumentSnapshot bDoc : bankDocs) {
                        bDoc.getReference().update(bankUpdates).get();
                    }
                }

                response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?success=Profile updated successfully");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?error=" + e.getMessage());
            return;
        }

        response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp");
    }
}
