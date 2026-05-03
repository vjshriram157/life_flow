<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Pending Approvals | LifeFlow Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>
<body class="bg-dark text-white">
<% request.setAttribute("activePage", "approvals"); %>
<jsp:include page="/WEB-INF/fragments/admin-topnav.jspf" />

<div class="admin-view">
    <!-- MAIN CONTENT -->
    <div class="container-fluid px-4 px-md-5">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Verify Pending Registrations</h2>
                <p class="text-white-50">Review and approve new donors and blood banks to grant them system access.</p>
            </div>
        </div>

        <!-- DONOR APPROVALS -->
        <div class="card card-modern fade-in-up delay-100 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-users text-danger me-2"></i> Pending Donors</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Applicant Name</th>
                            <th>Blood Group</th>
                            <th>City/Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> donors = db.collection("users")
                                    .whereEqualTo("status", "PENDING")
                                    .whereEqualTo("role", "DONOR").limit(100).get().get().getDocuments();
                                boolean hasRows = false;
                                for (QueryDocumentSnapshot doc : donors) {
                                    hasRows = true;
                        %>
                                <tr>
                                    <td><div class="fw-bold text-white"><%= doc.getString("full_name") %></div></td>
                                    <td><span class="badge badge-soft-danger fs-6"><%= doc.getString("blood_group") %></span></td>
                                    <td class="text-white-50"><i class="fa-solid fa-location-dot me-1"></i> <%= doc.getString("city") %></td>
                                    <td class="text-end">
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="approve">
                                            <button class="btn btn-success btn-sm rounded-pill px-3 fw-bold me-2"><i class="fa-solid fa-check me-1"></i> Approve</button>
                                        </form>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="reject">
                                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3 fw-bold"><i class="fa-solid fa-xmark me-1"></i> Reject</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows) { out.print("<tr><td colspan='4' class='text-center text-white-50 py-5'><i class='fa-solid fa-clipboard-check mb-2 fs-2 text-light'></i><br>No pending donors. All caught up!</td></tr>"); }
                            } catch (Exception e) { out.print("<tr><td colspan='4' class='text-danger'>Error: " + e.getMessage() + "</td></tr>"); }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- BANK APPROVALS -->
        <div class="card card-modern fade-in-up delay-200">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-hospital text-danger me-2"></i> Pending Blood Banks</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Facility Name</th>
                            <th>City/Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> banks = db.collection("users")
                                    .whereEqualTo("status", "PENDING")
                                    .whereEqualTo("role", "BANK").limit(100).get().get().getDocuments();
                                boolean hasRows2 = false;
                                for (QueryDocumentSnapshot doc : banks) {
                                    hasRows2 = true;
                        %>
                                <tr>
                                    <td><div class="fw-bold text-white"><%= doc.getString("full_name") %></div></td>
                                    <td class="text-white-50"><i class="fa-solid fa-location-dot me-1"></i> <%= doc.getString("city") %></td>
                                    <td class="text-end">
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="approve">
                                            <button class="btn btn-success btn-sm rounded-pill px-3 fw-bold me-2"><i class="fa-solid fa-check me-1"></i> Approve</button>
                                        </form>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminApprovalServlet" class="d-inline">
                                            <input type="hidden" name="type" value="user">
                                            <input type="hidden" name="id" value="<%= doc.getId() %>">
                                            <input type="hidden" name="action" value="reject">
                                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3 fw-bold"><i class="fa-solid fa-xmark me-1"></i> Reject</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows2) { out.print("<tr><td colspan='3' class='text-center text-white-50 py-5'><i class='fa-solid fa-clipboard-check mb-2 fs-2 text-light'></i><br>No pending blood banks. All caught up!</td></tr>"); }
                            } catch (Exception e) { out.print("<tr><td colspan='3' class='text-danger'>Error: " + e.getMessage() + "</td></tr>"); }
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
