package com.bloodbank.util;

import org.json.JSONObject;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Minimal FCM HTTP client for sending high-priority emergency notifications.
 *
 * IMPORTANT:
 * - Replace SERVER_KEY with your Firebase project's legacy server key
 *   (or migrate this to HTTP v1 with OAuth2 for production).
 * - Restrict this key in Firebase console.
 */
public class FcmClient {

    private static final String FCM_ENDPOINT = "https://fcm.googleapis.com/fcm/send";
    private static final String SERVER_KEY = "REPLACE_WITH_YOUR_FCM_SERVER_KEY";

    public static void sendEmergencyAlertToDevices(List<String> tokens,
                                                   String title,
                                                   String body,
                                                   String alertId,
                                                   String bankId,
                                                   String bloodGroup) {
        if (tokens == null || tokens.isEmpty()) {
            return;
        }

        for (String token : tokens) {
            sendToSingleDevice(token, title, body, alertId, bankId, bloodGroup);
        }
    }

    private static void sendToSingleDevice(String token,
                                           String title,
                                           String body,
                                           String alertId,
                                           String bankId,
                                           String bloodGroup) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(FCM_ENDPOINT);
            conn = (HttpURLConnection) url.openConnection();
            conn.setUseCaches(false);
            conn.setDoInput(true);
            conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "key=" + SERVER_KEY);
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

            JSONObject payload = new JSONObject();
            payload.put("to", token);

            JSONObject notification = new JSONObject();
            notification.put("title", title);
            notification.put("body", body);
            notification.put("priority", "high");

            JSONObject data = new JSONObject();
            data.put("type", "EMERGENCY_ALERT");
            data.put("alertId", alertId);
            data.put("bankId", bankId);
            data.put("bloodGroup", bloodGroup);

            payload.put("notification", notification);
            payload.put("data", data);
            payload.put("priority", "high");

            byte[] bytes = payload.toString().getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(bytes.length);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(bytes);
                os.flush();
            }

            int status = conn.getResponseCode();
            if (status != HttpURLConnection.HTTP_OK) {
                // In production, log this in detail
                System.err.println("FCM send failed with HTTP status " + status);
            }
        } catch (Exception e) {
            // In production, log this error with alertId/bankId
            System.err.println("Error sending FCM notification: " + e.getMessage());
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }
}

