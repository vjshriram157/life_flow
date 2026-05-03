package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/BookAppointmentServlet")
public class BookAppointmentServlet extends HttpServlet {

    // 🔹 Load blood banks for dropdown
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Firestore db = FirebaseConfig.getFirestore();
            QuerySnapshot querySnapshot = db.collection("blood_banks").whereEqualTo("status", "APPROVED").get().get();

            List<String[]> banks = new ArrayList<>();

            for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
                Object latObj = document.get("latitude");
                Object lngObj = document.get("longitude");
                String lat = latObj != null ? String.valueOf(latObj) : "0";
                String lng = lngObj != null ? String.valueOf(lngObj) : "0";

                String city = document.getString("city");
                if (city == null) city = "Unknown Location";

                banks.add(new String[]{
                        document.getId(),
                        document.getString("bank_name"),
                        lat,
                        lng,
                        city
                });
            }

            request.setAttribute("banks", banks);
            
            // Pass prefill parameters if they exist
            String prefillBankId = request.getParameter("prefillBankId");
            if (prefillBankId != null && !prefillBankId.trim().isEmpty()) {
                request.setAttribute("prefillBankId", prefillBankId.trim());
            }
            
            String requestId = request.getParameter("requestId");
            if (requestId != null && !requestId.trim().isEmpty()) {
                request.setAttribute("requestId", requestId.trim());
            }
            
            String alertId = request.getParameter("alertId");
            if (alertId != null && !alertId.trim().isEmpty()) {
                request.setAttribute("alertId", alertId.trim());
            }

            // Handle Flash Error messages
            String bookingError = (String) request.getSession().getAttribute("bookingError");
            if (bookingError != null) {
                request.setAttribute("bookingError", bookingError);
                request.getSession().removeAttribute("bookingError");
            }

            request.getRequestDispatcher("/dashboard/donor/bookAppointment.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }

    // 🔹 Insert appointment
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String donorId = (String) session.getAttribute("userId"); // Now expects a string from Firestore

        if (donorId == null || donorId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String bankId = request.getParameter("bankId");
        String appointmentTime = request.getParameter("appointmentTime");
        String alertId = request.getParameter("alertId");
        String requestId = request.getParameter("requestId");

        try {
            Firestore db = FirebaseConfig.getFirestore();

            // 🔴 CHECK STRIKE COUNT BEFORE BOOKING
            DocumentSnapshot donorDoc = db.collection("users").document(donorId).get().get();
            
            if (donorDoc.exists()) {
                Long strikesLong = donorDoc.getLong("strikes");
                int strikes = strikesLong != null ? strikesLong.intValue() : 0;

                if (strikes >= 3) {
                    session.setAttribute("bookingError", "Your account is temporarily suspended due to 3 or more missed appointments. Please contact your administrator to restore booking privileges.");
                    response.sendRedirect(request.getContextPath() + "/BookAppointmentServlet");
                    return;
                }
            }

            // 🔹 Original booking logic (unchanged conceptual flow)
            appointmentTime = appointmentTime.replace("T", " ") + ":00";

            Map<String, Object> appointmentData = new HashMap<>();
            appointmentData.put("donor_id", donorId);
            appointmentData.put("bank_id", bankId);
            appointmentData.put("appointment_time", appointmentTime);
            appointmentData.put("status", "PENDING");
            
            if (alertId != null && !alertId.trim().isEmpty()) {
                appointmentData.put("alert_id", alertId.trim());
            }
            if (requestId != null && !requestId.trim().isEmpty()) {
                appointmentData.put("peer_request_id", requestId.trim());
            }

            db.collection("appointments").add(appointmentData).get();

            response.sendRedirect(request.getContextPath() + "/dashboard/donor/home.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}