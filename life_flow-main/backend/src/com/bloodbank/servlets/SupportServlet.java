package com.bloodbank.servlets;

import com.bloodbank.util.EmailService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "SupportServlet", urlPatterns = {"/SupportServlet"})
public class SupportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String message = request.getParameter("message");

        if (name != null && email != null && message != null) {
            try {
                EmailService.sendSupportEmail(name, email, message);
                response.sendRedirect("contact.jsp?success=true");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("contact.jsp?error=true");
            }
        } else {
            response.sendRedirect("contact.jsp");
        }
    }
}
