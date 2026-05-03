package com.bloodbank.servlets;

import org.json.JSONObject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "AIDispatchHelperServlet", urlPatterns = {"/api/ai-dispatch-helper"})
public class AIDispatchHelperServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String bloodGroup = request.getParameter("bloodGroup");
        String bankName = request.getParameter("bankName");
        String currentStockStr = request.getParameter("currentStock");
        
        int currentStock = 0;
        try {
            if (currentStockStr != null) currentStock = Integer.parseInt(currentStockStr);
        } catch (NumberFormatException e) {}

        JSONObject result = new JSONObject();

        // --- AI LOGIC SIMULATION (Gemini 2.5 Flash Proxy) ---
        int suggestedRadius = 50;
        String suggestedMessage = "";
        String rationale = "";

        boolean isRare = isRareGroup(bloodGroup);
        
        if (isRare) {
            suggestedRadius = 150; // Cast a wider net for rare groups
            suggestedMessage = "🚨 URGENT: Critical shortage of " + bloodGroup + " at " + bankName + ". Your rare donation is desperately needed to save lives. Please visit today.";
            rationale = "Rare blood type detected. Gemini recommends a high-intensity outreach within a 150km radius to ensure sufficient donor conversion.";
        } else {
            suggestedRadius = 75;
            suggestedMessage = "Emergency Alert: " + bankName + " is low on " + bloodGroup + " supplies. If you are nearby, please consider donating today. Every unit counts!";
            rationale = "Standard blood group. A 75km radius provides optimal donor density vs. travel time balance.";
        }

        // Adjust based on stock severity
        if (currentStock <= 1) {
            suggestedRadius += 50;
            rationale += " Stock level is critical (<= 1 unit). Radius expanded to maximize immediate response.";
        }

        result.put("suggestedRadius", suggestedRadius);
        result.put("suggestedMessage", suggestedMessage);
        result.put("rationale", rationale);

        try (PrintWriter out = response.getWriter()) {
            out.print(result.toString());
        }
    }

    private boolean isRareGroup(String group) {
        if (group == null) return false;
        return group.contains("-") || group.equals("AB+");
    }
}
