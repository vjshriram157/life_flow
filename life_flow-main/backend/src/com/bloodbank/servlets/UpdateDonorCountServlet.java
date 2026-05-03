package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.FieldValue;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.WriteResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

/**
 * 🛠️ DEBUG TOOL: Manually forces a donor's donation count to increase.
 * Used for verifying the Leaderboard feature without processing a full appointment.
 */
@WebServlet("/UpdateDonorCountServlet")
public class UpdateDonorCountServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String donorEmail = request.getParameter("donorEmail");
        if (donorEmail == null || donorEmail.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/home.jsp?error=MissingEmail");
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // Find the donor by email
            ApiFuture<QuerySnapshot> future = db.collection("users")
                .whereEqualTo("email", donorEmail.trim())
                .whereEqualTo("role", "DONOR")
                .get();
            
            QuerySnapshot querySnapshot = future.get();
            
            if (querySnapshot.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/dashboard/admin/home.jsp?error=DonorNotFound");
                return;
            }

            // Increment the count
            DocumentReference donorRef = querySnapshot.getDocuments().get(0).getReference();
            donorRef.update("donation_count", FieldValue.increment(1)).get();

            response.sendRedirect(request.getContextPath() + "/dashboard/admin/home.jsp?syncSuccess=true");

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/home.jsp?error=ConnectionError");
        }
    }
}
