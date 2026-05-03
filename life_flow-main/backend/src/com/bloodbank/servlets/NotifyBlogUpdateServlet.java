package com.bloodbank.servlets;

import com.bloodbank.util.BlogService;
import com.bloodbank.util.EmailService;
import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.models.BlogModel;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "NotifyBlogUpdateServlet", urlPatterns = {"/NotifyBlogUpdateServlet"})
public class NotifyBlogUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String blogId = request.getParameter("blogId");

        if (blogId == null || blogId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=Invalid Blog ID");
            return;
        }

        try {
            BlogModel post = BlogService.getPostById(blogId);
            if (post == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=Blog post not found");
                return;
            }

            // Using NewsletterService helper for consistency
            List<String> emails = com.bloodbank.util.NewsletterService.getAllSubscribers();

            if (emails == null || emails.isEmpty()) {
                System.out.println("⚠️ BLOG NOTIFY: No active subscribers found in 'subscribers' collection.");
                response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=No active subscribers found in the mailing list.");
                return;
            }

            System.out.println("🚀 BLOG NOTIFY: Sending update for '" + post.getTitle() + "' to " + emails.size() + " subscribers.");

            // Construct a cleaner notification message
            String updateMessage = "We've just published a new article: " + post.getTitle() + "\n\n" + post.getPreview();
            
            // Send notification
            EmailService.sendWeeklyNewsletter(emails, updateMessage);

            response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?success=Successfully notified " + emails.size() + " active subscribers!");
            
        } catch (Exception e) {
            System.err.println("❌ BLOG NOTIFY ERROR: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=Failed to process notifications: " + e.getMessage());
        }
    }
}
