<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List" %>

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
    <title>Newsletter Subscribers | LifeFlow Admin</title>
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
                <h2 class="fw-bold mb-1">Newsletter Subscribers</h2>
                <p class="text-white-50">View all users who have subscribed to the platform's newsletter.</p>
            </div>
            <div>
                <button class="btn btn-outline-secondary rounded-pill px-4" onclick="window.location.reload()"><i class="fa-solid fa-rotate-right me-2"></i>Refresh</button>
            </div>
        </div>

        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <div class="alert alert-danger fade-in-up delay-100"><i class="fa-solid fa-triangle-exclamation me-2"></i> <%= error %></div>
        <%
            }
            if (success != null) {
        %>
            <div class="alert alert-success fade-in-up delay-100"><i class="fa-solid fa-circle-check me-2"></i> <%= success %></div>
        <%
            }
        %>

        <!-- SUBSCRIBERS LIST -->
        <div class="card card-modern fade-in-up delay-100 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-envelopes-bulk text-danger me-2"></i> Subscribers List</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Email Address</th>
                            <th>Subscribed On</th>
                            <th class="text-center">Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                // We query the "subscribers" collection
                                List<QueryDocumentSnapshot> subs = db.collection("subscribers")
                                    .limit(100).get().get().getDocuments();
                                boolean hasRows = false;
                                for (QueryDocumentSnapshot doc : subs) {
                                    hasRows = true;
                                    String id = doc.getId();
                                    String email = doc.getString("email") != null ? doc.getString("email") : "N/A";
                                    String subscribedAt = doc.getString("subscribed_at") != null ? doc.getString("subscribed_at") : "Unknown Date";
                                    String status = doc.getString("status") != null ? doc.getString("status") : "ACTIVE";
                        %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-white"><i class="fa-regular fa-envelope text-white-50 me-2"></i><%= email %></div>
                                    </td>
                                    <td><span class="text-white-50"><i class="fa-regular fa-calendar text-white-50 me-2"></i><%= subscribedAt %></span></td>
                                    <td class="text-center">
                                        <% if ("ACTIVE".equalsIgnoreCase(status)) { %>
                                            <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3 py-2"><i class="fa-solid fa-check me-1"></i> Active</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary bg-opacity-10 text-secondary rounded-pill px-3 py-2"><i class="fa-solid fa-xmark me-1"></i> Inactive</span>
                                        <% } %>
                                    </td>
                                    <td class="text-end">
                                        <form action="<%=request.getContextPath()%>/RemoveSubscriberServlet" method="POST" style="display: inline;" onsubmit="return confirm('Are you sure you want to remove this subscriber?');">
                                            <input type="hidden" name="subscriberId" value="<%= id %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3">
                                                <i class="fa-solid fa-trash-can me-2"></i>Remove
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows) { out.print("<tr><td colspan='4' class='text-center text-white-50 py-5'><i class='fa-solid fa-folder-open mb-2 fs-2 text-light'></i><br>No active subscribers.</td></tr>"); }
                            } catch (Exception e) { out.print("<tr><td colspan='4' class='text-center text-danger'>Error fetching subscribers: " + e.getMessage() + "</td></tr>"); }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
