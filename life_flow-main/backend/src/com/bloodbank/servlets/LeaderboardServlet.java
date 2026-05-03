package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.Query;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "LeaderboardServlet", urlPatterns = {"/api/leaderboard"})
public class LeaderboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            Firestore db = FirebaseConfig.getFirestore();

            // Query donors with donation_count > 0
            // Note: Efficient sorting on server side
            Query query = db.collection("users")
                    .whereEqualTo("role", "DONOR")
                    .whereGreaterThan("donation_count", 0)
                    .orderBy("donation_count", Query.Direction.DESCENDING)
                    .orderBy("created_at", Query.Direction.ASCENDING) // Tie-breaker: earlier join date
                    .limit(50);

            QuerySnapshot querySnapshot = query.get().get();
            JSONArray leaderboardArr = new JSONArray();

            for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
                JSONObject donor = new JSONObject();
                String name = document.getString("full_name");
                long count = document.getLong("donation_count");
                
                donor.put("id", document.getId());
                donor.put("name", name != null ? name : "Anonymous Donor");
                donor.put("count", count);
                
                // Add badge logic based on thresholds
                if (count >= 20) {
                    donor.put("badge", "Life Saver");
                    donor.put("badgeIcon", "fa-crown");
                } else if (count >= 10) {
                    donor.put("badge", "Top Donor");
                    donor.put("badgeIcon", "fa-award");
                } else if (count >= 5) {
                    donor.put("badge", "Regular Donor");
                    donor.put("badgeIcon", "fa-star");
                }

                leaderboardArr.put(donor);
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("leaderboard", leaderboardArr);
            out.print(result.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try {
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "Error fetching leaderboard: " + e.getMessage());
                response.getWriter().print(error.toString());
            } catch (IOException ignored) {}
        }
    }
}
