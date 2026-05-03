package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "BlogManagementServlet", urlPatterns = {"/admin/manage-blog"})
public class BlogManagementServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;
        
        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        try {
            Firestore db = FirebaseConfig.getFirestore();
            if ("retract".equals(action)) {
                String articleId = request.getParameter("id");
                if (articleId != null && !articleId.isEmpty()) {
                    db.collection("blog_posts").document(articleId).delete().get();
                    response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?success=Article+retracted");
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=Invalid+ID");
                }
            } else if ("create".equals(action)) {
                String title = request.getParameter("title");
                String category = request.getParameter("category");
                String author = request.getParameter("author");
                String imageUrl = request.getParameter("imageUrl");
                String preview = request.getParameter("preview");
                String content = request.getParameter("content");
                
                String date = LocalDate.now().format(DateTimeFormatter.ofPattern("MMM dd, yyyy"));

                if (title != null && !title.trim().isEmpty()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("title", title);
                    data.put("category", category != null ? category : "GENERAL");
                    data.put("date", date);
                    data.put("author", author != null ? author : "LifeFlow Team");
                    data.put("preview", preview != null ? preview : "");
                    data.put("content", content != null ? content : "");
                    data.put("imageUrl", imageUrl != null ? imageUrl : "https://images.unsplash.com/photo-1536856136534-bb679c52a9aa"); // default generic tech/medical
                    
                    db.collection("blog_posts").add(data).get();
                    response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?success=Article+published");
                } else {
                    response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=Title+is+required");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=Invalid+action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/admin/blogCMS.jsp?error=System+error");
        }
    }
}
