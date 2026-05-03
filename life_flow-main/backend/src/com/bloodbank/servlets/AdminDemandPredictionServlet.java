package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "AdminDemandPredictionServlet", urlPatterns = {"/api/demand-prediction"})
public class AdminDemandPredictionServlet extends HttpServlet {

    private static final int WINDOW_DAYS = 30;
    private static final int HORIZON_DAYS = 7;
    
    // 🕒 Cache configuration: 5-minute expiry
    private static final long CACHE_EXPIRY_MS = 5 * 60 * 1000;
    private static final Map<String, JSONObject> predictionCache = new java.util.concurrent.ConcurrentHashMap<>();
    private static long lastCacheTime = 0;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Check Cache
        if (System.currentTimeMillis() - lastCacheTime < CACHE_EXPIRY_MS && predictionCache.containsKey("latest")) {
            try (PrintWriter out = response.getWriter()) {
                out.print(predictionCache.get("latest").toString());
                return;
            } catch (Exception ignored) {}
        }

        JSONObject result = new JSONObject();
        result.put("horizonDays", HORIZON_DAYS);

        try (PrintWriter out = response.getWriter()) {
            Firestore db = FirebaseConfig.getFirestore();

            LocalDateTime windowStart = LocalDateTime.now().minusDays(WINDOW_DAYS);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            String windowStartStr = windowStart.format(formatter);

            // 🎯 OPTIMIZATION: Get completed appointments only from the last 30 days
            QuerySnapshot apptsSnapshot = db.collection("appointments")
                    // Filter "status" in memory to avoid requiring a composite index in Firestore
                    .whereGreaterThanOrEqualTo("appointment_time", windowStartStr)
                    .get().get();

            // 🎯 OPTIMIZATION: Only get blood banks to avoid huge user fetch
            QuerySnapshot bankSnapshot = db.collection("blood_banks").get().get();
            Map<String, String> bankNameMap = new HashMap<>();
            for (QueryDocumentSnapshot doc : bankSnapshot.getDocuments()) {
                bankNameMap.put(doc.getId(), doc.getString("bank_name"));
            }


            // Aggregation map: bankId|bloodGroup -> recentCount
            Map<String, Integer> aggregation = new HashMap<>();

            for (QueryDocumentSnapshot doc : apptsSnapshot.getDocuments()) {
                if (!"COMPLETED".equalsIgnoreCase(doc.getString("status"))) continue; // Filter in memory
                
                String bId = doc.getString("bank_id");
                
                String bGroup = doc.getString("blood_group");
                // Skip if no group
                if (bGroup == null || bGroup.isEmpty() || "Unknown".equalsIgnoreCase(bGroup)) continue;

                String timeStr = doc.getString("appointment_time");
                if (timeStr == null || timeStr.isEmpty()) continue;

                try {
                    LocalDateTime apptTime = LocalDateTime.parse(timeStr, formatter);
                    if (apptTime.isAfter(windowStart)) {
                        String key = bId + "|" + bGroup;
                        aggregation.put(key, aggregation.getOrDefault(key, 0) + 1);
                    }
                } catch (Exception ignored) {}
            }

            // Fetch current stock mapped by bankId|bloodGroup
            QuerySnapshot stockSnapshot = db.collection("blood_stock").get().get();
            Map<String, Long> stockMap = new HashMap<>();
            for (QueryDocumentSnapshot doc : stockSnapshot.getDocuments()) {
                String sBankId = doc.getString("blood_bank_id");
                String sGroup = doc.getString("blood_group");
                Long units = doc.getLong("units");
                if (units == null) units = 0L;
                stockMap.put(sBankId + "|" + sGroup, units);
            }

            JSONArray arr = new JSONArray();

            for (Map.Entry<String, Integer> entry : aggregation.entrySet()) {
                String[] parts = entry.getKey().split("\\|");
                String bId = parts[0];
                String bGroup = parts[1];
                int recentCount = entry.getValue();

                double dailyAvg = (double) recentCount / WINDOW_DAYS;
                int forecastUnits = (int) Math.round(dailyAvg * HORIZON_DAYS);
                long currentStock = stockMap.getOrDefault(bId + "|" + bGroup, 0L);

                // Skip entries whose bank_id has no matching blood bank in Firestore
                if (!bankNameMap.containsKey(bId)) continue;

                JSONObject row = new JSONObject();
                row.put("bankId", bId);
                row.put("bankName", bankNameMap.get(bId));
                row.put("bloodGroup", bGroup);
                row.put("dailyAvg", dailyAvg);
                row.put("forecastUnits", forecastUnits);
                row.put("currentStock", currentStock);
                arr.put(row);
            }

            result.put("predictions", arr);
            
            // Update Cache
            predictionCache.put("latest", result);
            lastCacheTime = System.currentTimeMillis();
            
            out.print(result.toString());

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("error", "Database error: " + e.getMessage());
            try {
                response.getWriter().print(result.toString());
            } catch (IOException ignored) {}
        }
    }
}

