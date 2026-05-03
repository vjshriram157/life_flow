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
    <title>Directory Management | LifeFlow Admin</title>
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
                <h2 class="fw-bold mb-1">User Directory Console</h2>
                <p class="text-white-50">Edit or securely remove active verified profiles across your platform.</p>
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

        <!-- ACTIVE DONORS -->
        <div class="card card-modern fade-in-up delay-100 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-users text-danger me-2"></i> Active Donors</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Name</th>
                            <th>Blood Group</th>
                            <th>Contact / Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> donors = db.collection("users")
                                    .whereEqualTo("status", "APPROVED")
                                    .whereEqualTo("role", "DONOR").limit(100).get().get().getDocuments();
                                boolean hasRows = false;
                                for (QueryDocumentSnapshot doc : donors) {
                                    hasRows = true;
                                    String id = doc.getId();
                                    String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
                                    String bg = doc.getString("blood_group") != null ? doc.getString("blood_group") : "";
                                    String city = doc.getString("city") != null ? doc.getString("city") : "";
                                    String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
                                    String email = doc.getString("email") != null ? doc.getString("email") : "";
                        %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-white"><%= name %></div>
                                        <div class="text-white-50" style="font-size:0.8rem;"><%= email %></div>
                                    </td>
                                    <td><span class="badge badge-soft-danger fs-6"><%= bg %></span></td>
                                    <td class="text-white-50">
                                        <div><i class="fa-solid fa-phone me-1"></i> <%= phone %></div>
                                        <div style="font-size:0.8rem;"><i class="fa-solid fa-location-dot me-1"></i> <%= city %></div>
                                    </td>
                                    <td class="text-end">
                                        <button class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold me-2" data-bs-toggle="modal" data-bs-target="#editModal<%= id %>"><i class="fa-solid fa-pen me-1"></i> Edit</button>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminUserManagementServlet" class="d-inline" onsubmit="return confirm('Are you sure you want to permanently delete this donor?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="userId" value="<%= id %>">
                                            <input type="hidden" name="role" value="DONOR">
                                            <input type="hidden" name="email" value="<%= email %>">
                                            <button class="btn btn-outline-danger btn-sm rounded-pill px-3 fw-bold"><i class="fa-solid fa-trash me-1"></i> Remove</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows) { out.print("<tr><td colspan='4' class='text-center text-white-50 py-5'><i class='fa-solid fa-folder-open mb-2 fs-2 text-light'></i><br>No active donors.</td></tr>"); }
                            } catch (Exception e) { 
                                 String m = e.getMessage();
                                 if (m != null && m.contains("RESOURCE_EXHAUSTED")) {
                                     out.print("<tr><td colspan='4' class='text-center py-4 text-danger'><i class='fa-solid fa-triangle-exclamation me-2'></i> <b>Firestore Quota Exceeded</b></td></tr>");
                                 } else {
                                     out.print("<tr><td colspan='4' class='text-danger'>Error: " + m + "</td></tr>");
                                 }
                             }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- RARE DONOR REGISTRY -->
        <div class="card card-modern fade-in-up delay-150 mb-5 border-danger border-2">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="fw-bold mb-0 text-danger"><i class="fa-solid fa-gem me-2"></i> Rare Donor Registry</h4>
                    <button class="btn btn-danger rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#bulkNotifyModal">
                        <i class="fa-solid fa-bullhorn me-2"></i> Bulk Mobilize
                    </button>
                </div>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="bg-danger bg-opacity-10 text-danger">
                        <tr>
                            <th>Hero Name</th>
                            <th>Rare Blood Group</th>
                            <th>Contact / Area</th>
                            <th class="text-end">Status</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                boolean hasRare = false;
                                Firestore dbRare = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> allDonors = dbRare.collection("users")
                                    .whereEqualTo("status", "APPROVED")
                                    .whereEqualTo("role", "DONOR").limit(200).get().get().getDocuments();
                                    
                                for (QueryDocumentSnapshot doc : allDonors) {
                                    String bg = doc.getString("blood_group");
                                    if (bg != null && bg.endsWith("-")) {
                                        hasRare = true;
                                        String rId = doc.getId();
                                        String rName = doc.getString("full_name") != null ? doc.getString("full_name") : "";
                                        String rCity = doc.getString("city") != null ? doc.getString("city") : "";
                                        String rPhone = doc.getString("phone") != null ? doc.getString("phone") : "";
                                        String rEmail = doc.getString("email") != null ? doc.getString("email") : "";
                        %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-white"><i class="fa-solid fa-crown text-warning me-2"></i><%= rName %></div>
                                        <div class="text-white-50" style="font-size:0.8rem;"><%= rEmail %></div>
                                    </td>
                                    <td><span class="badge bg-danger rounded-pill px-3 fs-6"><%= bg %></span></td>
                                    <td class="text-white-50">
                                        <div><i class="fa-solid fa-phone me-1"></i> <%= rPhone %></div>
                                        <div style="font-size:0.8rem;"><i class="fa-solid fa-location-dot me-1"></i> <%= rCity %></div>
                                    </td>
                                    <td class="text-end">
                                        <span class="badge bg-success bg-opacity-10 text-success rounded-pill">Verified Active</span>
                                    </td>
                                </tr>
                        <%
                                    }
                                }
                                if (!hasRare) { out.print("<tr><td colspan='4' class='text-center text-white-50 py-5'>No rare donors found in the network.</td></tr>"); }
                            } catch (Exception e) {}
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>



        <!-- ACTIVE BLOOD BANKS -->
        <div class="card card-modern fade-in-up delay-200 mb-5">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-hospital text-danger me-2"></i> Active Blood Banks</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Facility Name</th>
                            <th>Contact Info</th>
                            <th>City/Area</th>
                            <th class="text-end">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore db = FirebaseConfig.getFirestore();
                                List<QueryDocumentSnapshot> banks = db.collection("users")
                                    .whereEqualTo("status", "APPROVED")
                                    .whereEqualTo("role", "BANK").limit(100).get().get().getDocuments();
                                boolean hasRows2 = false;
                                for (QueryDocumentSnapshot doc : banks) {
                                    hasRows2 = true;
                                    String id = doc.getId();
                                    String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
                                    String city = doc.getString("city") != null ? doc.getString("city") : "";
                                    String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
                                    String email = doc.getString("email") != null ? doc.getString("email") : "";
                        %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-white"><%= name %></div>
                                        <div class="text-white-50" style="font-size:0.8rem;"><%= id.length() > 8 ? id.substring(0,8) : id %>...</div>
                                    </td>
                                    <td class="text-white-50">
                                        <div><i class="fa-solid fa-envelope me-1"></i> <%= email %></div>
                                        <div style="font-size:0.8rem;"><i class="fa-solid fa-phone me-1"></i> <%= phone %></div>
                                    </td>
                                    <td class="text-white-50"><i class="fa-solid fa-location-dot me-1"></i> <%= city %></td>
                                    <td class="text-end">
                                        <button class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold me-2" data-bs-toggle="modal" data-bs-target="#editModal<%= id %>"><i class="fa-solid fa-pen me-1"></i> Edit</button>
                                        <form method="post" action="<%= request.getContextPath() %>/AdminUserManagementServlet" class="d-inline" onsubmit="return confirm('WARNING: Removing a blood bank will also erase them from the spatial locator map! Proceed?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="userId" value="<%= id %>">
                                            <input type="hidden" name="role" value="BANK">
                                            <input type="hidden" name="email" value="<%= email %>">
                                            <button class="btn btn-danger btn-sm rounded-pill px-3 fw-bold shadow-sm"><i class="fa-solid fa-trash me-1"></i> Remove</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                                if (!hasRows2) { out.print("<tr><td colspan='4' class='text-center text-white-50 py-5'><i class='fa-solid fa-folder-open mb-2 fs-2 text-light'></i><br>No active blood banks.</td></tr>"); }
                            } catch (Exception e) { 
                                 String m = e.getMessage();
                                 if (m != null && m.contains("RESOURCE_EXHAUSTED")) {
                                     out.print("<tr><td colspan='4' class='text-center py-4 text-danger'><i class='fa-solid fa-triangle-exclamation me-2'></i> <b>Firestore Quota Exceeded</b></td></tr>");
                                 } else {
                                     out.print("<tr><td colspan='4' class='text-danger'>Error: " + m + "</td></tr>");
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

<!-- DONOR MODALS -->
<%
    try {
        Firestore db = FirebaseConfig.getFirestore();
        List<QueryDocumentSnapshot> donors = db.collection("users")
            .whereEqualTo("status", "APPROVED")
            .whereEqualTo("role", "DONOR").limit(100).get().get().getDocuments();
        for (QueryDocumentSnapshot doc : donors) {
            String id = doc.getId();
            String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
            String bg = doc.getString("blood_group") != null ? doc.getString("blood_group") : "";
            String city = doc.getString("city") != null ? doc.getString("city") : "";
            String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
            String email = doc.getString("email") != null ? doc.getString("email") : "";
%>
    <div class="modal fade" id="editModal<%= id %>" tabindex="-1" aria-labelledby="editLabel<%= id %>" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border border-secondary shadow-lg bg-dark text-white" style="border-radius: 1.5rem;">
                <form action="<%= request.getContextPath() %>/AdminUserManagementServlet" method="post">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold" id="editLabel<%= id %>">Edit Donor Profile</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="userId" value="<%= id %>">
                        <input type="hidden" name="role" value="DONOR">
                        <input type="hidden" name="email" value="<%= email %>">
                        
                        <div class="mb-3">
                            <label class="form-label text-white-50 small text-uppercase fw-bold">Full Name</label>
                            <input type="text" class="form-control form-control-modern" name="fullName" value="<%= name %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-white-50 small text-uppercase fw-bold">Blood Group</label>
                            <select class="form-select form-control-modern" name="bloodGroup">
                                <option value="A+" <%= "A+".equals(bg)?"selected":"" %>>A+</option>
                                <option value="A-" <%= "A-".equals(bg)?"selected":"" %>>A-</option>
                                <option value="B+" <%= "B+".equals(bg)?"selected":"" %>>B+</option>
                                <option value="B-" <%= "B-".equals(bg)?"selected":"" %>>B-</option>
                                <option value="O+" <%= "O+".equals(bg)?"selected":"" %>>O+</option>
                                <option value="O-" <%= "O-".equals(bg)?"selected":"" %>>O-</option>
                                <option value="AB+" <%= "AB+".equals(bg)?"selected":"" %>>AB+</option>
                                <option value="AB-" <%= "AB-".equals(bg)?"selected":"" %>>AB-</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-white-50 small text-uppercase fw-bold">Phone Number</label>
                            <input type="text" class="form-control form-control-modern" name="phone" value="<%= phone %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-white-50 small text-uppercase fw-bold">City / Area</label>
                            <input type="text" class="form-control form-control-modern" name="city" value="<%= city %>" required>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-outline-light rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-premium rounded-pill px-4 shadow-sm">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
<%
        }
    } catch (Exception e) {}
%>

<!-- BANK MODALS -->
<%
    try {
        Firestore db = FirebaseConfig.getFirestore();
        List<QueryDocumentSnapshot> banks = db.collection("users")
            .whereEqualTo("status", "APPROVED")
            .whereEqualTo("role", "BANK").limit(100).get().get().getDocuments();
        for (QueryDocumentSnapshot doc : banks) {
            String id = doc.getId();
            String name = doc.getString("full_name") != null ? doc.getString("full_name") : "";
            String city = doc.getString("city") != null ? doc.getString("city") : "";
            String phone = doc.getString("phone") != null ? doc.getString("phone") : "";
            String email = doc.getString("email") != null ? doc.getString("email") : "";
%>
    <div class="modal fade" id="editModal<%= id %>" tabindex="-1" aria-labelledby="editLabel<%= id %>" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border border-secondary shadow-lg bg-dark text-white" style="border-radius: 1.5rem;">
                <form action="<%= request.getContextPath() %>/AdminUserManagementServlet" method="post">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold" id="editLabel<%= id %>">Edit Blood Bank</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="userId" value="<%= id %>">
                        <input type="hidden" name="role" value="BANK">
                        <input type="hidden" name="email" value="<%= email %>">
                        
                        <div class="mb-3">
                            <label class="form-label text-white-50 small text-uppercase fw-bold">Facility Name</label>
                            <input type="text" class="form-control form-control-modern" name="fullName" value="<%= name %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-white-50 small text-uppercase fw-bold">Phone Number</label>
                            <input type="text" class="form-control form-control-modern" name="phone" value="<%= phone %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-white-50 small text-uppercase fw-bold">City / Area</label>
                            <input type="text" class="form-control form-control-modern" name="city" value="<%= city %>" required>
                        </div>
                        <p class="text-danger small mt-3"><i class="fa-solid fa-triangle-exclamation me-1"></i> Saving changes will auto-sync their map coordinates if they are connected to the spatial index.</p>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-outline-light rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-premium rounded-pill px-4 shadow-sm">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
<%
        }
    } catch (Exception e) {}
%>

<!-- ===== BULK NOTIFY MODAL (must be at body level to avoid transform stacking context) ===== -->
<div class="modal fade" id="bulkNotifyModal" tabindex="-1" aria-labelledby="bulkNotifyLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border border-secondary shadow-lg" style="background:#1e293b; border-radius:1.5rem; color:#f8fafc;">
            <div class="modal-header border-0 p-4 pb-0">
                <h5 class="modal-title fw-bold text-danger" id="bulkNotifyLabel"><i class="fa-solid fa-bullhorn me-2"></i> Bulk Mobilize Rare Donors</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <p style="color:#94a3b8; font-size:0.875rem;" class="mb-4">Instantly alert all verified donors with negative blood types (O-, A-, B-, AB-) across the entire platform.</p>
                <form action="<%= request.getContextPath() %>/api/notify-rare" method="post">
                    <div class="mb-3">
                        <label class="fw-bold" style="font-size:0.8rem; text-transform:uppercase; letter-spacing:0.5px; color:#94a3b8;">Emergency Message</label>
                        <textarea name="message" rows="4"
                            placeholder="A critical shortage of rare blood types has been reported. Please prepare for direct contact or visit your nearest facility."
                            style="width:100%; margin-top:0.5rem; padding:0.75rem 1rem; border-radius:0.5rem; border:1px solid #475569; background:#0f172a; color:#f8fafc; font-size:0.95rem; resize:vertical;"></textarea>
                    </div>
                    <button type="submit" class="btn btn-danger w-100 rounded-pill py-2 fw-bold">Dispatch Notification</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
