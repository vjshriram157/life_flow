<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List,java.util.Map,java.util.HashMap" %>
<%
    String userId = (String) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null || role == null || !"BANK".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bank Dashboard | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>
<body>
<div class="d-flex">
    <!-- SIDEBAR -->
    <% request.setAttribute("activePage", "home"); %>
    <jsp:include page="/WEB-INF/fragments/sidebar-bank.jspf" />

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Facility Operations</h2>
                <p class="text-white-50">Process incoming donor appointments and accurately track completed donations.</p>
            </div>
            <button class="btn btn-outline-secondary rounded-pill px-4" onclick="window.location.reload()"><i class="fa-solid fa-rotate-right me-2"></i>Refresh Queue</button>
        </div>

        <!-- ACTIVE EMERGENCY ALERTS -->
        <div class="card card-modern border-0 fade-in-up delay-100 mb-4">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-tower-broadcast text-danger me-2"></i> Active Emergency Broadcasts</h4>
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                            <tr>
                                <th>Requested Blood Group</th>
                                <th>Broadcast Radius</th>
                                <th>Broadcast Time</th>
                                <th>Message</th>
                            </tr>
                        </thead>
                        <tbody>
<%
Firestore db = null;
String alertBankId = null;
boolean hasAlerts = false;
try {
    db = FirebaseConfig.getFirestore();
    DocumentSnapshot userDoc = db.collection("users").document(userId).get().get();

    if (userDoc.exists() && userDoc.getString("email") != null) {
        String userEmail = userDoc.getString("email");
        ApiFuture<QuerySnapshot> futureBank = db.collection("blood_banks").whereEqualTo("email", userEmail).get();
        List<QueryDocumentSnapshot> bankDocs = futureBank.get().getDocuments();
        if (!bankDocs.isEmpty()) {
            alertBankId = bankDocs.get(0).getId();
        }
    }

    if (alertBankId != null) {
        ApiFuture<QuerySnapshot> alertFuture = db.collection("emergency_alerts").whereEqualTo("bank_id", alertBankId).get();
        List<QueryDocumentSnapshot> alertDocs = new java.util.ArrayList<QueryDocumentSnapshot>(alertFuture.get().getDocuments());
        
        // Sort alerts by time descending
        java.util.Collections.sort(alertDocs, new java.util.Comparator<QueryDocumentSnapshot>() {
            public int compare(QueryDocumentSnapshot d1, QueryDocumentSnapshot d2) {
                String t1 = d1.getString("created_at");
                String t2 = d2.getString("created_at");
                if (t1 == null) return 1;
                if (t2 == null) return -1;
                return t2.compareTo(t1);
            }
        });

        for (QueryDocumentSnapshot alert : alertDocs) {
            hasAlerts = true;
            String bg = alert.getString("blood_group");
            Double rad = alert.getDouble("radius_km");
            String msg = alert.getString("message");
            String createdAt = alert.getString("created_at");
%>
                            <tr>
                                <td><span class="badge bg-danger rounded-pill px-3 fs-6 flex-shrink-0"><i class="fa-solid fa-droplet me-1"></i> <%= bg %></span></td>
                                <td class="text-white-50"><i class="fa-solid fa-satellite-dish me-1"></i> <%= rad != null ? rad : 10.0 %> km radius</td>
                                <td class="text-white-50"><i class="fa-regular fa-clock me-1"></i> <%= createdAt != null ? createdAt : "Just now" %></td>
                                <td><span class="text-white"><%= msg != null ? msg : "Urgent blood request" %></span></td>
                            </tr>
<%
        }
    }
    if (!hasAlerts) {
%>
                            <tr>
                                <td colspan="4" class="text-center text-white-50 py-4">
                                    <i class="fa-solid fa-check-circle fs-3 text-success mb-2 opacity-50"></i><br>
                                    No active emergency broadcasts for this facility.
                                </td>
                            </tr>
<%
    }
} catch (Exception e) {
%>
                            <tr><td colspan="4" class="text-danger py-4">Error loading alerts: <%= e.getMessage() %></td></tr>
<%
}
%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <!-- LIVE INVENTORY MONITOR -->
            <div class="col-lg-8">
                <div class="card card-modern border-0 h-100 fade-in-up delay-200">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h4 class="fw-bold mb-0"><i class="fa-solid fa-boxes-stacked text-danger me-2"></i> Live Inventory Management</h4>
                            <span class="badge border border-secondary border-opacity-25 text-white-50 rounded-pill px-3 py-2">Auto-sync with Admin</span>
                        </div>
                        
                        <div class="row g-3">
                            <% 
                                String[] groups = {"A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"};
                                Map<String, Long> stocks = new HashMap<>();
                                if (alertBankId != null) {
                                    ApiFuture<QuerySnapshot> stockFuture = db.collection("blood_stock").whereEqualTo("blood_bank_id", alertBankId).get();
                                    for (QueryDocumentSnapshot sDoc : stockFuture.get().getDocuments()) {
                                        stocks.put(sDoc.getString("blood_group"), sDoc.getLong("units"));
                                    }
                                }
                                for (String g : groups) {
                                    long units = stocks.getOrDefault(g, 0L);
                                    String statusClass = units < 5 ? "text-danger fw-bold" : "text-success";
                            %>
                            <div class="col-md-3 col-6">
                                <div class="p-3 border border-secondary border-opacity-25 rounded-4 text-center bg-dark h-100">
                                    <div class="small text-white-50 text-uppercase fw-bold mb-1"><%= g %></div>
                                    <div class="fs-4 <%= statusClass %> mb-2"><%= units %> <small class="fs-6">Units</small></div>
                                    <button class="btn btn-sm btn-outline-danger rounded-pill w-100" data-bs-toggle="modal" data-bs-target="#updateStock<%= g.replace("+","Plus").replace("-","Minus") %>">
                                        Update
                                    </button>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <p class="text-white-50 small mt-4 mb-0"><i class="fa-solid fa-circle-info me-1"></i> Tip: Setting any stock below 5 units will automatically alert the Admin for emergency dispatch.</p>
                    </div>
                </div>
            </div>

            <!-- EMERGENCY PANIC BUTTON -->
            <div class="col-lg-4">
                <div class="card card-modern border-0 h-100 bg-danger text-white fade-in-up delay-300">
                    <div class="card-body p-4 p-md-5 d-flex flex-column justify-content-center text-center">
                        <i class="fa-solid fa-triangle-exclamation fs-1 mb-4"></i>
                        <h4 class="fw-bold mb-2">Emergency Override</h4>
                        <p class="opacity-75 mb-4 small">Manually request a priority broadcast to regional donors regardless of stock levels.</p>
                        <div class="position-relative d-inline-block">
                            <div class="position-absolute inset-0 bg-danger rounded-pill blur-sm opacity-25 pulse-glow" style="z-index: -1;"></div>
                            <button class="btn btn-danger rounded-pill px-5 py-3 fw-bold shadow-lg border-0 transition-premium" data-bs-toggle="modal" data-bs-target="#manualEmergencyModal" style="background: linear-gradient(135deg, #e11d48 0%, #9f1239 100%); letter-spacing: 1.5px; font-size: 0.9rem;">
                                <i class="fa-solid fa-tower-broadcast me-2 heartbeat-slow"></i>TRANSMIT OVERRIDE
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card card-modern border-0 fade-in-up delay-200 mb-4">
            <div class="card-body p-4 p-md-5">
                <h4 class="fw-bold mb-4"><i class="fa-solid fa-clipboard-list text-danger me-2"></i> Daily Appointments Queue</h4>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                            <tr>
                                <th>Booking ID</th>
                                <th>Donor Overview</th>
                                <th>Blood Group</th>
                                <th>Scheduled Time</th>
                                <th class="text-end">Fulfillment Action</th>
                            </tr>
                        </thead>
                        <tbody>

<%
boolean any = false;

try {
    // First, get the user's email
    DocumentSnapshot userDoc = db.collection("users").document(userId).get().get();
    String bankId = null;

    if (userDoc.exists() && userDoc.getString("email") != null) {
        String userEmail = userDoc.getString("email");
        ApiFuture<QuerySnapshot> futureBank = db.collection("blood_banks").whereEqualTo("email", userEmail).get();
        List<QueryDocumentSnapshot> bankDocs = futureBank.get().getDocuments();
        if (!bankDocs.isEmpty()) {
            bankId = bankDocs.get(0).getId();
        }
    }

    if (bankId == null) {
%>
                            <tr>
                                <td colspan="5" class="text-center text-white-50 py-5 text-danger">
                                    <i class="fa-solid fa-circle-exclamation fs-1 mb-3"></i><br>
                                    Bank profile not found or linked. Please contact the administrator.
                                </td>
                            </tr>
<%
    } else {
        ApiFuture<QuerySnapshot> apptFuture = db.collection("appointments").whereEqualTo("bank_id", bankId).get();
        List<QueryDocumentSnapshot> apptDocs = new java.util.ArrayList<QueryDocumentSnapshot>(apptFuture.get().getDocuments());

        // Sort by status descending (PENDING first usually in alphabetical sort, actually PENDING vs COMPLETED -> P is after C. But let's just sort by time for simplicity, or we can just sort in memory)
        java.util.Collections.sort(apptDocs, new java.util.Comparator<QueryDocumentSnapshot>() {
            public int compare(QueryDocumentSnapshot d1, QueryDocumentSnapshot d2) {
                String t1 = d1.getString("appointment_time");
                String t2 = d2.getString("appointment_time");
                if (t1 == null) return 1;
                if (t2 == null) return -1;
                return t2.compareTo(t1); // Descending order — newest first
            }
        });

        for (QueryDocumentSnapshot apptDoc : apptDocs) {
            any = true;
            String st = apptDoc.getString("status");
            String donorIdStr = apptDoc.getString("donor_id");
            String apptId = apptDoc.getId();
            String apptTime = apptDoc.getString("appointment_time");

            String donorName = "Unknown Donor";
            String donorPhone = "N/A";
            String bloodGroup = "N/A";

            if (donorIdStr != null) {
                DocumentSnapshot dDoc = db.collection("users").document(donorIdStr).get().get();
                if (dDoc.exists()) {
                    donorName = dDoc.getString("full_name") != null ? dDoc.getString("full_name") : "Unknown Donor";
                    donorPhone = dDoc.getString("phone") != null ? dDoc.getString("phone") : "N/A";
                    bloodGroup = dDoc.getString("blood_group") != null ? dDoc.getString("blood_group") : "N/A";
                }
            }
%>
                            <tr>
                                <td><span class="text-white-50 fw-bold">#<%= apptId.substring(0, Math.min(8, apptId.length())) %></span></td>
                                <td>
                                    <div class="fw-bold text-white"><i class="fa-solid fa-user text-white-50 me-1"></i> <%= donorName %></div>
                                    <div class="text-white-50" style="font-size: 0.85rem;"><i class="fa-solid fa-phone me-1"></i> <%= donorPhone %></div>
                                </td>
                                <td>
                                    <span class="badge badge-soft-danger px-3 shadow-sm" style="font-size: 0.9rem;">
                                        <%= bloodGroup %>
                                    </span>
                                </td>
                                <td class="text-white-50 fw-bold"><i class="fa-regular fa-clock me-1"></i> <%= apptTime != null ? apptTime : "" %></td>
                                <td class="text-end">
                                    <% if ("PENDING".equals(st)) { %>
                                    <form action="<%= request.getContextPath() %>/CompleteAppointmentServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="appointmentId" value="<%= apptId %>">
                                        <button type="submit" class="btn btn-premium btn-sm rounded-pill px-3 shadow-sm">
                                            <i class="fa-solid fa-check me-1"></i> Mark Donated
                                        </button>
                                    </form>
                                    <% } else { %>
                                        <span class="badge bg-success rounded-pill px-3 fs-6"><i class="fa-solid fa-check-double me-1"></i> Completed</span>
                                    <% } %>
                                </td>
                            </tr>
<%
        }
        if (!any) {
%>
                            <tr>
                                <td colspan="5" class="text-center text-white-50 py-5">
                                    <i class="fa-solid fa-calendar-xmark fs-1 text-light mb-3"></i><br>
                                    No incoming appointments found for this facility.
                                </td>
                            </tr>
<%
        }
    }
} catch (Exception e) {
%>
                            <tr>
                                <td colspan="5" class="text-danger py-4 text-center">
                                    <strong>Database Error:</strong> <%= e.getMessage() %>
                                </td>
                            </tr>
<%
}
%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODALS AREA -->
<%
    for (String g : groups) {
        long units = stocks.getOrDefault(g, 0L);
%>
<div class="modal fade" id="updateStock<%= g.replace("+","Plus").replace("-","Minus") %>" tabindex="-1">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 shadow" style="border-radius: 1rem;">
            <form action="<%= request.getContextPath() %>/UpdateStockServlet" method="post">
                <div class="modal-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="fw-bold mb-0">Update <%= g %> Stock</h6>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close" style="font-size: 0.75rem;"></button>
                    </div>
                    <input type="hidden" name="action" value="update_inventory">
                    <input type="hidden" name="bloodGroup" value="<%= g %>">
                    <label class="small text-white-50 mb-1">New Unit Count</label>
                    <input type="number" name="units" class="form-control bg-dark text-white border-secondary rounded-pill mb-3" value="<%= units %>" required min="0">
                    <div class="d-grid">
                        <button type="submit" class="btn btn-danger rounded-pill">Save Changes</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<div class="modal fade" id="manualEmergencyModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark text-white border border-secondary border-opacity-25 shadow-lg" style="border-radius: 1.5rem;">
            <form action="<%= request.getContextPath() %>/UpdateStockServlet" method="post">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold">Manual Emergency Request</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <input type="hidden" name="action" value="manual_emergency">
                    <div class="mb-4">
                        <label class="small text-white-50 text-uppercase fw-bold mb-3 d-block" style="letter-spacing: 1px;">Target Blood Group</label>
                        <div class="row g-2">
                            <% for(String g : groups) { %> 
                            <div class="col-3">
                                <input type="radio" class="btn-check" name="bloodGroup" id="bg_<%= g.replace("+","Plus").replace("-","Minus") %>" value="<%= g %>" required <%= "A+".equals(g) ? "checked" : "" %>>
                                <label class="btn btn-outline-danger btn-sm w-100 rounded-pill py-2 border-opacity-25 shadow-sm fw-bold" for="bg_<%= g.replace("+","Plus").replace("-","Minus") %>">
                                    <%= g %>
                                </label>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="small text-white-50 text-uppercase fw-bold mb-2 d-block" style="letter-spacing: 1px;">Emergency Description</label>
                        <textarea name="message" class="form-control bg-dark text-white border-secondary rounded-4 shadow-sm" rows="3" placeholder="Describe the crisis... e.g., Urgent bypass surgery requirement." style="border-color: rgba(255,255,255,0.1) !important;"></textarea>
                    </div>
                    <p class="text-danger small"><i class="fa-solid fa-eye me-1"></i> This request will be flagged as HIGH PRIORITY in the Admin Emergency Center.</p>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-outline-secondary text-white rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4">Transmit Request</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/chatWidget.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
