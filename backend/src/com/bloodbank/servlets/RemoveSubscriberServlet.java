package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RemoveSubscriberServlet", urlPatterns = {"/RemoveSubscriberServlet"})
public class RemoveSubscriberServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String subscriberId = request.getParameter("subscriberId");

        if (subscriberId == null || subscriberId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminSubscribers.jsp?error=Invalid Subscriber ID");
            return;
        }

        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // Delete the document from the 'subscribers' collection
            db.collection("subscribers").document(subscriberId).delete().get();

            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminSubscribers.jsp?success=Subscriber removed successfully");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/adminSubscribers.jsp?error=Failed to remove subscriber: " + e.getMessage());
        }
    }
}
