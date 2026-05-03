<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.EmailService" %>
<%
    String testEmail = request.getParameter("email");
    String status = "";
    if (testEmail != null && !testEmail.isEmpty()) {
        try {
            EmailService.sendWelcomeEmail(testEmail, "Test User", "DONOR");
            status = "✅ Test email sent to " + testEmail + ". Please check your Inbox and Spam folder.";
        } catch (Exception e) {
            status = "❌ Error: " + e.getMessage();
        }
    }
%>
<html>
<head><title>Email Service Test</title></head>
<body style="font-family: sans-serif; padding: 50px; background: #f8fafc;">
    <h2>LifeFlow Email Service Diagnostic</h2>
    <form>
        <input type="email" name="email" placeholder="Enter your email" required style="padding: 10px; width: 300px;">
        <button type="submit" style="padding: 10px 20px; background: #e11d48; color: white; border: none; border-radius: 5px; cursor: pointer;">Send Test Welcome Email</button>
    </form>
    <p><%= status %></p>
    <hr>
    <p>If this page says "✅ Sent" but you receive nothing, the issue is likely with the Gmail App Password or SMTP settings in <code>config.properties</code>.</p>
</body>
</html>
