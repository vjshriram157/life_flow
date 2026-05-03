<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List,java.util.ArrayList" %>
<%
    String userId = (String) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null || role == null || !"DONOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String reqBg = request.getParameter("bloodGroup");
    String reqCity = request.getParameter("city");
    
    boolean isSearch = reqBg != null && !reqBg.isEmpty();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Find Donors | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css?v=5" rel="stylesheet">
</head>
<body>
<div class="d-flex">
    <!-- SIDEBAR -->
    <% request.setAttribute("activePage", "find_donors"); %>
    <jsp:include page="/WEB-INF/fragments/sidebar-donor.jspf" />

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1 text-white">Find Nearby Donors</h2>
                <p class="text-light text-opacity-75">Connect with life-savers in your community.</p>
            </div>
            <a href="home.jsp" class="btn btn-outline-secondary rounded-pill px-4 rounded-pill border-opacity-25 text-white">
                <i class="fa-solid fa-arrow-left me-2"></i> Back
            </a>
        </div>

        <div class="card card-modern fade-in-up delay-100 p-3 mb-5 border-0" style="background-color: var(--surface-dark);">
            <div class="card-body">
                <form action="findDonors.jsp" method="get">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-5">
                            <label class="form-label text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem; letter-spacing: 1px;">Blood Group Needed</label>
                            <select name="bloodGroup" class="form-select bg-dark text-white border-secondary border-opacity-25 rounded-pill py-2 px-4 shadow-sm" required>
                                <option value="" disabled <%= !isSearch ? "selected" : "" %>>Select Group</option>
                                <option value="A+" <%= "A+".equals(reqBg) ? "selected" : "" %>>A+</option>
                                <option value="A-" <%= "A-".equals(reqBg) ? "selected" : "" %>>A-</option>
                                <option value="B+" <%= "B+".equals(reqBg) ? "selected" : "" %>>B+</option>
                                <option value="B-" <%= "B-".equals(reqBg) ? "selected" : "" %>>B-</option>
                                <option value="AB+" <%= "AB+".equals(reqBg) ? "selected" : "" %>>AB+</option>
                                <option value="AB-" <%= "AB-".equals(reqBg) ? "selected" : "" %>>AB-</option>
                                <option value="O+" <%= "O+".equals(reqBg) ? "selected" : "" %>>O+</option>
                                <option value="O-" <%= "O-".equals(reqBg) ? "selected" : "" %>>O-</option>
                            </select>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem; letter-spacing: 1px;">City (Optional)</label>
                            <div class="input-group">
                                <span class="input-group-text bg-dark border-secondary border-opacity-25 rounded-start-pill text-danger ps-4"><i class="fa-solid fa-building"></i></span>
                                <input type="text" name="city" value="<%= reqCity != null ? reqCity : "" %>" class="form-control bg-dark text-white border-secondary border-opacity-25 rounded-end-pill py-2 shadow-sm" placeholder="e.g. trichy">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-danger w-100 rounded-pill py-2 shadow-lg fw-bold border-0" style="background: linear-gradient(135deg, var(--primary-crimson) 0%, #aa0000 100%);">
                                <i class="fa-solid fa-search me-2"></i> Search
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <% if (isSearch) { %>
        <div class="row g-4 fade-in-up delay-150">
            <%
                int count = 0;
                try {
                    Firestore db = FirebaseConfig.getFirestore();
                    ApiFuture<QuerySnapshot> donorFuture = db.collection("users")
                        .whereEqualTo("role", "DONOR")
                        .whereEqualTo("blood_group", reqBg).get();
                    
                    List<QueryDocumentSnapshot> docs = donorFuture.get().getDocuments();
                    
                    for (QueryDocumentSnapshot doc : docs) {
                        String status = doc.getString("status");
                        if (!"APPROVED".equalsIgnoreCase(status)) continue; // only approved donors
                        
                        String docId = doc.getId();
                        if (docId.equals(userId)) continue; // dont show self
                        
                        String dName = doc.getString("full_name");
                        String dCity = doc.getString("city");
                        String dPhone = doc.getString("phone");
                        String dEmail = doc.getString("email");
                        
                        // Client-side partial city filter
                        if (reqCity != null && !reqCity.trim().isEmpty() && dCity != null) {
                            if (!dCity.toLowerCase().contains(reqCity.toLowerCase().trim())) {
                                continue;
                            }
                        }

                        count++;
            %>
            <div class="col-md-4 col-xl-3">
                <div class="card card-modern h-100 bg-dark border-secondary border-opacity-25">
                    <div class="card-body p-4 position-relative">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div class="rounded-circle d-flex align-items-center justify-content-center bg-secondary bg-opacity-25" style="width: 50px; height: 50px;">
                                <i class="fa-solid fa-user text-white-50 fs-4"></i>
                            </div>
                            <span class="badge bg-danger rounded-pill px-3 fs-6"><%= reqBg %></span>
                        </div>
                        
                        <h5 class="fw-bold text-white mb-1"><%= dName != null ? dName.toLowerCase() : "unknown" %></h5>
                        <p class="text-white-50 small mb-3"><i class="fa-solid fa-location-dot text-white-50 me-1"></i> <%= dCity != null ? dCity.toLowerCase() : "unspecified" %></p>
                        
                        <hr class="border-secondary border-opacity-50">
                        
                        <div class="mb-4">
                            <div class="text-light text-opacity-75 small mb-2"><i class="fa-solid fa-phone me-2 text-danger"></i> <%= dPhone != null ? dPhone : "hidden" %></div>
                            <div class="text-light text-opacity-75 small text-truncate"><i class="fa-solid fa-envelope me-2 text-danger"></i> <%= dEmail != null ? dEmail : "hidden" %></div>
                        </div>
                        
                        <div class="mt-auto">
                            <a href="tel:<%= dPhone %>" class="btn btn-outline-danger w-100 rounded-pill py-2 fw-bold text-white border-secondary border-opacity-50" style="border-width: 1px;">
                                <i class="fa-solid fa-phone-volume me-2"></i> Contact Now
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }
                } catch (Exception e) {}
                
                if (count == 0) {
            %>
            <div class="col-12 text-center py-5">
                <i class="fa-solid fa-user-xmark fs-1 text-white-50 mb-3 opacity-25"></i>
                <h5 class="text-white">No Donors Found</h5>
                <p class="text-white-50">Try broadening your search criteria or trying a different city.</p>
            </div>
            <%
                }
            %>
        </div>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
