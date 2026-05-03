<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.bloodbank.util.BlogService,com.bloodbank.models.BlogModel,java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Content Management | LifeFlow</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>
<body class="bg-dark text-white">
<% request.setAttribute("activePage", "more"); %>
<jsp:include page="/WEB-INF/fragments/admin-topnav.jspf" />

<div class="admin-view">
    <!-- MAIN CONTENT -->
    <div class="container-fluid px-4 px-md-5">




        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Health Blog Engine</h2>
                <p class="text-white-50">Publish, edit, and orchestrate platform news and medical insights.</p>
            </div>
            <button class="btn btn-danger rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#newArticleModal">
                <i class="fa-solid fa-plus me-2"></i> New Article
            </button>
        </div>

        <% String success = request.getParameter("success"); if(success != null) { %>
            <div class="alert alert-success alert-dismissible fade show border-success border-opacity-25 bg-success bg-opacity-10 text-success rounded-3 mb-4" role="alert">
                <i class="fa-solid fa-check-circle me-2"></i> <%= success.replaceAll("\\+", " ") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="card card-modern fade-in-up delay-100 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-layer-group text-danger me-2"></i> Published Articles</h4>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Article Info</th>
                            <th>Category</th>
                            <th>Author</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<BlogModel> posts = BlogService.getAllPosts();
                            if(posts.isEmpty()) {
                                out.print("<tr><td colspan='4' class='text-center py-5 text-white-50'>No published articles found.</td></tr>");
                            } else {
                                for(BlogModel post : posts) {
                        %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="rounded bg-secondary" style="width:50px; height:50px; overflow:hidden; border: 1px solid rgba(255,255,255,0.1);">
                                                <img src="<%= post.getImageUrl() %>" alt="thumb" style="width:100%; height:100%; object-fit:cover;">
                                            </div>
                                            <div>
                                                <div class="fw-bold text-white"><%= post.getTitle() %></div>
                                                <a href="<%=request.getContextPath()%>/blog_detail.jsp?id=<%= post.getId() %>" target="_blank" class="text-decoration-none text-info small"><i class="fa-solid fa-arrow-up-right-from-square me-1"></i> View Live</a>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 rounded-pill px-3"><%= post.getCategory() %></span></td>
                                    <td class="text-white-50"><i class="fa-solid fa-user-pen me-2"></i><%= post.getAuthor() %></td>
                                    <td class="text-end">
                                        <form action="<%=request.getContextPath()%>/NotifyBlogUpdateServlet" method="post" class="d-inline" onsubmit="return confirm('Broadcast this news to all active newsletter subscribers?');">
                                            <input type="hidden" name="blogId" value="<%= post.getId() %>">
                                            <button type="submit" class="btn btn-outline-info btn-sm rounded-pill px-3 me-2"><i class="fa-solid fa-paper-plane me-1"></i> Notify</button>
                                        </form>
                                        <form action="<%=request.getContextPath()%>/admin/manage-blog" method="post" class="d-inline" onsubmit="return confirm('Are you sure you want to retract this article? It will be permanently removed from the public website.');">
                                            <input type="hidden" name="action" value="retract">
                                            <input type="hidden" name="id" value="<%= post.getId() %>">
                                            <button type="submit" class="btn btn-outline-danger btn-sm rounded-pill px-3"><i class="fa-solid fa-trash me-1"></i> Retract</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- New Article Modal -->
<div class="modal fade" id="newArticleModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg" style="border-radius: var(--radius-lg);">
            <div class="modal-header border-0 p-4 pb-0">
                <h5 class="modal-title fw-bold text-danger"><i class="fa-solid fa-pen-nib me-2"></i> Publish New Article</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <form action="<%=request.getContextPath()%>/admin/manage-blog" method="post">
                    <input type="hidden" name="action" value="create">
                    
                    <div class="mb-3">
                        <label class="form-label small fw-bold">Article Title</label>
                        <input type="text" name="title" class="form-control" placeholder="e.g., The Impact of Regular Donations" required>
                    </div>
                    
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Category</label>
                            <input type="text" name="category" class="form-control" placeholder="e.g., IMPACT or TECHNOLOGY" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Author Name</label>
                            <input type="text" name="author" class="form-control" placeholder="e.g., Dr. Jane Smith" required>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label small fw-bold">Header Image URL (Optional)</label>
                        <input type="url" name="imageUrl" class="form-control" placeholder="https://images.unsplash.com/...">
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label small fw-bold">Short Preview Text</label>
                        <textarea name="preview" class="form-control" rows="2" placeholder="Brief summary for the blog listing..." required></textarea>
                    </div>
                    
                    <div class="mb-4">
                        <label class="form-label small fw-bold">Full Article Content (HTML allowed)</label>
                        <textarea name="content" class="form-control" rows="6" placeholder="<p>Full article content goes here...</p>" required></textarea>
                    </div>
                    
                    <button type="submit" class="btn btn-danger w-100 rounded-pill py-3 fw-bold shadow">Publish Article</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
