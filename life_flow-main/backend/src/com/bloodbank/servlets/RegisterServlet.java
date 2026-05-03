package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.util.PasswordUtil;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String bloodGroup = request.getParameter("bloodGroup");
        String city = request.getParameter("city");

        // 🔹 Basic validation
        if (fullName == null || email == null || password == null || confirmPassword == null
                || fullName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Please fill in all required fields.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        String role = request.getParameter("role");
        if (role == null || (!"DONOR".equals(role) && !"BANK".equals(role))) {
            role = "DONOR";
        }

        String passwordHash = PasswordUtil.hashPassword(password);

        try {
            Firestore db = FirebaseConfig.getFirestore();
            if (db == null) {
                throw new IllegalStateException("Firestore is not initialized.");
            }

            // 🔒 CHECK IF EMAIL ALREADY EXISTS
            ApiFuture<QuerySnapshot> future = db.collection("users").whereEqualTo("email", email).get();
            QuerySnapshot querySnapshot = future.get();

            if (!querySnapshot.isEmpty()) {
                request.setAttribute("error", "This email is already registered. Please login.");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            // 📝 INSERT NEW USER (UNVERIFIED EMAIL)
            Map<String, Object> docData = new HashMap<>();
            docData.put("full_name", fullName);
            docData.put("email", email);
            docData.put("phone", phone);
            docData.put("password_hash", passwordHash);
            docData.put("blood_group", bloodGroup);
            docData.put("role", role);
            docData.put("status", "UNVERIFIED");
            docData.put("city", city);
            docData.put("created_at", java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            docData.put("donation_count", 0); // Initialize for leaderboard integrity

            ApiFuture<DocumentReference> addedDocRef = db.collection("users").add(docData);
            String userId = addedDocRef.get().getId();

            // Generate 6-digit OTP
            String otp = String.format("%06d", new java.util.Random().nextInt(999999));

            // Insert OTP into password_resets collection
            Map<String, Object> tokenData = new HashMap<>();
            tokenData.put("user_id", userId);
            tokenData.put("token", otp);

            db.collection("password_resets").add(tokenData).get(); // wait for execution

            // Dispatch real email
            com.bloodbank.util.EmailService.sendOtpEmail(email, otp);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to register. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // ✅ Redirect to OTP verification page
        response.sendRedirect(request.getContextPath() + "/verifyRegistrationOtp.jsp?email=" + email);
    }
}
