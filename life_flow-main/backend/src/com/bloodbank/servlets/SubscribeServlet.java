package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.DocumentSnapshot;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

public class SubscribeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        JSONObject result = new JSONObject();

        // ── Validate email format ──
        if (email == null || email.trim().isEmpty() || !email.matches("^[\\w.+\\-]+@[\\w\\-]+\\.[a-zA-Z]{2,}$")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("error", "Please enter a valid email address.");
            response.getWriter().write(result.toString());
            return;
        }

        final String cleanEmail = email.trim().toLowerCase();

        try {
            Firestore db = FirebaseConfig.getFirestore();

            // ── Duplicate-check: query existing subscribers with same email ──
            com.google.cloud.firestore.QuerySnapshot existing = db.collection("subscribers")
                    .whereEqualTo("email", cleanEmail)
                    .get()
                    .get();

            if (!existing.isEmpty()) {
                // Email already subscribed – do not store again, do not send email
                result.put("success", false);
                result.put("duplicate", true);
                result.put("error", "You are already a subscriber.");
                response.getWriter().write(result.toString());
                return;
            }

            // ── New subscriber: persist to Firestore ──
            Map<String, Object> data = new HashMap<>();
            data.put("email", cleanEmail);
            data.put("subscribed_at", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            data.put("status", "ACTIVE");

            // 🎨 Smart Personalization: Capture user traits if logged in
            javax.servlet.http.HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                String userId = (String) session.getAttribute("userId");
                DocumentSnapshot userDoc = db.collection("users").document(userId).get().get();
                if (userDoc.exists()) {
                    String bloodGroup = userDoc.getString("blood_group");
                    String city = userDoc.getString("city");
                    if (bloodGroup != null) data.put("blood_group", bloodGroup);
                    if (city != null) data.put("city", city);
                }
            }

            db.collection("subscribers").add(data).get();

            // ── Send confirmation email (fire-and-forget on a separate thread) ──
            new Thread(() -> {
                try {
                    com.bloodbank.util.EmailService.sendNewsletterConfirmationEmail(cleanEmail);
                } catch (Exception ex) {
                    System.err.println("Newsletter confirmation email failed for " + cleanEmail + ": " + ex.getMessage());
                }
            }).start();

            result.put("success", true);
            response.getWriter().write(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("error", "Failed to register subscription due to internal error.");
            response.getWriter().write(result.toString());
        }
    }
}
