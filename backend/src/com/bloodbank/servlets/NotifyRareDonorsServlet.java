package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.util.EmailService;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "NotifyRareDonorsServlet", urlPatterns = {"/api/notify-rare"})
public class NotifyRareDonorsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;
        
        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized Access");
            return;
        }

        String message = request.getParameter("message");
        if (message == null || message.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?error=Message+cannot+be+empty");
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            QuerySnapshot donors = db.collection("users")
                    .whereEqualTo("role", "DONOR")
                    .whereEqualTo("status", "APPROVED")
                    .whereIn("blood_group", java.util.Arrays.asList("A-", "B-", "AB-", "O-"))
                    .get().get();

            List<String> bccEmails = new ArrayList<>();
            for (QueryDocumentSnapshot doc : donors.getDocuments()) {
                String email = doc.getString("email");
                if (email != null && !email.trim().isEmpty()) {
                    bccEmails.add(email);
                }
            }

            if (!bccEmails.isEmpty()) {
                EmailService.sendEmergencyBroadcastEmail(
                        bccEmails, 
                        "Rare Blood Groups (O-, A-, B-, AB-)", 
                        "LifeFlow Command Center", 
                        message
                );
                response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?success=Bulk+notification+dispatched+successfully+to+" + bccEmails.size() + "+rare+donors.");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?error=No+rare+donors+found+with+valid+emails.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminDirectory.jsp?error=System+error+during+dispatch.");
        }
    }
}
