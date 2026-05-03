<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List" %>
<%
    String userId = (String) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    
    // Convert to upper case for safe comparison
    String upperRole = (role != null) ? role.toUpperCase() : "";
    
    if (userId == null || (!"ADMIN".equals(upperRole) && !"BANK".equals(upperRole))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Campaign Management | LifeFlow</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>
<body class="bg-dark text-white">
<% 
    request.setAttribute("activePage", "campaigns"); 
    if ("ADMIN".equalsIgnoreCase(role)) {
%>
    <jsp:include page="/WEB-INF/fragments/admin-topnav.jspf" />
<% } else { %>
    <div class="d-flex">
        <jsp:include page="/WEB-INF/fragments/sidebar-bank.jspf" />
<% } %>

<div class="<%= "ADMIN".equalsIgnoreCase(role) ? "admin-view" : "" %>">
    <!-- MAIN CONTENT -->
    <div class="container-fluid px-4 px-md-5">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Smart Campaigns</h2>
                <p class="text-white-50">Organize blood drives and notify local donors instantly.</p>
            </div>
            <button class="btn btn-premium rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#createCampaignModal">
                <i class="fa-solid fa-plus me-2"></i> New Campaign
            </button>
        </div>


        <div class="row g-4 mb-5">
            <div class="col-12 fade-in-up delay-100">
                <div class="card card-modern">
                    <div class="card-body p-4 p-md-5">
                        <h5 class="fw-bold mb-4"><i class="fa-solid fa-bullhorn text-danger me-2"></i> Active Campaigns</h5>
                        <div class="table-responsive">
                            <table class="table table-modern align-middle mb-0">
                                <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                                    <tr>
                                        <th>Campaign Title</th>
                                        <th>City</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
<%
    try {
        Firestore db = FirebaseConfig.getFirestore();
        QuerySnapshot campaigns = db.collection("campaigns").orderBy("created_at", Query.Direction.DESCENDING).get().get();
        boolean any = false;
        for (QueryDocumentSnapshot doc : campaigns.getDocuments()) {
            any = true;
            String id = doc.getId();
            String title = doc.getString("title");
            String city = doc.getString("city");
            String date = doc.getString("date");
            String status = doc.getString("status");
%>
                                    <tr>
                                        <td><div class="fw-bold"><%= title %></div></td>
                                        <td class="text-white-50"><i class="fa-solid fa-location-dot me-1"></i> <%= city %></td>
                                        <td><i class="fa-regular fa-calendar me-1"></i> <%= date %></td>
                                        <td><span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3"><%= status %></span></td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-danger rounded-pill px-3 shadow-sm" 
                                                    onclick="showCampaignDetails('<%= title.replace("'","\\'") %>', '<%= doc.getString("description") != null ? doc.getString("description").replace("'","\\'") : "No description." %>', '<%= city %>', '<%= date %>', '<%= status %>')">
                                                <i class="fa-solid fa-circle-info me-1"></i> View Details
                                            </button>
                                        </td>
                                    </tr>
<%
        }
        if (!any) {
            out.print("<tr><td colspan='5' class='text-center text-white-50 py-5'>No active campaigns found.</td></tr>");
        }
    } catch (Exception e) {
        out.print("<tr><td colspan='5' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<% if (!"ADMIN".equalsIgnoreCase(role)) { %>
</div> <!-- close d-flex for bank -->
<% } %>

<!-- Create Campaign Modal -->
<div class="modal fade" id="createCampaignModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg text-white" style="border-radius: var(--radius-lg); background-color: var(--surface-dark);">
            <div class="modal-header border-0 p-4">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-bullhorn text-danger me-2"></i> Launch Smart Campaign</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 pt-0">
                <form id="campaignForm">
                    <input type="hidden" name="action" value="create">
                    <div class="mb-3">
                        <label class="form-label small fw-bold">Campaign Title</label>
                        <input type="text" name="title" class="form-control rounded-pill" placeholder="Summer Mega Donation Drive" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold">Event Description</label>
                        <textarea name="description" class="form-control" style="border-radius: var(--radius-md);" rows="3" placeholder="Describe the goal of this drive..."></textarea>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6 mb-3">
                            <label class="form-label small fw-bold">Target City</label>
                            <input type="text" name="city" class="form-control rounded-pill" placeholder="e.g. Bangalore" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label small fw-bold">Event Date</label>
                            <input type="date" name="date" class="form-control rounded-pill" required>
                        </div>
                    </div>
                    <div class="alert alert-warning small mt-2">
                        <i class="fa-solid fa-circle-info me-1"></i> Saving this will instantly notify all donors in the target city via Email.
                    </div>
                    <button type="submit" class="btn btn-premium w-100 rounded-pill py-2 mt-3 fw-bold">Launch & Notify Donors</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Campaign Details Modal -->
<div class="modal fade" id="campaignDetailsModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg text-white" style="border-radius: var(--radius-lg); background-color: var(--surface-dark);">
            <div class="modal-header border-0 p-4 pb-0">
                <h5 class="modal-title fw-bold" id="detTitle">Campaign Details</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-4">
                    <label class="small fw-bold text-danger text-uppercase mb-2 d-block" style="letter-spacing: 1px;">Description</label>
                    <p id="detDesc" class="text-white-50 mb-0"></p>
                </div>
                <div class="row g-3">
                    <div class="col-6">
                        <label class="small fw-bold text-white-50 text-uppercase mb-1 d-block" style="font-size: 0.7rem;">Target City</label>
                        <div id="detCity" class="fw-bold"></div>
                    </div>
                    <div class="col-6">
                        <label class="small fw-bold text-white-50 text-uppercase mb-1 d-block" style="font-size: 0.7rem;">Event Date</label>
                        <div id="detDate" class="fw-bold"></div>
                    </div>
                </div>
                <hr class="border-secondary opacity-25 my-4">
                <div class="d-flex justify-content-between align-items-center">
                    <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3 py-2" id="detStatus">ACTIVE</span>
                    <button class="btn btn-sm btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showCampaignDetails(title, desc, city, date, status) {
        document.getElementById('detTitle').innerText = title;
        document.getElementById('detDesc').innerText = desc;
        document.getElementById('detCity').innerHTML = '<i class="fa-solid fa-location-dot text-danger me-1"></i> ' + city;
        document.getElementById('detDate').innerHTML = '<i class="fa-regular fa-calendar text-danger me-1"></i> ' + date;
        document.getElementById('detStatus').innerText = status;
        
        const myModal = new bootstrap.Modal(document.getElementById('campaignDetailsModal'));
        myModal.show();
    }

    document.getElementById('campaignForm').onsubmit = function(e) {
        e.preventDefault();
        const formData = new FormData(this);
        const submitBtn = this.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i>Launching...';

        fetch('<%=request.getContextPath()%>/api/campaigns', {
            method: 'POST',
            body: new URLSearchParams(formData)
        })
        .then(res => res.json())
        .then(data => {
            if(data.success) {
                alert('Campaign launched successfully! Targeted notifications dispatched.');
                window.location.reload();
            } else {
                alert('Error: ' + data.error);
                submitBtn.disabled = false;
                submitBtn.innerHTML = 'Launch & Notify Donors';
            }
        }).catch(err => {
            console.error(err);
            alert('A system error occurred.');
            submitBtn.disabled = false;
            submitBtn.innerHTML = 'Launch & Notify Donors';
        });
    }
</script>
</body>
</html>
