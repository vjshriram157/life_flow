package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.util.EmailService;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ExecutionException;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required.");
            request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            ApiFuture<QuerySnapshot> futureUser = db.collection("users").whereEqualTo("email", email).get();
            List<QueryDocumentSnapshot> users = futureUser.get().getDocuments();
            
            if (!users.isEmpty()) {
                String userId = users.get(0).getId();
                
                // Generate 6-digit OTP
                String otp = String.format("%06d", new Random().nextInt(999999));
                
                // Clear existing tokens for this user
                ApiFuture<QuerySnapshot> tokensFuture = db.collection("password_resets").whereEqualTo("user_id", userId).get();
                for (QueryDocumentSnapshot doc : tokensFuture.get().getDocuments()) {
                    db.collection("password_resets").document(doc.getId()).delete().get();
                }
                
                // Insert new OTP
                Map<String, Object> tokenData = new HashMap<>();
                tokenData.put("user_id", userId);
                tokenData.put("token", otp);
                db.collection("password_resets").add(tokenData).get();
                
                // Dispatch real email
                EmailService.sendOtpEmail(email, otp);
                
                // Redirect user to the OTP verification page
                response.sendRedirect(request.getContextPath() + "/verifyOtp.jsp?email=" + email);
                return;
            } else {
                // If account does not exist, silently succeed to prevent enum, but redirect to OTP anyway
                response.sendRedirect(request.getContextPath() + "/verifyOtp.jsp?email=" + email);
                return;
            }
            
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing your request.");
            request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
        }
    }
}
