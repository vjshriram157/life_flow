package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@WebServlet(name = "BloodBankLocatorServlet", urlPatterns = {"/api/locator"})
public class BloodBankLocatorServlet extends HttpServlet {
    private static final java.util.concurrent.ConcurrentHashMap<String, double[]> GEO_CACHE = new java.util.concurrent.ConcurrentHashMap<>();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String latParam = request.getParameter("lat");
        String lngParam = request.getParameter("lng");
        String radiusParam = request.getParameter("radiusKm");
        String cityParam = request.getParameter("city");
        String pincodeParam = request.getParameter("pincode");

        double lat = 0.0;
        double lng = 0.0;
        boolean coordinatesFound = false;

        // 1. Try explicit coordinates first
        if (latParam != null && lngParam != null) {
            try {
                lat = Double.parseDouble(latParam);
                lng = Double.parseDouble(lngParam);
                coordinatesFound = true;
            } catch (NumberFormatException e) {
                // Ignore, try geocoding
            }
        }

        // 2. If no coords, try geocoding city/pincode
        if (!coordinatesFound) {
            String query = null;
            if (cityParam != null && !cityParam.trim().isEmpty()) {
                query = cityParam;
                if (pincodeParam != null && !pincodeParam.trim().isEmpty()) {
                    query += ", " + pincodeParam;
                }
            } else if (pincodeParam != null && !pincodeParam.trim().isEmpty()) {
                query = pincodeParam;
            }

            if (query != null) {
                double[] geocoded = geocodedWithCache(query);
                if (geocoded != null) {
                    lat = geocoded[0];
                    lng = geocoded[1];
                    coordinatesFound = true;
                }
            }
        }

        if (!coordinatesFound) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Location not found or invalid coordinates provided.\"}");
            return;
        }

        double radiusKm = 25.0;
        try {
            if (radiusParam != null) {
                radiusKm = Double.parseDouble(radiusParam);
            }
        } catch (NumberFormatException e) {
            // Default 25
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Firestore db = FirebaseConfig.getFirestore();
            QuerySnapshot snapshot = db.collection("blood_banks")
                    .whereEqualTo("status", "APPROVED")
                    .get().get();
            
            JSONObject result = new JSONObject();
            result.put("centerLat", lat);
            result.put("centerLng", lng);
            
            // Temporary class for sorting
            class BankDistance {
                JSONObject json;
                double distance;
                BankDistance(JSONObject json, double distance) {
                    this.json = json;
                    this.distance = distance;
                }
            }
            
            List<BankDistance> validBanks = new ArrayList<>();

            for (QueryDocumentSnapshot doc : snapshot.getDocuments()) {
                Double bLat = doc.getDouble("latitude");
                Double bLng = doc.getDouble("longitude");

                if (bLat != null && bLng != null) {
                    double dist = calculateHaversineDistance(lat, lng, bLat, bLng);
                    if (dist <= radiusKm) {
                        JSONObject bank = new JSONObject();
                        // Firestore ID is a String, UI might expect integer/long but we will pass string context
                        bank.put("id", doc.getId());
                        bank.put("name", doc.getString("bank_name"));
                        bank.put("city", doc.getString("city"));
                        bank.put("latitude", bLat);
                        bank.put("longitude", bLng);
                        bank.put("distanceKm", dist);
                        
                        validBanks.add(new BankDistance(bank, dist));
                    }
                }
            }

            // Sort by distance ASC
            validBanks.sort(Comparator.comparingDouble(b -> b.distance));

            // Optional: Limit 20
            JSONArray banksArr = new JSONArray();
            int limit = Math.min(validBanks.size(), 20);
            for (int i = 0; i < limit; i++) {
                banksArr.put(validBanks.get(i).json);
            }
            
            result.put("banks", banksArr);

            PrintWriter out = response.getWriter();
            out.print(result.toString());
            out.flush();

        } catch (Exception e) {
            e.printStackTrace(); // VERY IMPORTANT
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write(
                "{\"error\": \"" + e.getMessage().replace("\"", "'") + "\"}"
            );
        }

    }

    private double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
        if ((lat1 == lat2) && (lon1 == lon2)) {
            return 0;
        }
        double theta = lon1 - lon2;
        double dist = Math.sin(Math.toRadians(lat1)) * Math.sin(Math.toRadians(lat2)) + 
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.cos(Math.toRadians(theta));
        dist = Math.acos(dist);
        dist = Math.toDegrees(dist);
        dist = dist * 60 * 1.1515;
        // Convert to Kilometers
        dist = dist * 1.609344;
        return dist;
    }

    private double[] geocodedWithCache(String query) {
        if (query == null) return null;
        String normalizedQuery = query.toLowerCase().trim();
        if (GEO_CACHE.containsKey(normalizedQuery)) {
            return GEO_CACHE.get(normalizedQuery);
        }
        double[] coords = geocodeAddress(query);
        if (coords != null) {
            GEO_CACHE.put(normalizedQuery, coords);
        }
        return coords;
    }

    private double[] geocodeAddress(String query) {
        // Use OpenStreetMap Nominatim API (Free, requires User-Agent)
        String url;
        try {
            url = "https://nominatim.openstreetmap.org/search?q=" + URLEncoder.encode(query, "UTF-8") + "&format=json&limit=1";
            try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
                HttpGet request = new HttpGet(url);
                request.setHeader("User-Agent", "LifeFlowBloodBank/1.0"); // Nominatim requires User-Agent

                try (CloseableHttpResponse response = httpClient.execute(request)) {
                    if (response.getCode() == 200) {
                        String jsonStr = EntityUtils.toString(response.getEntity());
                        JSONArray jsonArr = new JSONArray(jsonStr);
                        if (jsonArr.length() > 0) {
                            JSONObject loc = jsonArr.getJSONObject(0);
                            double lat = loc.getDouble("lat");
                            double lon = loc.getDouble("lon");
                            return new double[]{lat, lon};
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}

