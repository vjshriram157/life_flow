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
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;

/**
 * Optimized JSON analytics API for dashboards.
 * Implements simple in-memory caching to prevent Firestore read spikes.
 */
@WebServlet(name = "AnalyticsServlet", urlPatterns = {"/api/analytics"})
public class AnalyticsServlet extends HttpServlet {

    // 🕒 Cache configuration: 3-hour expiry to minimize Firebase reads
    private static final long CACHE_EXPIRY_MS = 3 * 60 * 60 * 1000;
    private static final Map<String, CacheEntry> metricsCache = new ConcurrentHashMap<>();

    private static class CacheEntry {
        Object data;
        long timestamp;
        CacheEntry(Object data) {
            this.data = data;
            this.timestamp = System.currentTimeMillis();
        }
        boolean isExpired() {
            return (System.currentTimeMillis() - timestamp) > CACHE_EXPIRY_MS;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String metric = request.getParameter("metric");
        if (metric == null || metric.isEmpty()) {
            metric = "donationsByMonth";
        }

        // Force refresh bypass if needed
        boolean forceRefresh = "true".equals(request.getParameter("refresh"));

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Check Cache (Bust cache with v2 suffix to ensure names are shown)
        String cacheKey = metric + "_v2";
        if (!forceRefresh && metricsCache.containsKey(cacheKey)) {
            CacheEntry entry = metricsCache.get(cacheKey);
            if (!entry.isExpired()) {
                System.out.println("⚡ Analytics Cache Hit: " + metric);
                try (PrintWriter out = response.getWriter()) {
                    JSONObject cachedResult = new JSONObject();
                    cachedResult.put("metric", metric);
                    cachedResult.put("data", entry.data);
                    cachedResult.put("cached", true);
                    out.print(cachedResult.toString());
                    return;
                }
            }
        }

        JSONObject result = new JSONObject();
        try (PrintWriter out = response.getWriter()) {
            Firestore db = FirebaseConfig.getFirestore();
            Object data = null;

            if ("donationsByMonth".equalsIgnoreCase(metric)) {
                data = getDonationsByMonth(db);
            } else if ("heatmapDemand".equalsIgnoreCase(metric)) {
                data = getDemandHeatmap(db);
            } else if ("operationalFlux".equalsIgnoreCase(metric)) {
                data = getOperationalFlux(db);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("error", "Unknown metric");
                out.print(result.toString());
                return;
            }

            // Update Cache
            metricsCache.put(cacheKey, new CacheEntry(data));

            result.put("metric", metric);
            result.put("data", data); // Frontend consistently uses "data"
            
            out.print(result.toString());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("error", "Database error: " + e.getMessage());
            try { response.getWriter().print(result.toString()); } catch (IOException ignored) {}
        }
    }

    private JSONArray getDonationsByMonth(Firestore db) throws InterruptedException, ExecutionException {
        // 🎯 OPTIMIZATION: Only fetch appointments from the last 12 months
        String oneYearAgo = LocalDateTime.now().minusMonths(12).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        
        QuerySnapshot apptsSnapshot = db.collection("appointments")
                // Filter "status" in memory to avoid requiring a composite index in Firestore
                .whereGreaterThanOrEqualTo("appointment_time", oneYearAgo)
                .get().get();
                
        Map<String, Integer> counts = new HashMap<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        for (QueryDocumentSnapshot doc : apptsSnapshot.getDocuments()) {
            if (!"COMPLETED".equalsIgnoreCase(doc.getString("status"))) continue; // Filter in memory
            
            String bg = doc.getString("blood_group");
            
            // Skip appointments with no valid blood group
            if (bg == null || bg.isEmpty() || "Unknown".equalsIgnoreCase(bg)) continue;
            
            String timeStr = doc.getString("appointment_time");
            if (timeStr == null || timeStr.isEmpty()) continue;
            
            try {
                LocalDateTime dateTime = LocalDateTime.parse(timeStr, formatter);
                String key = dateTime.getYear() + "-" + String.format("%02d", dateTime.getMonthValue()) + "-" + bg;
                counts.put(key, counts.getOrDefault(key, 0) + 1);
            } catch (Exception ignored) {}
        }

        JSONArray arr = new JSONArray();
        counts.forEach((key, count) -> {
            String[] parts = key.split("-");
            JSONObject row = new JSONObject();
            row.put("year", Integer.parseInt(parts[0]));
            row.put("month", Integer.parseInt(parts[1]));
            row.put("bloodGroup", parts[2]);
            row.put("count", count);
            arr.put(row);
        });
        return arr;
    }

