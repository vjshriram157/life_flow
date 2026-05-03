package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.util.EmailService;
import com.google.cloud.firestore.*;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Management of Blood Drive Campaigns.
 */
@WebServlet(name = "CampaignServlet", urlPatterns = {"/api/campaigns"})
public class CampaignServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        if (role == null || (!"ADMIN".equalsIgnoreCase(role) && !"BANK".equalsIgnoreCase(role))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized access");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            createCampaign(request, response, userId);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        }
    }

    private void createCampaign(HttpServletRequest request, HttpServletResponse response, String userId) throws IOException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String date = request.getParameter("date");
        String city = request.getParameter("city");

        if (title == null || date == null || city == null || title.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required fields");
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            Map<String, Object> campaign = new HashMap<>();
            campaign.put("title", title);
            campaign.put("description", description);
            campaign.put("date", date);
            campaign.put("city", city);
            campaign.put("organizer_id", userId);
            campaign.put("created_at", LocalDateTime.now().toString());
            campaign.put("status", "ACTIVE");

            DocumentReference docRef = db.collection("campaigns").add(campaign).get();
            String campaignId = docRef.getId();

            // 📢 Newsletter Trigger: Notify all subscribers about the new camp
            com.bloodbank.util.NewsletterService.triggerNearbyCampAlert(title, date, city);

            // 📢 NOTIFY LOCAL DONORS (Via matching)
            notifyLocalDonors(db, city, title, date);

            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"campaignId\": \"" + campaignId + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void notifyLocalDonors(Firestore db, String city, String title, String date) {
        try {
            // Find donors in the same city
            QuerySnapshot donors = db.collection("users")
                    .whereEqualTo("role", "DONOR")
                    .whereEqualTo("city", city)
                    .get().get();

            List<String> emails = new ArrayList<>();
            for (DocumentSnapshot doc : donors.getDocuments()) {
                String email = doc.getString("email");
                if (email != null) emails.add(email);
            }

            if (!emails.isEmpty()) {
                String subject = "New Blood Drive: " + title;
                String body = "Hi Hero,\n\nA new blood drive has been organized in your city (" + city + ") on " + date + ".\n\nEvent: " + title + "\nDescription: " + title + "\n\nJoin us and save lives!";
                // We'll use the broadcast method of EmailService if it supports single messages or adjust
                // For simplicity, we'll blast them via BCC
                String facilityName = "Community Blood Drive in " + city;
                // Using 4-arg signature: (bccEmails, bloodGroup, facilityName, emergencyMessage)
                EmailService.sendEmergencyBroadcastEmail(emails, "Multiple Groups", facilityName, body);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
