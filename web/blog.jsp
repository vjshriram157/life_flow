<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.BlogService" %>
<%@ page import="com.bloodbank.models.BlogModel" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Health Blog | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .blog-header {
            padding: 10rem 0 5rem;
            background: linear-gradient(180deg, #020617 0%, var(--bg-dark) 100%);
            text-align: center;
        }
        .accent-pill {
            background: rgba(225, 29, 72, 0.1);
            color: var(--primary-crimson);
            border-radius: var(--radius-pill);
            padding: 0.5rem 1.2rem;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/fragments/header.jspf" %>

<div class="blog-header">
    <div class="container fade-in-up">
        <div class="accent-pill mb-4 text-uppercase">
            <i class="fa-solid fa-journal-whills"></i> Health Journal
        </div>
        <h1 class="display-3 fw-bold text-white mb-4" style="font-family: 'Poppins';">Wellness & <span class="text-danger">Impact</span></h1>
        <p class="text-secondary fs-5 mx-auto" style="max-width: 650px;">Latest updates from the LifeFlow medical editorial team on donation impact and health science.</p>
    </div>
</div>

<main class="container mb-5 pb-5">
    <div class="row g-4 fade-in-up delay-100">
        <%
            List<BlogModel> posts = BlogService.getAllPosts();
            for (BlogModel post : posts) {
        %>
        <div class="col-lg-4 col-md-6">
            <div class="glass-card h-100 overflow-hidden">
                <div style="height: 220px; overflow: hidden; position: relative;">
                    <img src="<%= post.getImageUrl() %>" style="width:100%; height:100%; object-fit:cover;" alt="<%= post.getTitle() %>">
                    <div style="position: absolute; top: 1.5rem; left: 1.5rem;">
                        <span class="badge bg-danger rounded-pill px-3 py-2 text-uppercase" style="font-size: 0.7rem; letter-spacing: 1px;">
                            <%= post.getCategory() %>
                        </span>
                    </div>
                </div>
                <div class="p-4">
                    <div class="text-secondary small mb-2">
                        <i class="fa-regular fa-calendar-days me-1"></i> <%= post.getDate() %> &nbsp;&bull;&nbsp; 
                        <i class="fa-solid fa-user-pen me-1"></i> <%= post.getAuthor() %>
                    </div>
                    <h4 class="text-white fw-bold mb-3"><%= post.getTitle() %></h4>
                    <p class="text-secondary small mb-4" style="line-height: 1.6;">
                        <%= post.getPreview() %>
                    </p>
                    <a href="blog_detail.jsp?id=<%= post.getId() %>" class="btn btn-outline-light rounded-pill px-4 btn-sm fw-bold">
                        Read More <i class="fa-solid fa-arrow-right ms-2"></i>
                    </a>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</main>

<%@ include file="/WEB-INF/fragments/footer.jspf" %>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const observerOptions = { threshold: 0.1 };
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('scroll-active');
                }
            });
        }, observerOptions);

        document.querySelectorAll('.fade-in-up').forEach(el => observer.observe(el));
    });
</script>
</body>
</html>
