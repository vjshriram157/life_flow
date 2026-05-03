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
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutionException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null) email = email.trim();

        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            if (db == null) {
                throw new IllegalStateException("Firestore is not initialized.");
            }

            ApiFuture<QuerySnapshot> future = db.collection("users").whereEqualTo("email", email).get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();

            if (documents.isEmpty()) {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            QueryDocumentSnapshot document = documents.get(0);

            // Document ID is used as the unique user ID in Firestore
            String userId = document.getId();
            String fullName = document.getString("full_name");
            String passwordHash = document.getString("password_hash");
            String role = document.getString("role");
            String status = document.getString("status");

            // Verify password
            if (!PasswordUtil.verifyPassword(password, passwordHash)) {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Check approval status
            if (!"APPROVED".equalsIgnoreCase(status)) {
                request.setAttribute("error", "Your account is pending approval. Please try again later.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // 🔐 Create new session (prevent session fixation)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("userId", userId);
            session.setAttribute("fullName", fullName);
            session.setAttribute("role", role);

            String ctx = request.getContextPath();

            // Redirect based on role
            if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect(ctx + "/dashboard/admin/home.jsp");
            } else if ("BANK".equalsIgnoreCase(role)) {
                response.sendRedirect(ctx + "/dashboard/bank/home.jsp");
            } else {
                response.sendRedirect(ctx + "/dashboard/donor/home.jsp");
            }

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            request.setAttribute("error", "DB Error: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
