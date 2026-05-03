package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "RegisterDeviceServlet", urlPatterns = {"/api/register-device"})
public class RegisterDeviceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String userIdParam = request.getParameter("userId");
        String token = request.getParameter("token");
        String platform = request.getParameter("platform");
        String latParam = request.getParameter("lat");
        String lngParam = request.getParameter("lng");

        try (PrintWriter out = response.getWriter()) {
            if (userIdParam == null || token == null || platform == null ||
                    userIdParam.isEmpty() || token.isEmpty() || platform.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"userId, token, and platform are required\"}");
                return;
            }

            Double lat = null;
            Double lng = null;
            try {
                if (latParam != null && !latParam.isEmpty()) {
                    lat = Double.parseDouble(latParam);
                }
                if (lngParam != null && !lngParam.isEmpty()) {
                    lng = Double.parseDouble(lngParam);
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid lat/lng\"}");
                return;
            }

            String normalizedPlatform = platform.toUpperCase();
            if (!"ANDROID".equals(normalizedPlatform) && !"IOS".equals(normalizedPlatform)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"platform must be ANDROID or IOS\"}");
                return;
            }

            try {
                Firestore db = FirebaseConfig.getFirestore();
                
                Map<String, Object> data = new HashMap<>();
                data.put("user_id", userIdParam);
                data.put("device_token", token);
                data.put("platform", normalizedPlatform);
                if (lat != null) data.put("last_latitude", lat);
                if (lng != null) data.put("last_longitude", lng);

                // Use userId as the document ID for easy upserts
                db.collection("device_tokens").document(userIdParam).set(data, SetOptions.merge()).get();

            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Database error: " + e.getMessage() + "\"}");
                return;
            }

            out.print("{\"status\":\"OK\"}");
        }
    }
}

