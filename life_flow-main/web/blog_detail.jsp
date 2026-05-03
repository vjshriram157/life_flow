<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.BlogService" %>
<%@ page import="com.bloodbank.models.BlogModel" %>
<%
    String id = request.getParameter("id");
    BlogModel post = BlogService.getPostById(id);
    if (post == null) {
        response.sendRedirect("blog.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= post.getTitle() %> | LifeFlow Blog</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .article-hero {
            padding: 8rem 0 4rem;
            background: var(--bg-dark);
            position: relative;
        }
        .article-banner {
            width: 100%;
            height: 500px;
            object-fit: cover;
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-premium);
            margin-bottom: -150px;
            position: relative;
            z-index: 2;
        }
        .content-container {
            max-width: 800px;
            margin: 180px auto 100px;
            padding: 0 1.5rem;
            position: relative;
        }
        .sticky-social {
            position: fixed;
            left: 5%;
            top: 50%;
            transform: translateY(-50%);
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            z-index: 10;
        }
        @media (max-width: 1200px) {
            .sticky-social { display: none; }
        }
        .social-link {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            border: var(--border-glass);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-secondary);
            background: rgba(255, 255, 255, 0.05);
            transition: var(--transition-premium);
            text-decoration: none;
        }
        .social-link:hover {
            background: var(--primary-crimson);
            color: white;
            transform: scale(1.1);
        }
        .category-pill {
            background: rgba(225, 29, 72, 0.15);
            color: var(--primary-crimson);
            padding: 0.6rem 1.5rem;
            border-radius: var(--radius-pill);
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
        }
        .author-card {
            display: flex;
            align-items: center;
            gap: 1.25rem;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
        }
        .author-avatar {
            width: 55px;
            height: 55px;
            background: var(--surface-dark);
            border: 1px solid var(--primary-crimson);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: white;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/fragments/header.jspf" %>

<div class="sticky-social">
    <a href="#" class="social-link"><i class="fa-brands fa-facebook-f"></i></a>
    <a href="#" class="social-link"><i class="fa-brands fa-twitter"></i></a>
    <a href="#" class="social-link"><i class="fa-brands fa-linkedin-in"></i></a>
    <a href="#" class="social-link"><i class="fa-solid fa-link"></i></a>
</div>

<div class="article-hero text-center">
    <div class="container fade-in-up">
        <span class="category-pill mb-4 d-inline-block"><%= post.getCategory() %></span>
        <h1 class="display-3 fw-bold text-white mb-4" style="font-family: 'Poppins';"><%= post.getTitle() %></h1>
        
        <div class="d-flex align-items-center justify-content-center gap-4 text-secondary mb-5">
            <span><i class="fa-regular fa-calendar-days me-2"></i> <%= post.getDate() %></span>
            <span><i class="fa-solid fa-clock me-2"></i> <fmt:message key="nav.min_read" /></span>
        </div>

        <img src="<%= post.getImageUrl() %>" alt="Article Banner" class="article-banner">
    </div>
</div>

<main class="content-container fade-in-up delay-200">
    <div class="article-body" style="font-size: 1.15rem; line-height: 1.8; color: var(--text-secondary);">
        <%= post.getContent() %>
    </div>

    <div class="author-card">
        <div class="author-avatar"><%= post.getAuthor().substring(0, 1) %></div>
        <div>
            <div class="text-white fw-bold"><%= post.getAuthor() %></div>
            <div class="text-secondary small"><fmt:message key="nav.expert_tag" /> &bull; <%= post.getDate() %></div>
        </div>
    </div>

    <div class="mt-5 pt-5 text-center">
        <a href="blog.jsp" class="btn btn-outline-light rounded-pill px-5 py-3">
            <i class="fa-solid fa-arrow-left me-3"></i> <fmt:message key="nav.back_to_journal" />
        </a>
    </div>
</main>

<%@ include file="/WEB-INF/fragments/footer.jspf" %>

</body>
</html>
