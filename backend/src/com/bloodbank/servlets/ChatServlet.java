package com.bloodbank.servlets;

import org.json.JSONArray;
import org.json.JSONObject;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Properties;

@WebServlet(name = "ChatServlet", urlPatterns = {"/api/chat"})
public class ChatServlet extends HttpServlet {

    private String apiKey;

    @Override
    public void init() throws ServletException {
        super.init();
        loadApiKey();
    }

    private void loadApiKey() {
        Properties prop = new Properties();
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("config.properties")) {
            if (input == null) {
                System.err.println("Sorry, unable to find config.properties in classpath");
                return;
            }
            prop.load(input);
            apiKey = prop.getProperty("gemini.api.key");
        } catch (IOException ex) {
            System.err.println("Error loading config.properties: " + ex.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String fullName = (session != null) ? (String) session.getAttribute("fullName") : null;
        String role     = (session != null) ? (String) session.getAttribute("role") : null;

        String msg = request.getParameter("message");

        response.setContentType("application/json");

        JSONObject result = new JSONObject();

        try (PrintWriter out = response.getWriter()) {
            if (msg == null || msg.trim().isEmpty()) {
                result.put("reply", "I'm listening, " + (fullName != null ? fullName : "Hero") + ". How can I assist you today?");
            } else {
                String reply = generateGeminiResponse(msg, fullName, role);
                result.put("reply", reply);
            }
            out.print(result.toString());
        }
    }

    private String generateGeminiResponse(String input, String name, String role) {
        if (apiKey == null || apiKey.isEmpty()) {
            return "Intelligence Fallback: API Key not configured. Please contact the administrator.";
        }

        String identity = (name != null) ? name : "Hero";
        String userRole = (role != null) ? role.toLowerCase() : "donor";

        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpPost post = new HttpPost(url);

            // Construct System Instruction & Context
            String systemInstruction = "You are the LifeFlow AI Assistant (Neural Engine). You are a professional, helpful, and empathetic medical assistant for a blood bank platform. " +
                    "The user's name is " + identity + " and their role is " + userRole + ". " +
                    "Provide insights on donation eligibility, health advice, and platform features. " +
                    "Be concise, professional, and slightly futuristic in tone. Do NOT mention being an AI unless asked. " +
                    "If the user asks about specific donation rules, prioritize safety and platform protocols.";

            JSONObject jsonPayload = new JSONObject();
            
            // System Instruction
            JSONObject sysInstrObj = new JSONObject();
            JSONArray sysParts = new JSONArray();
            sysParts.put(new JSONObject().put("text", systemInstruction));
            sysInstrObj.put("parts", sysParts);
            jsonPayload.put("system_instruction", sysInstrObj);

            // User Content
            JSONArray contents = new JSONArray();
            JSONObject userContent = new JSONObject();
            JSONArray userParts = new JSONArray();
            userParts.put(new JSONObject().put("text", input));
            userContent.put("parts", userParts);
            contents.put(userContent);
            jsonPayload.put("contents", contents);

            StringEntity entity = new StringEntity(jsonPayload.toString(), ContentType.APPLICATION_JSON);
            post.setEntity(entity);

            try (CloseableHttpResponse apiResponse = httpClient.execute(post)) {
                String responseBody = EntityUtils.toString(apiResponse.getEntity());
                JSONObject resObj = new JSONObject(responseBody);
                
                if (resObj.has("candidates")) {
                    return resObj.getJSONArray("candidates")
                            .getJSONObject(0)
                            .getJSONObject("content")
                            .getJSONArray("parts")
                            .getJSONObject(0)
                            .getString("text");
                } else {
                    System.err.println("Gemini API Error: " + responseBody);
                    return "Intelligence Fallback: I encountered an anomaly while processing your request. Please try again.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "Intelligence Fallback: My neural links are experiencing interference. Please check your connection.";
        }
    }
}

