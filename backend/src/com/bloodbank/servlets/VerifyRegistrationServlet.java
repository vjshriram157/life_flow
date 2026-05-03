package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
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

@WebServlet("/VerifyRegistrationServlet")
public class VerifyRegistrationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String otp = request.getParameter("otp");
        
        if (email == null || otp == null || otp.trim().isEmpty()) {
            request.setAttribute("error", "OTP is required.");
            request.getRequestDispatcher("/verifyRegistrationOtp.jsp?email=" + email).forward(request, response);
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // Find User by email and UNVERIFIED
            ApiFuture<QuerySnapshot> userFuture = db.collection("users")
                    .whereEqualTo("email", email)
                    .whereEqualTo("status", "UNVERIFIED")
                    .get();
            List<QueryDocumentSnapshot> users = userFuture.get().getDocuments();

            if (users.isEmpty()) {
                request.setAttribute("error", "Invalid or expired OTP.");
                request.getRequestDispatcher("/verifyRegistrationOtp.jsp?email=" + email).forward(request, response);
                return;
            }

            String userId = users.get(0).getId();

            // Find matching OTP in password_resets
            ApiFuture<QuerySnapshot> tokenFuture = db.collection("password_resets")
                    .whereEqualTo("user_id", userId)
                    .whereEqualTo("token", otp)
                    .get();
            List<QueryDocumentSnapshot> tokens = tokenFuture.get().getDocuments();

            if (!tokens.isEmpty()) {
                // Update user status
                db.collection("users").document(userId).update("status", "PENDING").get();
                
                // Delete used OTP
                db.collection("password_resets").document(tokens.get(0).getId()).delete().get();
                
                // Redirect back to login with success message
                response.sendRedirect(request.getContextPath() + "/login.jsp?registered=1");
            } else {
                request.setAttribute("error", "Invalid or expired OTP.");
                request.getRequestDispatcher("/verifyRegistrationOtp.jsp?email=" + email).forward(request, response);
            }
            
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again later.");
            request.getRequestDispatcher("/verifyRegistrationOtp.jsp?email=" + email).forward(request, response);
        }
    }
}