    private JSONArray getDemandHeatmap(Firestore db) throws InterruptedException, ExecutionException {
        // Fetch approved banks only
        QuerySnapshot banksSnapshot = db.collection("blood_banks").whereEqualTo("status", "APPROVED").get().get();
        
        class BankPoint {
            String name;
            Double lat, lng;
            double shortage = 0;
            BankPoint(String name, Double lat, Double lng) { this.name = name; this.lat = lat; this.lng = lng; }
        }
        
        Map<String, BankPoint> bankCoords = new HashMap<>();
        for (QueryDocumentSnapshot doc : banksSnapshot.getDocuments()) {
            Double lat = doc.getDouble("latitude");
            Double lng = doc.getDouble("longitude");
            String name = doc.getString("bank_name");
            if (name == null || name.isEmpty()) {
                name = doc.getString("name");
            }
            if (lat != null && lng != null) {
                bankCoords.put(doc.getId(), new BankPoint(name, lat, lng));
            }
        }
        
        // Fetch stock
        QuerySnapshot stockSnapshot = db.collection("blood_stock").get().get();
        for (QueryDocumentSnapshot doc : stockSnapshot.getDocuments()) {
            String bankId = doc.getString("blood_bank_id");
            if (bankId != null && bankCoords.containsKey(bankId)) {
                Long units = doc.getLong("units");
                bankCoords.get(bankId).shortage += Math.max(0, 5 - (units != null ? units : 0));
            }
        }
        
        JSONArray arr = new JSONArray();
        for (BankPoint bp : bankCoords.values()) {
            JSONObject point = new JSONObject();
            point.put("name", bp.name);
            point.put("lat", bp.lat);
            point.put("lng", bp.lng);
            point.put("weight", Math.max(0.2, bp.shortage));
            arr.put(point);
        }
        return arr;
    }

    private JSONArray getOperationalFlux(Firestore db) throws InterruptedException, ExecutionException {
        JSONArray arr = new JSONArray();
        DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDateTime now = LocalDateTime.now();
        String sevenDaysAgo = now.minusDays(7).format(dayFormatter);

        Map<String, Integer> fluxData = new HashMap<>();
        for (int i = 0; i < 7; i++) {
            fluxData.put(now.minusDays(i).format(dayFormatter), 0);
        }

        // 🎯 OPTIMIZATION: Only fetch appointments from last 7 days
        QuerySnapshot appts = db.collection("appointments")
                .whereGreaterThanOrEqualTo("appointment_time", sevenDaysAgo)
                .get().get();
        
        for (QueryDocumentSnapshot doc : appts.getDocuments()) {
            String timeStr = doc.getString("appointment_time");
            if (timeStr != null && timeStr.length() >= 10) {
                String day = timeStr.substring(0, 10);
                if (fluxData.containsKey(day)) {
                    fluxData.put(day, fluxData.get(day) + 1);
                }
            }
        }

        // Removed user creation fetch to save Firestore reads

        fluxData.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .forEach(entry -> {
                    JSONObject dayObj = new JSONObject();
                    dayObj.put("day", entry.getKey());
                    dayObj.put("volume", entry.getValue());
                    arr.put(dayObj);
                });

        return arr;
    }
}


