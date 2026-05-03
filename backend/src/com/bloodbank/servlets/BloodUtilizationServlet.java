package com.bloodbank.servlets;

import com.bloodbank.util.EmailService;
import com.bloodbank.util.FcmClient;
import com.bloodbank.util.FirebaseConfig;
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
import java.util.List;

/**
 * Endpoint for Blood Banks to mark individual bags as Utilized (Saved a life!)
 */
@WebServlet("/api/utilize-bag")
public class BloodUtilizationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"BANK".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String bagId = request.getParameter("bagId");
        if (bagId == null || bagId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            DocumentReference bagRef = db.collection("blood_bags").document(bagId);
            DocumentSnapshot bagDoc = bagRef.get().get();

            if (!bagDoc.exists() || !"COLLECTED".equals(bagDoc.getString("status"))) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Bag not found or already utilized");
                return;
            }

            String donorId = bagDoc.getString("donor_id");
            String bloodGroup = bagDoc.getString("blood_group");

            // 1. Update Bag Status
            bagRef.update("status", "UTILIZED", "utilized_at", LocalDateTime.now().toString()).get();

            // 2. Fetch Donor Info
            DocumentSnapshot donorDoc = db.collection("users").document(donorId).get().get();
            if (donorDoc.exists()) {
                String donorEmail = donorDoc.getString("email");
                String donorName = donorDoc.getString("full_name");

                // 📧 DUAL-CHANNEL NOTIFICATION: EMAIL
                EmailService.sendLifeSavedEmail(donorEmail, donorName, bloodGroup);

                // 📱 DUAL-CHANNEL NOTIFICATION: PUSH (FCM)
                // We'll look up device tokens for this donor
                QuerySnapshot tokens = db.collection("fcm_tokens").whereEqualTo("user_id", donorId).get().get();
                List<String> tokenList = new ArrayList<>();
                for(DocumentSnapshot tDoc : tokens.getDocuments()){
                    tokenList.add(tDoc.getString("token"));
                }

                if(!tokenList.isEmpty()){
                    FcmClient.sendEmergencyAlertToDevices(
                        tokenList,
                        "Your Blood Saved a Life!",
                        "Your " + bloodGroup + " unit was just used to help a patient. You're a hero!",
                        "UTILIZATION_" + bagId,
                        (String)session.getAttribute("userId"),
                        bloodGroup
                    );
                }
            }

            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true}");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
