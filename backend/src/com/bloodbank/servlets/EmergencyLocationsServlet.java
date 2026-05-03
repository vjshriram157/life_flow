package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.*;
import com.google.api.core.ApiFuture;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "EmergencyLocationsServlet", urlPatterns = {"/api/emergency-locations"})
public class EmergencyLocationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        JSONArray locations = new JSONArray();

        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // 1. Fetch critical stock alerts (< 5 units)
            ApiFuture<QuerySnapshot> stockFuture = db.collection("blood_stock").whereLessThan("units", 5L).get();
            List<QueryDocumentSnapshot> lowStockDocs = stockFuture.get().getDocuments();

            for (QueryDocumentSnapshot sDoc : lowStockDocs) {
                String bankId = sDoc.getString("blood_bank_id");
                if (bankId == null) continue;

                DocumentSnapshot bankDoc = db.collection("blood_banks").document(bankId).get().get();
                if (bankDoc.exists()) {
                    JSONObject obj = new JSONObject();
                    obj.put("type", "CRITICAL_STOCK");
                    obj.put("bankName", bankDoc.getString("bank_name"));
                    obj.put("bloodGroup", sDoc.getString("blood_group"));
                    obj.put("city", bankDoc.getString("city"));
                    
                    Double lat = bankDoc.getDouble("latitude");
                    Double lng = bankDoc.getDouble("longitude");
                    if (lat != null && lng != null) {
                        obj.put("lat", lat);
                        obj.put("lng", lng);
                        locations.put(obj);
                    }
                }
            }

            // 2. Fetch manual active emergencies
            ApiFuture<QuerySnapshot> manualAlertsFuture = db.collection("emergency_alerts").whereEqualTo("status", "ACTIVE_MANUAL").get();
            List<QueryDocumentSnapshot> manualAlertDocs = manualAlertsFuture.get().getDocuments();

            for (QueryDocumentSnapshot aDoc : manualAlertDocs) {
                String bankId = aDoc.getString("bank_id");
                if (bankId == null) continue;

                DocumentSnapshot bankDoc = db.collection("blood_banks").document(bankId).get().get();
                if (bankDoc.exists()) {
                    JSONObject obj = new JSONObject();
                    obj.put("type", "MANUAL_EMERGENCY");
                    obj.put("bankName", bankDoc.getString("bank_name"));
                    obj.put("bloodGroup", aDoc.getString("blood_group"));
                    obj.put("message", aDoc.getString("message"));
                    Double lat = bankDoc.getDouble("latitude");
                    Double lng = bankDoc.getDouble("longitude");
                    if (lat != null && lng != null) {
                        obj.put("lat", lat);
                        obj.put("lng", lng);
                        locations.put(obj);
                    }
                }
            }

            try (PrintWriter out = response.getWriter()) {
                out.print(locations.toString());
            }

        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
