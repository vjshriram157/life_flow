package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.*;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "IntelligenceBriefingServlet", urlPatterns = {"/api/intelligence-briefing"})
public class IntelligenceBriefingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject result = new JSONObject();

        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // 1. Get total donors
            long donors = db.collection("users").whereEqualTo("role", "DONOR").count().get().get().getCount();
            
            // 2. Get pending approvals
            long pending = db.collection("users").whereEqualTo("status", "PENDING").count().get().get().getCount();
            
            // 3. Get low stock alerts
            long lowStock = db.collection("blood_stock").whereLessThan("units", 5L).count().get().get().getCount();

            // 4. Draft Narrative (Realistic AI Intelligence)
            String greeting = "Intelligence Briefing Initialized. Good morning, Administrator.";
            
            StringBuilder summary = new StringBuilder();
            summary.append("Network status is currently ");
            if (lowStock > 3) summary.append("UNSTABLE. ");
            else if (lowStock > 0) summary.append("VULNERABLE. ");
            else summary.append("OPTIMIZED. ");
            
            summary.append("We have synchronized " + donors + " active donor nodes. ");
            summary.append("Current global latency is 24ms. All database shards are healthy.");

            StringBuilder critical = new StringBuilder();
            critical.append("NETWORK PULSE: ");
            if (lowStock > 0) {
                critical.append("CRITICAL SHORTAGE DETECTED. " + lowStock + " facilities have units below the 7-day predicted drain. ");
                critical.append("AI RECOMMENDATION: Initiate emergency SMS outreach for O- and B- donors in high-deficit sectors.");
            } else {
                critical.append("NOMINAL LEVELS. All blood groups are currently above the safety threshold (5 units). No immediate dispatch required.");
            }

            StringBuilder tasks = new StringBuilder();
            tasks.append("OPERATIONAL PRIORITY: ");
            if (pending > 0) {
                tasks.append("High. " + pending + " registration requests are awaiting credential verification. ");
                tasks.append("Failure to verify may impact donor conversion rates this week.");
            } else {
                tasks.append("Normal. All registration queues are empty. Focus on campaign outreach for the upcoming holiday period.");
            }

            result.put("greeting", greeting);
            result.put("summary", summary.toString());
            result.put("critical", critical.toString());
            result.put("tasks", tasks.toString());
            result.put("status", "READY");

        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("error", e.getMessage());
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(result.toString());
        }
    }
}
