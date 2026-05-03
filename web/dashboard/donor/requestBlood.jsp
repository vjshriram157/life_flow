<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List" %>
<%
    String userId = (String) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null || role == null || !"DONOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Post a Blood Request | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css?v=5" rel="stylesheet">
</head>
<body>
<div class="d-flex">
    <!-- SIDEBAR -->
    <% request.setAttribute("activePage", "request_blood"); %>
    <jsp:include page="/WEB-INF/fragments/sidebar-donor.jspf" />

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1 text-white">Post a Blood Request</h2>
                <p class="text-light text-opacity-75">Broadcast your need to nearby donors and blood banks.</p>
            </div>
            <a href="home.jsp" class="btn btn-outline-secondary rounded-pill px-4 rounded-pill border-opacity-25 text-white">
                <i class="fa-solid fa-arrow-left me-2"></i> Back to Dashboard
            </a>
        </div>

        <div class="row g-4 fade-in-up delay-100">
            <!-- LEFT COLUMN: REQUEST FORM -->
            <div class="col-lg-8">
                <div class="card card-modern h-100">
                    <div class="card-body p-4 p-md-5">
                        <form action="<%=request.getContextPath()%>/api/peer-request" method="post" id="requestForm">
                            <input type="hidden" name="action" value="create">
                            <input type="hidden" name="patientName" value="<%= session.getAttribute("fullName") %>"> <!-- We auto-assign the donor name as requester -->
                            <input type="hidden" name="hospitalCity" id="hospitalCityCombined">
                            
                            <div class="row g-4 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem; letter-spacing: 1px;">Blood Group Needed</label>
                                    <select name="bloodGroup" class="form-select bg-dark text-white border-secondary border-opacity-25 py-2" required>
                                        <option value="" disabled selected>Select Group</option>
                                        <option value="A+">A+</option>
                                        <option value="A-">A-</option>
                                        <option value="B+">B+</option>
                                        <option value="B-">B-</option>
                                        <option value="AB+">AB+</option>
                                        <option value="AB-">AB-</option>
                                        <option value="O+">O+</option>
                                        <option value="O-">O-</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem; letter-spacing: 1px;">Urgency Level</label>
                                    <select name="urgency" class="form-select bg-dark text-white border-secondary border-opacity-25 py-2">
                                        <option value="Normal">Normal</option>
                                        <option value="Emergency">Emergency</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row g-4 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem; letter-spacing: 1px;">Target Blood Bank (For Donation)</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-dark border-secondary border-opacity-25 text-danger"><i class="fa-solid fa-hospital"></i></span>
                                        <select name="bankId" id="bankId" class="form-select bg-dark text-white border-secondary border-opacity-25 py-2" required>
                                            <option value="" disabled selected>Select Preferred Bank</option>
                                            <%
                                                try {
                                                    Firestore db = FirebaseConfig.getFirestore();
                                                    QuerySnapshot bankSnap = db.collection("blood_banks").whereEqualTo("status", "APPROVED").get().get();
                                                    for (QueryDocumentSnapshot bDoc : bankSnap.getDocuments()) {
                                                        String bId = bDoc.getId();
                                                        String bName = bDoc.getString("bank_name");
                                                        String bCity = bDoc.getString("city");
                                            %>
                                                        <option value="<%= bId %>" data-city="<%= bCity %>"><%= bName %> (<%= bCity %>)</option>
                                            <%
                                                    }
                                                } catch (Exception e) {}
                                            %>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem; letter-spacing: 1px;">Units Required</label>
                                    <input type="number" name="units" class="form-control bg-dark text-white border-secondary border-opacity-25 py-2" placeholder="1" min="1" max="10" value="1" required>
                                </div>
                            </div>

                            <div class="mb-5">
                                <label class="form-label text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem; letter-spacing: 1px;">Additional Message (Optional)</label>
                                <textarea name="notes" class="form-control bg-dark text-white border-secondary border-opacity-25" rows="4" placeholder="Any specific requirements or contact instructions..."></textarea>
                            </div>

                            <button type="submit" class="btn btn-danger w-100 rounded-pill py-3 fw-bold fs-5 shadow-lg" style="background: linear-gradient(135deg, var(--primary-crimson) 0%, #aa0000 100%);">
                                <i class="fa-solid fa-bullhorn me-2"></i> Broadcast Blood Request
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- RIGHT COLUMN: HISTORY & INFO -->
            <div class="col-lg-4">
                <!-- Info Banner -->
                <div class="card border-0 mb-4 rounded-4" style="background-color: #d1eff7;">
                    <div class="card-body p-4">
                        <h5 class="fw-bold text-white"><i class="fa-solid fa-shield-halved text-info me-2"></i> Safe & Secure</h5>
                        <p class="mb-0 text-white small opacity-75">Your request will be visible to matched donors and local blood banks. High-urgency requests will also trigger mobile push notifications to donors in your city.</p>
                    </div>
                </div>

                <!-- Recent Requests -->
                <h5 class="fw-bold text-white mb-3"><i class="fa-solid fa-clock-rotate-left me-2"></i> Your Recent Requests</h5>
                
                <div class="d-flex flex-column gap-3">
                    <%
                        boolean hasRequests = false;
                        try {
                            Firestore db = FirebaseConfig.getFirestore();
                            ApiFuture<QuerySnapshot> future = db.collection("peer_requests")
                                .whereEqualTo("donor_id", userId)
                                .orderBy("created_at", com.google.cloud.firestore.Query.Direction.DESCENDING)
                                .limit(5).get();
                            List<QueryDocumentSnapshot> docs = future.get().getDocuments();

                            for(QueryDocumentSnapshot doc : docs) {
                                hasRequests = true;
                                String bgGroup = doc.getString("blood_group");
                                String hCity = doc.getString("hospital_city");
                                String urgency = doc.getString("urgency");
                                String rStatus = doc.getString("status");
                                
                                String cityOnly = hCity;
                                if(hCity != null && hCity.contains(",")) {
                                    String[] parts = hCity.split(",");
                                    if(parts.length > 1) cityOnly = parts[1].trim();
                                }
                    %>
                    <div class="card card-modern bg-dark border-secondary border-opacity-25 rounded-4">
                        <div class="card-body p-3 position-relative overflow-hidden">
                            <% if("COMPLETED".equalsIgnoreCase(rStatus)) { %>
                            <div class="position-absolute top-0 start-0 w-100 bg-success" style="height: 3px;"></div>
                            <% } else { %>
                            <div class="position-absolute top-0 start-0 w-100 bg-danger" style="height: 3px;"></div>
                            <% } %>
                            
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <div class="text-white-50"><i class="fa-solid fa-hospital-user fs-4"></i></div>
                                <span class="badge bg-danger rounded-pill px-3 fs-6"><%= bgGroup %></span>
                            </div>
                            <p class="text-light text-opacity-75 mb-1 small"><i class="fa-solid fa-location-dot me-1 text-white-50"></i> <%= cityOnly %></p>
                            <div class="d-flex align-items-center">
                                <% if("Emergency".equalsIgnoreCase(urgency)) { %>
                                <small class="text-danger fw-bold"><i class="fa-solid fa-circle-exclamation me-1"></i> Emergency</small>
                                <% } else { %>
                                <small class="text-primary fw-bold"><i class="fa-solid fa-circle-info me-1"></i> Normal</small>
                                <% } %>
                                <span class="badge badge-soft-warning ms-auto rounded-pill"><%= rStatus %></span>
                            </div>
                            
                        </div>
                    </div>
                    <%
                            }
                        } catch(Exception e) {}

                        if(!hasRequests) {
                    %>
                    <div class="card card-modern bg-transparent border-secondary border-opacity-10 border-dashed rounded-4 text-center p-4">
                        <i class="fa-solid fa-ghost fs-1 text-white-50 mb-2 opacity-25"></i>
                        <p class="text-white-50 small mb-0">No recent requests.</p>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.getElementById('requestForm').addEventListener('submit', function(e) {
        // Combine Hospital Name and City for the API
        const bankSelect = document.getElementById('bankId');
        const selectedOption = bankSelect.options[bankSelect.selectedIndex];
        const bankNameFull = selectedOption.text;
        document.getElementById('hospitalCityCombined').value = bankNameFull;
    });
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
