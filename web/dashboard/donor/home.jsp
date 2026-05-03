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
    <title>Donor Dashboard | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css?v=4" rel="stylesheet">
    <style>
        /* Hero ID Card Premium Styles */
        .id-card-wrapper { display: flex; justify-content: center; padding: 20px; }
        .id-card { width: 450px; height: 280px; background: linear-gradient(135deg, #1e1b4b 0%, #4c0519 100%); border-radius: 20px; position: relative; padding: 25px; box-shadow: 0 30px 60px rgba(0,0,0,0.5); overflow: hidden; border: 1px solid rgba(255,255,255,0.1); font-family: 'Outfit', sans-serif; }
        .id-card::before { content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%; background: radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%); pointer-events: none; }
        .id-card .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 30px; }
        .id-card .logo { color: white; font-weight: 800; font-size: 1.2rem; letter-spacing: 2px; }
        .id-card .chip { width: 40px; height: 30px; background: linear-gradient(135deg, #ffd700, #b8860b); border-radius: 6px; }
        .id-card .main { display: flex; gap: 20px; align-items: center; }
        .id-card .blood-seal { width: 70px; height: 70px; background: rgba(225,29,72,0.2); border: 2px solid #e11d48; border-radius: 50%; display: flex; justify-content: center; align-items: center; color: #e11d48; font-weight: 800; font-size: 1.5rem; text-shadow: 0 0 10px rgba(225,29,72,0.5); }
        .id-card .info-box { color: white; }
        .id-card .name { font-size: 1.4rem; font-weight: 700; text-transform: uppercase; margin: 0; line-height: 1.2; }
        .id-card .rank { font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 1.5px; margin-top: 4px; }
        .id-card .stats { display: flex; gap: 20px; margin-top: 25px; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 15px; }
        .id-card .stat-item { text-align: left; }
        .id-card .stat-val { color: white; font-weight: 700; font-size: 1rem; }
        .id-card .stat-lbl { color: rgba(255,255,255,0.5); font-size: 0.6rem; text-transform: uppercase; font-weight: 600; }
        .id-card .footer { position: absolute; bottom: 20px; right: 25px; color: rgba(255,255,255,0.3); font-size: 0.6rem; text-transform: uppercase; letter-spacing: 1px; }
    </style>
</head>
<body>
<div class="d-flex">
    <!-- SIDEBAR -->
    <% request.setAttribute("activePage", "my_history"); %>
    <jsp:include page="/WEB-INF/fragments/sidebar-donor.jspf" />

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1 text-white">Donor Dashboard</h2>
                <p class="text-light text-opacity-75">Track your life-saving contributions and manage upcoming appointments.</p>
            </div>
            <div class="d-flex gap-2">
                <button id="viewHeroID" class="btn btn-outline-info rounded-pill px-4 shadow-sm fw-bold">
                    <i class="fa-solid fa-id-card me-2"></i> Hero ID
                </button>
                <a href="<%= request.getContextPath() %>/BookAppointmentServlet" class="btn btn-danger rounded-pill px-4 shadow-sm fw-bold border-0" style="background-color: var(--primary-crimson);">
                    <i class="fa-solid fa-heart-pulse me-2"></i> Book Appointment
                </a>
            </div>
        </div>

        <%
            // 💡 OPTIMIZATION: Use session-cached values to save reads
            Integer completedCountObj = (Integer) session.getAttribute("donationCount");
            int completedCount = (completedCountObj != null) ? completedCountObj : 0;
            
            // If session is missing count (e.g. just donated), we fetch it or just use current
            // For now, trust session for standard loads.
            
            int impactScore = completedCount * 150;
            String heroRank = "Bronze Lifesaver";
            String rankColor = "#cd7f32";
            if(completedCount >= 10) { heroRank = "Platinum Guardian"; rankColor = "#e5e4e2"; }
            else if(completedCount >= 5) { heroRank = "Gold Defender"; rankColor = "#ffd700"; }
            else if(completedCount >= 3) { heroRank = "Silver Warden"; rankColor = "#c0c0c0"; }
        %>
        
        <!-- NEW 3 PANEL STATS -->
        <div class="row g-4 mb-5 fade-in-up">
            <!-- Total Donations -->
            <div class="col-md-4">
                <div class="card card-modern h-100 position-relative overflow-hidden">
                    <div class="card-body p-4 d-flex flex-column justify-content-center">
                        <div class="text-white-50 text-uppercase fw-bold mb-2" style="font-size:0.75rem; letter-spacing:1px">Total Donations</div>
                        <h1 class="fw-bold text-white mb-0" style="font-size: 3rem; position: relative; z-index: 2;"><%= completedCount %></h1>
                    </div>
                    <i class="fa-solid fa-heart-pulse position-absolute" style="color: var(--primary-crimson); font-size: 8rem; right: -1.5rem; bottom: -1.5rem; opacity: 0.8; z-index: 1;"></i>
                </div>
            </div>
            <!-- Impact Score -->
            <div class="col-md-4">
                <div class="card card-modern h-100 position-relative overflow-hidden">
                    <div class="card-body p-4 d-flex flex-column justify-content-center">
                        <div class="text-white-50 text-uppercase fw-bold mb-2" style="font-size:0.75rem; letter-spacing:1px">Impact Score</div>
                        <h1 class="fw-bold text-white mb-0" style="font-size: 3rem; position: relative; z-index: 2;"><%= impactScore %> <span class="fs-5 text-white-50">Pts</span></h1>
                    </div>
                    <i class="fa-solid fa-bolt position-absolute text-white" style="font-size: 8rem; right: 0.5rem; top: 0.5rem; opacity: 0.9; z-index: 1;"></i>
                </div>
            </div>
            <!-- Current Rank -->
            <div class="col-md-4">
                <div class="card card-modern h-100 position-relative overflow-hidden" style="border-right: 4px solid <%= rankColor %> !important">
                    <div class="card-body p-4 d-flex flex-column justify-content-center">
                        <div class="text-white-50 text-uppercase fw-bold mb-2" style="font-size:0.75rem; letter-spacing:1px">Current Rank</div>
                        <h3 class="fw-bold text-white mb-1" style="position: relative; z-index: 2;"><%= heroRank %></h3>
                        <a href="<%=request.getContextPath()%>/leaderboard.jsp" class="text-info text-decoration-none small" style="position: relative; z-index: 2;">Network Leaderboard &rarr;</a>
                    </div>
                    <i class="fa-solid fa-award position-absolute" style="font-size: 8rem; right: -1.5rem; top: -1.5rem; color: <%= rankColor %>; opacity: 0.7; z-index: 1;"></i>
                </div>
            </div>
        </div>

        <div class="card card-modern fade-in-up delay-100 mb-4">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4 text-warning"><i class="fa-solid fa-bell me-2 mt-1"></i> Critical Blood Demands Near You</h4>
                
                <div class="row g-3"><%
    boolean anyAlerts = false;
    String myBloodGroup = (String) session.getAttribute("bloodGroup");
    if (myBloodGroup == null) myBloodGroup = "Unknown";

    List<QueryDocumentSnapshot> apptDocs = new java.util.ArrayList<QueryDocumentSnapshot>();
    java.util.Map<String, String> bankNames = new java.util.HashMap<String, String>();

    try {
        Firestore db = FirebaseConfig.getFirestore();
        
        if (myBloodGroup != null && !myBloodGroup.isEmpty() && !"Unknown".equals(myBloodGroup)) {
            // 1. Fetch Active Emergency Alerts
            ApiFuture<QuerySnapshot> alertFuture = db.collection("emergency_alerts")
                    .whereEqualTo("blood_group", myBloodGroup)
                    .whereEqualTo("status", "ACTIVE").get();
            List<QueryDocumentSnapshot> alerts = new java.util.ArrayList<QueryDocumentSnapshot>(alertFuture.get().getDocuments());
            
            // 2. Fetch All Appointments for this donor
            ApiFuture<QuerySnapshot> apptHistFuture = db.collection("appointments")
                    .whereEqualTo("donor_id", userId).get();
            apptDocs = new java.util.ArrayList<QueryDocumentSnapshot>(apptHistFuture.get().getDocuments());

            // 💡 BATCH FETCH OPTIMIZATION: Collect all Bank IDs from alerts and appointments
            java.util.Set<String> bankIds = new java.util.HashSet<String>();
            for (QueryDocumentSnapshot alert : alerts) {
                String bId = alert.getString("bank_id");
                if (bId != null) bankIds.add(bId);
            }
            for (QueryDocumentSnapshot appt : apptDocs) {
                String bId = appt.getString("bank_id");
                if (bId != null) bankIds.add(bId);
            }

            if (!bankIds.isEmpty()) {
                java.util.List<DocumentReference> refs = new java.util.ArrayList<DocumentReference>();
                for (String id : bankIds) refs.add(db.collection("blood_banks").document(id));
                
                // One single batch read instead of N reads!
                List<DocumentSnapshot> bankDocs = db.getAll(refs.toArray(new DocumentReference[0])).get();
                for (DocumentSnapshot bDoc : bankDocs) {
                    if (bDoc.exists()) {
                        String name = bDoc.getString("bank_name");
                        if (name == null) name = bDoc.getString("full_name"); // Fallback for legacy
                        bankNames.put(bDoc.getId(), name != null ? name : "Unknown Facility");
                    }
                }
            }

            // Render Alerts
            java.util.Collections.sort(alerts, new java.util.Comparator<QueryDocumentSnapshot>() {
                public int compare(QueryDocumentSnapshot d1, QueryDocumentSnapshot d2) {
                    String t1 = d1.getString("created_at");
                    String t2 = d2.getString("created_at");
                    return (t2 != null ? t2 : "").compareTo(t1 != null ? t1 : "");
                }
            });

            for (QueryDocumentSnapshot alert : alerts) {
                anyAlerts = true;
                String bankId = alert.getString("bank_id");
                String msg = alert.getString("message");
                Double radius = alert.getDouble("radius_km");
                String time = alert.getString("created_at");
                String bName = bankNames.getOrDefault(bankId, "Local Facility");
%>
                    <div class="col-md-6">
                        <div class="p-3 border border-secondary border-opacity-25 rounded bg-dark shadow-sm position-relative overflow-hidden">
                            <div class="position-absolute top-0 start-0 w-100 bg-warning" style="height: 4px;"></div>
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold text-white mb-0"><i class="fa-solid fa-hospital-user text-danger me-1"></i> <%= bName %></h6>
                                <span class="badge bg-danger rounded-pill"><%= myBloodGroup %> Needed</span>
                            </div>
                            <p class="text-white-50 small mb-2"><i class="fa-solid fa-satellite-dish me-1"></i> <%= radius != null ? radius : 10.0 %>km Alert Radius</p>
                            <p class="mb-3 fw-medium text-white"><%= msg != null ? msg : "Urgent requirement dispatched." %></p>
                            <div class="d-flex justify-content-between align-items-center">
                                <small class="text-white-50"><i class="fa-regular fa-clock me-1"></i> <%= time %></small>
                                <a href="<%= request.getContextPath() %>/BookAppointmentServlet?prefillBankId=<%= bankId %>&alertId=<%= alert.getId() %>" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">
                                    Respond Now <i class="fa-solid fa-arrow-right ms-1"></i>
                                </a>
                            </div>
                        </div>
                    </div>
<%
            }
        }
    } catch (Exception e) {}
    
    if (!anyAlerts) {
%>
                    <div class="col-12 text-center py-4">
                        <div class="d-inline-flex bg-success bg-opacity-10 text-success p-3 rounded-circle mb-3 border border-success border-opacity-25">
                            <i class="fa-solid fa-check fs-2"></i>
                        </div>
                        <h6 class="text-white-50 fw-bold pb-2">No critical emergencies for <%= myBloodGroup != null ? myBloodGroup : "your blood type" %> in your area right now.</h6>
                    </div>
<%
    }
%>
                </div>
            </div>
        </div>

        <!-- COMMUNITY REQUESTS -->
        <div class="card card-modern fade-in-up delay-150 mb-4">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="fw-bold mb-0 text-white"><i class="fa-solid fa-hand-holding-medical text-danger me-2"></i> Community Blood Requests</h4>
                    <a href="<%=request.getContextPath()%>/dashboard/donor/requestBlood.jsp" class="btn btn-outline-danger rounded-pill px-4 shadow-sm border-2 fw-bold text-white">
                        Post a Request
                    </a>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Requester</th>
                            <th>Group</th>
                            <th>Hospital & City</th>
                            <th>Urgency</th>
                            <th>Status</th>
                            <th>Created</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Firestore dbP2p = FirebaseConfig.getFirestore();
                                java.util.List<QueryDocumentSnapshot> p2pDocs = dbP2p.collection("peer_requests")
                                    .orderBy("created_at", com.google.cloud.firestore.Query.Direction.DESCENDING)
                                    .limit(5).get().get().getDocuments();
                                boolean hasP2p = false;
                                for (QueryDocumentSnapshot doc : p2pDocs) {
                                    hasP2p = true;
                                    String rName = doc.getString("requester_name");
                                    String rBg = doc.getString("blood_group");
                                    String hCity = doc.getString("hospital_city");
                                    String urg = doc.getString("urgency");
                                    String stat = doc.getString("status");
                                    String cAt = doc.getString("created_at");
                                    String rOwnerId = doc.getString("donor_id");
                                    boolean isMine = (userId != null && userId.equals(rOwnerId));
                        %>
                                <tr>
                                    <td class="fw-bold text-white"><%= rName %></td>
                                    <td><span class="badge bg-danger rounded-pill px-2 fs-6"><%= rBg %></span></td>
                                    <td><div class="text-light text-opacity-75 small" style="max-width: 150px;"><%= hCity %></div></td>
                                    <td><span class="badge <%= "Emergency".equals(urg) ? "bg-danger" : "bg-primary" %> bg-opacity-10 text-<%= "Emergency".equals(urg) ? "danger" : "primary" %> border border-<%= "Emergency".equals(urg) ? "danger" : "primary" %> border-opacity-25 rounded-pill"><%= urg %></span></td>
                                    <td>
                                        <span class="badge <%= "COMPLETED".equalsIgnoreCase(stat) ? "bg-success" : "badge-soft-warning" %>"><%= stat %></span>
                                    </td>
                                    <td class="text-light text-opacity-75 small">
                                        <div class="d-flex align-items-center gap-2">
                                            <%= cAt %>
                                            <% if (!isMine && "PENDING".equalsIgnoreCase(stat) && rBg != null && rBg.equalsIgnoreCase(myBloodGroup)) { %>
                                                <%
                                                    // Try to find bankId if stored
                                                    String bId = doc.getString("bank_id");
                                                    if (bId != null && !bId.isEmpty()) {
                                                %>
                                                    <a href="<%= request.getContextPath() %>/BookAppointmentServlet?prefillBankId=<%= bId %>&requestId=<%= doc.getId() %>" class="btn btn-danger btn-sm rounded-pill px-3 fw-bold" style="font-size: 0.7rem;">
                                                        Respond
                                                    </a>
                                                <% } else { %>
                                                    <a href="<%= request.getContextPath() %>/BookAppointmentServlet?requestId=<%= doc.getId() %>" class="btn btn-danger btn-sm rounded-pill px-3 fw-bold" style="font-size: 0.7rem;">
                                                        Respond
                                                    </a>
                                                <% } %>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                        <%
                                }
                                if(!hasP2p) out.print("<tr><td colspan='6' class='text-center text-white-50 py-5 pt-5 pb-4'>No active community blood requests at this moment.</td></tr>");
                            } catch (Exception e) {}
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="card card-modern fade-in-up delay-200 mb-4">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4 text-white"><i class="fa-solid fa-clock-rotate-left text-danger me-2"></i> Donation History</h4>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                        <tr>
                            <th>Date & Time</th>
                            <th>Partnering Blood Bank</th>
                            <th>Status</th>
                            <th class="text-center">Recognition</th>
                        </tr>
                        </thead>
                        <tbody>
<%
    boolean any = false;
    try {
        // 💡 OPTIMIZATION: Using pre-fetched apptDocs and bankNames map
        // (apptDocs and bankNames were defined above in the Alerts section logic)
        
        // Sort appointments by time descending
        java.util.Collections.sort(apptDocs, new java.util.Comparator<QueryDocumentSnapshot>() {
            public int compare(QueryDocumentSnapshot d1, QueryDocumentSnapshot d2) {
                String t1 = d1.getString("appointment_time");
                String t2 = d2.getString("appointment_time");
                return (t2 != null ? t2 : "").compareTo(t1 != null ? t1 : "");
            }
        });
 
        for (QueryDocumentSnapshot doc : apptDocs) {
            any = true;
            String st = doc.getString("status");
            String apptTime = doc.getString("appointment_time");
            String bankId = doc.getString("bank_id");
            String appId = doc.getId();
            String bankName = bankNames.getOrDefault(bankId, "Unknown Bank");

            String badgeClass = "secondary";
            if ("COMPLETED".equalsIgnoreCase(st)) badgeClass = "badge-soft-success";
            else if ("CONFIRMED".equalsIgnoreCase(st)) badgeClass = "badge-soft-primary";
            else if ("PENDING".equalsIgnoreCase(st)) badgeClass = "badge-soft-warning";
            else if ("CANCELLED".equalsIgnoreCase(st)) badgeClass = "badge-soft-danger";
%>
                        <tr>
                            <td><div class="fw-bold text-white"><i class="fa-regular fa-calendar me-2 text-white-50"></i><%= apptTime != null ? apptTime : "" %></div></td>
                            <td class="text-light text-opacity-75"><i class="fa-solid fa-building-user me-1 border border-secondary border-opacity-25 p-1 rounded"></i> <%= bankName %></td>
                            <td><span class="badge <%= badgeClass %> px-3 rounded-pill fs-6"><%= st != null ? st : "" %></span></td>
                            <td class="text-center">
                                <% if ("COMPLETED".equalsIgnoreCase(st)) { %>
                                <a class="btn btn-sm btn-outline-danger rounded-pill fw-bold" href="<%= request.getContextPath() %>/certificate?appointmentId=<%= appId %>" target="_blank">
                                    <i class="fa-solid fa-award me-1"></i> Certificate
                                </a>
                                <% } else { %>
                                <span class="text-white-50" style="font-size: 0.8rem;"><i class="fa-solid fa-hourglass-empty me-1"></i> Pending Verification</span>
                                <% } %>
                            </td>
                        </tr>
<%
        }
        if (!any) { out.print("<tr><td colspan='4' class='text-center text-white-50 py-5 pt-5 pb-5'><i class='fa-solid fa-notes-medical fs-1 text-white-50 mb-3 opacity-50'></i><br>No donation appointments recorded on your profile yet.</td></tr>"); }
    } catch (Exception e) { out.print("<tr><td colspan='4' class='text-danger py-4'>Error loading appointments: " + e.getMessage() + "</td></tr>"); }
%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- HERO ID MODAL -->
<div class="modal fade" id="heroIdModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content card-modern border-0 bg-transparent" style="box-shadow: none;">
            <div class="modal-body p-0">
                <div id="heroIdContainer" class="id-card-wrapper">
                    <!-- Loaded via AJAX -->
                    <div class="text-center py-5">
                        <div class="spinner-border text-info" role="status"></div>
                        <p class="text-white mt-3">Syncing Hero Credentials...</p>
                    </div>
                </div>
                <div class="text-center mt-3">
                    <button type="button" class="btn btn-outline-light btn-sm rounded-pill px-4" data-bs-dismiss="modal">Close ID</button>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/chatWidget.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const idBtn = document.getElementById('viewHeroID');
        const idModal = new bootstrap.Modal(document.getElementById('heroIdModal'));
        const idContainer = document.getElementById('heroIdContainer');

        if (idBtn) {
            idBtn.addEventListener('click', function() {
                idModal.show();
                fetch('<%= request.getContextPath() %>/donor-id?ajax=true')
                    .then(response => response.text())
                    .then(html => {
                        idContainer.innerHTML = html;
                    })
                    .catch(error => {
                        idContainer.innerHTML = '<div class="text-danger p-4">Error loading ID card. Please try again.</div>';
                    });
            });
        }
    });
</script>
</body>
</html>
