<%@ page import="com.bloodbank.util.*,com.bloodbank.models.*,java.util.*" %>
<%
    try {
        String blogId = "1"; // Test with first post
        BlogModel post = BlogService.getPostById(blogId);
        List<String> emails = NewsletterService.getAllSubscribers();
        
        out.println("<h3>Notify Test</h3>");
        out.println("<p>Post: " + (post != null ? post.getTitle() : "NOT FOUND") + "</p>");
        out.println("<p>Subscribers Found: " + (emails != null ? emails.size() : "NULL") + "</p>");
        
        if (post != null && emails != null && !emails.isEmpty()) {
            out.println("<p>Sending to: " + String.join(", ", emails) + "...</p>");
            out.flush();
            
            String updateMessage = "TEST BROADCAST: " + post.getTitle();
            try {
                EmailService.sendWeeklyNewsletter(emails, updateMessage);
                out.println("<h4 style='color:green;'>SUCCESS: Email Batch Dispatched!</h4>");
            } catch (Exception e) {
                out.println("<h4 style='color:red;'>FAILURE at Transport: " + e.getMessage() + "</h4>");
            }
        } else {
            out.println("<h4 style='color:orange;'>SKIPPED: Missing post or subscribers</h4>");
        }
    } catch (Exception e) {
        out.println("<h4 style='color:red;'>CRITICAL ERROR: " + e.getMessage() + "</h4>");
        e.printStackTrace();
    }
%>
