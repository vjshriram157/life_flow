package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.util.PasswordUtil;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutionException;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String otp = request.getParameter("otp");
        String newPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (email == null || otp == null || newPassword == null || otp.trim().isEmpty() || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // Find User by email
            ApiFuture<QuerySnapshot> userFuture = db.collection("users").whereEqualTo("email", email).get();
            List<QueryDocumentSnapshot> users = userFuture.get().getDocuments();

            if (users.isEmpty()) {
                request.setAttribute("error", "Invalid or expired OTP.");
                request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
                return;
            }

            String userId = users.get(0).getId();

            // Find matching OTP
            ApiFuture<QuerySnapshot> tokenFuture = db.collection("password_resets")
                    .whereEqualTo("user_id", userId)
                    .whereEqualTo("token", otp)
                    .get();
            List<QueryDocumentSnapshot> tokens = tokenFuture.get().getDocuments();
            
            if (!tokens.isEmpty()) {
                // Update user password hash
                String passwordHash = PasswordUtil.hashPassword(newPassword);
                db.collection("users").document(userId).update("password_hash", passwordHash).get();
                
                // Delete used OTP
                db.collection("password_resets").document(tokens.get(0).getId()).delete().get();
                
                // Redirect back to login with success message
                response.sendRedirect(request.getContextPath() + "/login.jsp?resetSuccess=true");
            } else {
                request.setAttribute("error", "Invalid or expired OTP.");
                request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
            }
            
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again later.");
            request.getRequestDispatcher("/verifyOtp.jsp?email=" + email).forward(request, response);
        }
    }
}
