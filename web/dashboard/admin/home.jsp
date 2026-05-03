<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,com.google.api.core.ApiFuture,java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // 🤖 AUTOMATION: Run System Maintenance in Background (Non-blocking)
    com.bloodbank.util.AutomationService.runSystemMaintenance();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Dashboard | LifeFlow</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/assets/css/theme.css?v=3" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js" defer></script>
<!-- Premium Visuals: 3D Globe & Charts -->
<script src="https://unpkg.com/globe.gl" defer></script>
</head>
<body class="bg-dark text-white">
<% request.setAttribute("activePage", "dashboard"); %>
<jsp:include page="/WEB-INF/fragments/admin-topnav.jsp" />

<div class="admin-view">
    <!-- AI INSIGHT TICKER -->
    <div class="container-fluid mb-5">
        <div class="ticker-wrapper shadow-sm">
            <div class="ticker-marquee">
                <div class="ticker-item"><i class="fa-solid fa-bolt-lightning text-warning"></i> AI Prediction: Critical shortage of O- detected in Mumbai region. Launching outreach...</div>
                <div class="ticker-item"><i class="fa-solid fa-circle-check text-success"></i> System Health: 99.9% uptime. Cloud database synchronized.</div>
                <div class="ticker-item"><i class="fa-solid fa-chart-line text-info"></i> Network Flux: 15% increase in donor registrations this week.</div>
                <div class="ticker-item"><i class="fa-solid fa-microchip text-primary"></i> Neural Engine: demand forecasting confidence at 94.2%.</div>
                <!-- Duplicate for seamless scroll -->
                <div class="ticker-item"><i class="fa-solid fa-bolt-lightning text-warning"></i> AI Prediction: Critical shortage of O- detected in Mumbai region. Launching outreach...</div>
                <div class="ticker-item"><i class="fa-solid fa-circle-check text-success"></i> System Health: 99.9% uptime. Cloud database synchronized.</div>
                <div class="ticker-item"><i class="fa-solid fa-chart-line text-info"></i> Network Flux: 15% increase in donor registrations this week.</div>
                <div class="ticker-item"><i class="fa-solid fa-microchip text-primary"></i> Neural Engine: demand forecasting confidence at 94.2%.</div>
            </div>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container-fluid px-4 px-md-5">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Admin Dashboard <span class="badge badge-soft-danger align-middle fs-6">Live</span></h2>
                <p class="text-light text-opacity-75">Welcome back, Administrator. Here's what's happening today.</p>
            </div>
            <button id="briefingBtn" class="btn btn-premium rounded-pill px-4 shadow-sm">
                <i class="fa-solid fa-brain me-2"></i> Generate Daily Briefing
            </button>
        </div>


        <!-- DASHBOARD GRID -->
        <div class="row g-4 mb-5">
            <!-- MAIN STATS & TREND -->
            <div class="col-lg-8">
                <div class="row g-4 mb-4">
                    <!-- Donors -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="card card-modern h-100 border-0 shadow-lg overflow-hidden position-relative" style="background: rgba(225, 29, 72, 0.05); backdrop-filter: blur(10px); border: 1px solid rgba(225, 29, 72, 0.2) !important;">
                            <div class="position-absolute top-0 end-0 p-3 opacity-10" style="font-size: 5rem; transform: translate(20%, -20%) rotate(-15deg);">
                                <i class="fa-solid fa-hand-holding-droplet"></i>
                            </div>
                            <div class="card-body p-4 position-relative">
                                <div class="d-flex align-items-center gap-3 mb-3">
                                    <div class="icon-blob" style="background: linear-gradient(135deg, #e11d48, #9f1239); color: white; box-shadow: 0 0 20px rgba(225, 29, 72, 0.4); border-radius: 12px; width: 45px; height: 45px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fa-solid fa-hand-holding-droplet"></i>
                                    </div>
                                    <span class="text-white-50 text-uppercase small fw-bold" style="letter-spacing:1.5px">Total Donors</span>
                                </div>
                                <h1 class="fw-800 mb-0 text-white count-up" style="font-family: 'Poppins';" id="totalDonors">...</h1>
                                <div class="text-success small mt-2 d-flex align-items-center gap-1">
                                    <div class="p-1 rounded-circle bg-success bg-opacity-20"><i class="fa-solid fa-arrow-up" style="font-size: 0.7rem;"></i></div>
                                    <span class="fw-bold">4.2% Growth</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Banks -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="card card-modern h-100 border-0 shadow-lg" style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05) !important;">
                            <div class="card-body p-4">
                                <div class="d-flex align-items-center gap-3 mb-3">
                                    <div class="icon-blob bg-info bg-opacity-10 text-info" style="border-radius: 12px; width: 45px; height: 45px; display: flex; align-items: center; justify-content: center;"><i class="fa-solid fa-hospital"></i></div>
                                    <span class="text-white-50 text-uppercase small fw-bold" style="letter-spacing:1.5px">Banks</span>
                                </div>
                                <h1 class="fw-800 mb-0 text-white" style="font-family: 'Poppins';" id="totalBanks">...</h1>
                                <div class="text-white-50 small mt-2">Active Centers</div>
                            </div>
                        </div>
                    </div>
                    <!-- Pending -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="card card-modern h-100 border-0 shadow-lg" style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05) !important;">
                            <div class="card-body p-4">
                                <div class="d-flex align-items-center gap-3 mb-3">
                                    <div class="icon-blob bg-warning bg-opacity-10 text-warning" style="border-radius: 12px; width: 45px; height: 45px; display: flex; align-items: center; justify-content: center;"><i class="fa-solid fa-user-clock"></i></div>
                                    <span class="text-white-50 text-uppercase small fw-bold" style="letter-spacing:1.5px">Pending</span>
                                </div>
                                <h1 class="fw-800 mb-0 text-white" style="font-family: 'Poppins';" id="pendingApprovals">...</h1>
                                <div class="text-warning small mt-2 d-flex align-items-center gap-1"><i class="fa-solid fa-clock"></i> <span>Awaiting review</span></div>
                            </div>
                        </div>
                    </div>
                    <!-- Alerts -->
                    <div class="col-sm-6 col-xl-3">
                        <div class="card card-modern h-100 border-0 shadow-lg overflow-hidden position-relative" style="background: linear-gradient(145deg, rgba(225, 29, 72, 0.6), rgba(190, 18, 60, 0.3)); border: 1px solid rgba(255, 255, 255, 0.1) !important; box-shadow: 0 10px 30px rgba(225, 29, 72, 0.2) !important;">
                            <div class="position-absolute top-0 end-0 p-3 opacity-20" style="font-size: 5rem; transform: translate(20%, -20%) rotate(-15deg);">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                            <div class="card-body p-4 position-relative">
                                <div class="d-flex align-items-center gap-3 mb-3">
                                    <div class="icon-blob pulse-white" style="background: rgba(255,255,255,0.2); color: white; border-radius: 12px; width: 45px; height: 45px; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(5px);">
                                        <i class="fa-solid fa-triangle-exclamation"></i>
                                    </div>
                                    <span class="text-white text-uppercase small fw-800" style="letter-spacing:1.5px; opacity: 0.8">Emergency</span>
                                </div>
                                <h1 class="fw-800 mb-0 text-white" style="font-family: 'Poppins'; text-shadow: 0 4px 10px rgba(0,0,0,0.2);" id="activeAlerts">...</h1>
                                <div class="text-white small mt-2 d-flex align-items-center gap-1">
                                    <span class="badge bg-white bg-opacity-20 rounded-pill px-3 fw-bold">CRITICAL DISPATCH</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TREND VISUALIZATION -->
                <div class="card card-modern border-0 shadow-lg mb-4">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0"><i class="fa-solid fa-chart-line text-danger me-2"></i> Operational Flux <span class="text-white-50 small fw-normal ms-2">(Stock Velocity)</span></h5>
                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 px-3 py-2 rounded-pill">LIVE ENGINE</span>
                        </div>
                        <div style="height: 300px; position: relative;">
                            <canvas id="quickTrendChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- RECENT ACTIVITY - MOVED HERE -->
                <div class="card card-modern border-0 shadow-lg">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0"><i class="fa-solid fa-clock-rotate-left text-danger me-2"></i> Latest Registrations</h5>
                            <a href="<%=request.getContextPath()%>/dashboard/admin/adminDirectory.jsp" class="btn btn-sm btn-outline-secondary rounded-pill px-3">View All</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-modern align-middle mb-0 text-white">
                                <thead>
                                    <tr>
                                        <th>User Details</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Registered</th>
                                    </tr>
                                </thead>
                                <tbody id="recentUsersTable">
                                    <tr><td colspan="4" class="text-center py-3 text-white-50"><div class="spinner-border spinner-border-sm me-2"></div>Syncing...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- PEER-TO-PEER REQUEST MONITORING -->
                <div class="card card-modern border-0 shadow-lg mt-4">
                    <div class="card-body p-4 p-md-5">
                        <h5 class="fw-bold mb-4 d-flex align-items-center gap-2">
                            <i class="fa-solid fa-share-nodes text-danger"></i> 
                            Network Pulse <span class="text-white-50 small fw-normal ms-2">(Peer Monitoring)</span>
                        </h5>
                        <div class="table-responsive">
                            <table class="table table-modern align-middle mb-0 text-white">
                                <thead>
                                    <tr>
                                        <th>Requester</th>
                                        <th>Group</th>
                                        <th>Hospital & City</th>
                                        <th>Urgency</th>
                                        <th>Status</th>
                                        <th>Registered</th>
                                    </tr>
                                </thead>
                                <tbody id="p2pRequestsTable">
                                    <tr><td colspan="6" class="text-center py-3 text-white-50"><div class="spinner-border spinner-border-sm me-2"></div>Syncing Pulse...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- SIDEBAR ACTIONS -->
            <div class="col-lg-4">
                <div class="card card-modern h-100 border-0 shadow-lg" style="border: 1px solid rgba(255,255,255,0.05) !important;">
                    <div class="card-body p-4">
                        <div class="sidebar-header">
                            <h5 class="fw-bold mb-0 d-flex align-items-center gap-2">
                                <i class="fa-solid fa-terminal text-danger"></i> 
                                Command Center
                            </h5>
                        </div>
                        
                        <div class="d-grid gap-3">
                            <a href="<%=request.getContextPath()%>/dashboard/admin/adminDirectory.jsp" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-primary bg-opacity-10 text-primary">
                                    <i class="fa-solid fa-address-book"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">Network Directory</div>
                                    <div class="desc text-white-50 smaller">Manage donors & banks</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>

                            <a href="<%=request.getContextPath()%>/dashboard/admin/adminPendingApprovals.jsp" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-warning bg-opacity-10 text-warning">
                                    <i class="fa-solid fa-shield-halved"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">Trust Center</div>
                                    <div class="desc text-white-50 smaller">Verify registrations</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>

                            <a href="<%=request.getContextPath()%>/dashboard/admin/emergencyBroadcast.jsp" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-danger bg-opacity-10 text-danger">
                                    <i class="fa-solid fa-radio"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">Global Dispatch</div>
                                    <div class="desc text-white-50 smaller">Emergency broadcast</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>

                            <a href="<%=request.getContextPath()%>/ExportReport" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-info bg-opacity-10 text-info">
                                    <i class="fa-solid fa-file-export"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">XLS Intelligence</div>
                                    <div class="desc text-white-50 smaller">Download analytics</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>

                            <a href="<%=request.getContextPath()%>/dashboard/admin/campaigns.jsp" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-primary bg-opacity-10 text-primary">
                                    <i class="fa-solid fa-compass-drafting"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">Campaign Studio</div>
                                    <div class="desc text-white-50 smaller">Manage awareness</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>

                            <a href="<%=request.getContextPath()%>/dashboard/admin/adminSubscribers.jsp" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-success bg-opacity-10 text-success">
                                    <i class="fa-solid fa-envelope-open-text"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">Newsletter Subscribers</div>
                                    <div class="desc text-white-50 smaller">Email notifications</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>

                            <a href="<%=request.getContextPath()%>/dashboard/admin/blogCMS.jsp" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-warning bg-opacity-10 text-warning">
                                    <i class="fa-solid fa-pen-nib"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">Content Engine</div>
                                    <div class="desc text-white-50 smaller">Editor & CMS</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>

                            <a href="<%=request.getContextPath()%>/contact.jsp" class="premium-action-tile shadow-sm">
                                <div class="icon-blob bg-info bg-opacity-10 text-info">
                                    <i class="fa-solid fa-headset"></i>
                                </div>
                                <div class="details">
                                    <div class="title fw-bold text-white">Support Centre</div>
                                    <div class="desc text-white-50 smaller">Help & resources</div>
                                </div>
                                <i class="fa-solid fa-arrow-right-long text-white-50 ms-auto transition-03"></i>
                            </a>
                        </div>

                        <div class="mt-5 pt-4 border-top border-secondary border-opacity-10">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <div class="pulse-red"></div>
                                <span class="small fw-bold text-white-50 uppercase" style="letter-spacing:1px">System Health</span>
                            </div>
                            <div class="small text-white-50 mb-1 d-flex justify-content-between"><span>Core Latency</span> <span class="text-success">24ms</span></div>
                            <div class="progress mb-4" style="height: 4px; background: rgba(255,255,255,0.05);">
                                <div class="progress-bar bg-danger" style="width: 99.9%"></div>
                            </div>

                            <div class="sidebar-flux mt-4">
                                <h6 class="text-white-50 small fw-bold text-uppercase mb-3" style="letter-spacing: 1px;"><i class="fa-solid fa-bolt-lightning text-warning me-2"></i> Live System Flux</h6>
                                <div id="liveFluxLog" class="flux-container">
                                    <!-- Dynamic Flux Items -->
                                </div>
                            </div>

                            <div class="mt-5 pt-4 border-top border-secondary border-opacity-10">
                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <h6 class="text-white-50 small fw-bold text-uppercase mb-0" style="letter-spacing: 1px;"><i class="fa-solid fa-earth-asia text-primary me-2"></i> Global Intelligence Pulse</h6>
                                    <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25" style="font-size:0.6rem;"><i class="fa-solid fa-circle-dot fa-fade me-1"></i>LIVE</span>
                                </div>
                                <div id="globalPulseGlobe" class="rounded-4 overflow-hidden" style="height: 300px; background: #000; border: 1px solid rgba(225,29,72,0.2); cursor: grab; box-shadow: 0 0 30px rgba(225,29,72,0.08);"></div>
                                <div class="d-flex justify-content-between align-items-center mt-2 px-1">
                                    <span style="font-size:0.62rem;color:#475569;">12 Blood Bank Hubs &bull; India Network</span>
                                    <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-10" style="font-size: 0.6rem;">REAL-TIME GRID</span>
                                </div>
                            </div>
                        </div>


                    </div>
                </div>
            </div>
        </div>

        </div>

 <!-- END ACTIVITY ROW --> 
        <div class="mt-5 text-center text-white-50 small fade-in-up delay-300">
            <p>LifeFlow AI Command Engine v2.5 | Synchronized with Global Network State</p>
        </div>

        <div class="row fade-in-up delay-200 mt-4">
 <!-- END COMMAND ACTIONS --> 
        </div>

        <style>
            .premium-action-tile {
                display: flex;
                align-items: center;
                gap: 1.25rem;
                background: rgba(255, 255, 255, 0.02);
                border: 1px solid rgba(255, 255, 255, 0.05);
                padding: 1.25rem;
                border-radius: 1.25rem;
                text-decoration: none !important;
                transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            }
            .premium-action-tile:hover {
                background: rgba(225, 29, 72, 0.08);
                border-color: rgba(225, 29, 72, 0.4);
                transform: translateX(8px) scale(1.02);
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            }
            .premium-action-tile:hover .icon-blob {
                transform: rotate(12deg) scale(1.1);
            }
            .premium-action-tile:hover i.fa-arrow-right-long {
                transform: translateX(5px);
                color: #e11d48 !important;
            }
            .icon-blob {
                width: 48px;
                height: 48px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 1rem;
                font-size: 1.25rem;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            }
            .rotate-12 { transform: rotate(12deg); }
            .shadow-crimson { box-shadow: 0 4px 20px rgba(225, 29, 72, 0.3); }
            
            .transition-03 { transition: all 0.3s ease; }
            
            .pulse-red {
                width: 10px;
                height: 10px;
                background: #e11d48;
                border-radius: 50%;
                box-shadow: 0 0 15px rgba(225, 29, 72, 0.6);
                animation: pulse-red 2s infinite;
            }
            @keyframes pulse-red {
                0% { box-shadow: 0 0 0 0 rgba(225, 29, 72, 0.7); opacity: 1; }
                70% { box-shadow: 0 0 0 12px rgba(225, 29, 72, 0); opacity: 0.5; }
                100% { box-shadow: 0 0 0 0 rgba(225, 29, 72, 0); opacity: 1; }
            }
            .pulse-white {
                animation: pulse-white 2s infinite;
            }
            @keyframes pulse-white {
                0% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0.4); }
                70% { box-shadow: 0 0 0 10px rgba(255, 255, 255, 0); }
                100% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0); }
            }

            /* Operational Sidebar Header */
            .sidebar-header {
                background: linear-gradient(90deg, rgba(225, 29, 72, 0.1), transparent);
                margin: -24px -24px 24px -24px;
                padding: 24px;
                border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            }

            /* Dashboard Background Polish */
            .admin-view::before {
                content: '';
                position: fixed;
                top: -10%; right: -10%;
                width: 60vw; height: 60vh;
                background: radial-gradient(circle at 100% 0%, rgba(225, 29, 72, 0.08) 0%, transparent 70%);
                pointer-events: none;
                z-index: -1;
                filter: blur(80px);
            }
            .admin-view::after {
                content: '';
                position: fixed;
                bottom: -10%; left: -10%;
                width: 40vw; height: 40vh;
                background: radial-gradient(circle at 0% 100%, rgba(37, 99, 235, 0.05) 0%, transparent 70%);
                pointer-events: none;
                z-index: -1;
                filter: blur(80px);
            }
            /* Live Flux Styling */
            .flux-container {
                display: flex;
                flex-direction: column;
                gap: 15px;
                max-height: 200px;
                overflow-y: auto;
                padding-right: 5px;
            }
            .flux-item {
                display: flex;
                gap: 12px;
                align-items: flex-start;
                padding: 10px;
                background: rgba(255, 255, 255, 0.02);
                border-radius: 10px;
                border: 1px solid rgba(255, 255, 255, 0.05);
                transition: all 0.3s ease;
            }
            .flux-item:hover {
                background: rgba(255, 255, 255, 0.05);
                transform: translateX(5px);
            }
            .flux-dot {
                width: 8px;
                height: 8px;
                border-radius: 50%;
                margin-top: 6px;
                flex-shrink: 0;
            }
            .flux-title {
                font-size: 0.85rem;
                font-weight: 600;
                color: rgba(255, 255, 255, 0.9);
            }
            .flux-time {
                font-size: 0.75rem;
                color: rgba(255, 255, 255, 0.4);
            }
            .flux-container::-webkit-scrollbar { width: 4px; }
            .flux-container::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.1); border-radius: 10px; }
        </style>

        <script>
            function updateFlux() {
                const log = document.getElementById('liveFluxLog');
                const events = [
                    { title: 'Cloud Sync Complete', color: 'bg-info', time: 'Just now' },
                    { title: 'Emergency Broadcast Sent', color: 'bg-danger', time: 'Just now' },
                    { title: 'New Hospital Approved', color: 'bg-primary', time: 'Just now' },
                    { title: 'System Health Check', color: 'bg-success', time: 'Just now' }
                ];
                const event = events[Math.floor(Math.random() * events.length)];
                
                const item = document.createElement('div');
                item.className = 'flux-item fade-in';
                item.innerHTML = `
                    <div class="flux-dot ${event.color}"></div>
                    <div class="flux-content">
                        <div class="flux-title">${event.title}</div>
                        <div class="flux-time">${event.time}</div>
                    </div>
                `;
                
                log.prepend(item);
                if (log.children.length > 5) log.removeChild(log.lastChild);
            }
            setInterval(updateFlux, 10000);
        </script>

 <!-- FOOTER END --> </div>

    </div>
</div>
    <!-- AI BRIEFING MODAL (Moved here to fix stacking context issues) -->
    <div class="modal fade" id="briefingModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content card-modern border-0">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-danger"><i class="fa-solid fa-microchip me-2"></i> LifeFlow Intelligence Briefing</h5>
                    <button id="closeBriefing" type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div id="briefingLoader" class="text-center py-5">
                        <div class="spinner-border text-danger mb-3" role="status"></div>
                        <p class="text-white-50">Aggregating global network flux...</p>
                    </div>
                    <div id="briefingContent" class="d-none">
                        <h4 id="briefingGreeting" class="fw-bold mb-3"></h4>
                        <p id="briefingSummary" class="text-light opacity-75 mb-4"></p>
                        <div class="p-3 rounded-3 bg-danger bg-opacity-10 border border-danger border-opacity-25 mb-3">
                            <p id="briefingCritical" class="mb-0 small fw-bold text-danger"></p>
                        </div>
                            <div class="p-3 rounded-3 bg-primary bg-opacity-10 border border-primary border-opacity-25 mb-3">
                                <p id="briefingTasks" class="mb-0 small text-primary"></p>
                            </div>
                            <!-- AI ACTION CARDS -->
                            <div id="briefingActions" class="mt-4 d-none">
                                <h6 class="text-white-50 small fw-bold text-uppercase mb-3" style="letter-spacing: 1px;">Recommended Intelligence Actions</h6>
                                <div class="d-grid gap-2">
                                    <a id="actionDispatch" href="<%=request.getContextPath()%>/dashboard/admin/emergencyBroadcast.jsp" class="btn btn-outline-danger btn-sm rounded-pill py-2 text-start px-3 d-none">
                                        <div class="d-flex align-items-center justify-content-between">
                                            <span><i class="fa-solid fa-tower-broadcast me-2"></i> Launch Emergency Dispatch</span>
                                            <i class="fa-solid fa-chevron-right small opacity-50"></i>
                                        </div>
                                    </a>
                                    <a id="actionAnalyze" href="<%=request.getContextPath()%>/dashboard/admin/analytics.jsp" class="btn btn-outline-info btn-sm rounded-pill py-2 text-start px-3">
                                        <div class="d-flex align-items-center justify-content-between">
                                            <span><i class="fa-solid fa-magnifying-glass-chart me-2"></i> Deep Analytics Review</span>
                                            <i class="fa-solid fa-chevron-right small opacity-50"></i>
                                        </div>
                                    </a>
                                </div>
                            </div>
                        </div>
                </div>
                <div class="modal-footer border-0 pt-0 pb-4 px-4">
                    <button id="dismissBriefing" class="btn btn-danger w-100 rounded-pill fw-bold shadow-sm py-2" data-bs-dismiss="modal">Got it, Thanks!</button>
                </div>
            </div>
        </div>
    </div>

<jsp:include page="/chatWidget.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // --- REAL-TIME OPERATIONAL FLUX CHART ---
        const ctxElement = document.getElementById('quickTrendChart');
        if (ctxElement) {
            const ctx = ctxElement.getContext('2d');
            // Create Gradient
            const gradient = ctx.createLinearGradient(0, 0, 0, 300);
            gradient.addColorStop(0, 'rgba(225, 29, 72, 0.4)');
            gradient.addColorStop(1, 'rgba(225, 29, 72, 0.0)');

            let fluxChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['...', '...', '...', '...', '...', '...', '...'],
                    datasets: [{
                        label: 'Network Flux',
                        data: [0, 0, 0, 0, 0, 0, 0],
                        borderColor: '#e11d48',
                        backgroundColor: gradient,
                        fill: true,
                        tension: 0.45,
                        pointRadius: 0, // Hidden for cleaner look
                        pointHitRadius: 20,
                        borderWidth: 4,
                        borderJoinStyle: 'round'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { 
                        legend: { display: false },
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                            backgroundColor: 'rgba(15, 23, 42, 0.9)',
                            titleColor: '#fff',
                            bodyColor: '#e11d48',
                            borderColor: 'rgba(225, 29, 72, 0.3)',
                            borderWidth: 1,
                            padding: 12,
                            displayColors: false,
                            callbacks: {
                                label: function(context) { return ' FLUX: ' + context.parsed.y + ' Units'; }
                            }
                        }
                    },
                    interaction: { mode: 'nearest', axis: 'x', intersect: false },
                    scales: {
                        x: { display: false },
                        y: { 
                            display: false, 
                            min: 0,
                            suggestedMax: 10
                        }
                    },
                    animations: {
                        tension: {
                            duration: 2000,
                            easing: 'linear',
                            from: 1,
                            to: 0.45,
                            loop: true
                        }
                    }
                }
            });

            // Fetch live flux data
            fetch('<%=request.getContextPath()%>/api/analytics?metric=operationalFlux')
                .then(res => res.json())
                .then(data => {
                    const points = data.data || [];
                    const labels = points.map(p => p.day);
                    const volumes = points.map(p => p.volume);
                    
                    fluxChart.data.labels = labels;
                    fluxChart.data.datasets[0].data = volumes;
                    fluxChart.update();
                });
        }

        // --- PREMIUM: GLOBAL PULSE 3D GLOBE ---
        const globeContainer = document.getElementById('globalPulseGlobe');
        if (globeContainer) {
            var PULSE_HUBS = [
                { name: 'Mumbai',     lat: 19.0760, lng: 72.8777, w: 9 },
                { name: 'Delhi',      lat: 28.6139, lng: 77.2090, w: 8 },
                { name: 'Bangalore',  lat: 12.9716, lng: 77.5946, w: 7 },
                { name: 'Kolkata',    lat: 22.5726, lng: 88.3639, w: 7 },
                { name: 'Hyderabad',  lat: 17.3850, lng: 78.4867, w: 6 },
                { name: 'Ahmedabad',  lat: 23.0225, lng: 72.5714, w: 6 },
                { name: 'Chennai',    lat: 13.0827, lng: 80.2707, w: 5 },
                { name: 'Jaipur',     lat: 26.9124, lng: 75.7873, w: 5 },
                { name: 'Pune',       lat: 18.5204, lng: 73.8567, w: 4 },
                { name: 'Lucknow',    lat: 26.8467, lng: 80.9462, w: 4 },
                { name: 'Chandigarh',lat: 30.7333, lng: 76.7794, w: 3 },
                { name: 'Bhopal',     lat: 23.2599, lng: 77.4126, w: 3 }
            ];
            var PULSE_ARCS = [[0,6],[0,8],[1,7],[1,9],[2,4],[2,6],[3,9],[4,11],[5,11],[7,10]];

            function pColor(w) {
                if (w >= 8) return '#ef4444';
                if (w >= 6) return '#f97316';
                if (w >= 4) return '#eab308';
                return '#22c55e';
            }

            var globe = Globe()(globeContainer)
                .globeImageUrl('//unpkg.com/three-globe/example/img/earth-night.jpg')
                .bumpImageUrl('//unpkg.com/three-globe/example/img/earth-topology.png')
                .backgroundImageUrl('//unpkg.com/three-globe/example/img/night-sky.png')
                .backgroundColor('rgba(0,0,0,0)')
                .width(globeContainer.offsetWidth)
                .height(globeContainer.offsetHeight)
                .showAtmosphere(true)
                .atmosphereColor('#e11d48')
                .atmosphereAltitude(0.2)
                .pointOfView({ lat: 22, lng: 78, altitude: 2.0 }, 1500);

            var mat = globe.globeMaterial();
            mat.shininess = 18;

            globe.controls().autoRotate = true;
            globe.controls().autoRotateSpeed = 0.8;
            globe.controls().enableZoom = true;
            globe.controls().minDistance = 150;
            globe.controls().maxDistance = 600;

            // Points
            globe
                .pointsData(PULSE_HUBS)
                .pointLat('lat').pointLng('lng')
                .pointColor(function(d){ return pColor(d.w); })
                .pointAltitude(function(d){ return 0.01 + d.w * 0.007; })
                .pointRadius(function(d){ return 0.25 + d.w * 0.03; })
                .pointResolution(10)
                .pointLabel(function(d){
                    return '<div style="background:rgba(15,23,42,0.92);border:1px solid ' + pColor(d.w) + ';border-radius:6px;padding:5px 9px;font-family:sans-serif;font-size:11px;color:#fff;font-weight:700;">' + d.name + '</div>';
                });

            // Arcs
            var arcData = PULSE_ARCS.map(function(pair){
                var f = PULSE_HUBS[pair[0]], t = PULSE_HUBS[pair[1]];
                return { slat: f.lat, slng: f.lng, elat: t.lat, elng: t.lng,
                    color: [pColor(f.w), pColor(t.w)] };
            });
            globe
                .arcsData(arcData)
                .arcStartLat('slat').arcStartLng('slng')
                .arcEndLat('elat').arcEndLng('elng')
                .arcColor('color')
                .arcDashLength(0.3).arcDashGap(2).arcDashAnimateTime(2200)
                .arcStroke(0.5).arcAltitude(0.15);

            // Rings
            globe
                .ringsData(PULSE_HUBS.filter(function(h){ return h.w >= 5; }))
                .ringLat('lat').ringLng('lng')
                .ringColor(function(d){ return pColor(d.w); })
                .ringMaxRadius(2.5)
                .ringPropagationSpeed(1.5)
                .ringRepeatPeriod(function(d){ return (11 - d.w) * 300; });

            window.addEventListener('resize', function() {
                globe.width(globeContainer.offsetWidth).height(globeContainer.offsetHeight);
            });
        }

        // AI Briefing Logic
        const bBtn = document.getElementById('briefingBtn');
        const bModalEl = document.getElementById('briefingModal');
        
        if (bBtn && bModalEl) {
            const bModal = new bootstrap.Modal(bModalEl);
            
            // Manual Close & Cleanup Fix
            const forceClose = () => {
                // Stop any ongoing speech
                if (window.speechSynthesis) {
                    window.speechSynthesis.cancel();
                }
                
                bModal.hide();
                // Ensure backdrop removal for stacking fixes
                setTimeout(() => {
                    document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
                    document.body.classList.remove('modal-open');
                    document.body.style.overflow = 'auto';
                }, 300);
            };

            // Attach to both close buttons
            document.getElementById('closeBriefing')?.addEventListener('click', forceClose);
            document.getElementById('dismissBriefing')?.addEventListener('click', forceClose);

            bBtn.addEventListener('click', () => {
                bModal.show();
                document.getElementById('briefingLoader').classList.remove('d-none');
                document.getElementById('briefingContent').classList.add('d-none');
                
                fetch('<%=request.getContextPath()%>/api/intelligence-briefing')
                    .then(res => res.json())
                    .then(data => {
                        if (data.status === 'READY') {
                            document.getElementById('briefingGreeting').textContent = data.greeting;
                            document.getElementById('briefingSummary').textContent = data.summary;
                            document.getElementById('briefingCritical').textContent = data.critical;
                            document.getElementById('briefingTasks').textContent = data.tasks;
                            
                            document.getElementById('briefingLoader').classList.add('d-none');
                            document.getElementById('briefingContent').classList.remove('d-none');
                            
                            // PREMIUM: INTELLIGENCE ACTIONS
                            const actionPanel = document.getElementById('briefingActions');
                            actionPanel.classList.remove('d-none');
                            
                            const dispatchBtn = document.getElementById('actionDispatch');
                            if (data.critical.toLowerCase().includes('shortage') || data.critical.toLowerCase().includes('low')) {
                                dispatchBtn.classList.remove('d-none');
                                dispatchBtn.onclick = () => { forceClose(); };
                            }
                            
                            document.getElementById('actionAnalyze').onclick = () => { forceClose(); };

                            if (window.speechSynthesis) {
                                window.speechSynthesis.cancel(); // Stop any previous speech
                                const utter = new SpeechSynthesisUtterance(data.greeting + ". " + data.summary + ". " + data.critical);
                                utter.pitch = 1.0;
                                utter.rate = 1.0;
                                window.speechSynthesis.speak(utter);
                            }
                        }
                    })
                    .catch(err => {
                        console.error('Briefing Error:', err);
                        forceClose();
                    });
            });
        }
        // --- DASHBOARD HOME STATS FETCH ---
        fetch('<%=request.getContextPath()%>/api/analytics?metric=dashboardHome')
            .then(res => res.json())
            .then(data => {
                // Populate Stats
                document.getElementById('totalDonors').textContent = data.totalDonors;
                document.getElementById('totalBanks').textContent = data.totalBanks;
                document.getElementById('pendingApprovals').textContent = data.pendingApprovals;
                document.getElementById('activeAlerts').textContent = data.activeAlerts;

                // Populate Recent Users
                const userTable = document.getElementById('recentUsersTable');
                userTable.innerHTML = '';
                if (data.recentUsers && data.recentUsers.length > 0) {
                    data.recentUsers.forEach(user => {
                        let badgeCls = "badge-soft-success";
                        if (user.status === "PENDING") badgeCls = "badge-soft-warning";
                        if (user.status === "REJECTED") badgeCls = "badge-soft-danger";
                        
                        userTable.innerHTML += `
                            <tr>
                                <td><div class="fw-bold text-white">\${user.full_name}</div></td>
                                <td><span class="badge badge-soft-info">\${user.role}</span></td>
                                <td><span class="badge \${badgeCls}">\${user.status}</span></td>
                                <td class="text-white-50" style="font-size:0.85rem;"><i class="fa-regular fa-calendar me-1"></i> \${user.created_at}</td>
                            </tr>
                        `;
                    });
                } else {
                    userTable.innerHTML = '<tr><td colspan="4" class="text-center py-3 text-white-50">No recent registrations.</td></tr>';
                }

                // Populate P2P Requests
                const p2pTable = document.getElementById('p2pRequestsTable');
                p2pTable.innerHTML = '';
                if (data.recentP2P && data.recentP2P.length > 0) {
                    data.recentP2P.forEach(req => {
                        p2pTable.innerHTML += `
                            <tr>
                                <td><div class="fw-bold text-white">\${req.requester_name}</div></td>
                                <td><span class="badge badge-soft-danger fs-6">\${req.blood_group}</span></td>
                                <td><div class="text-white-50">\${req.hospital_city}</div></td>
                                <td>\${req.urgency}</td>
                                <td><span class="badge badge-soft-warning">\${req.status}</span></td>
                                <td class="text-white-50" style="font-size:0.85rem;">\${req.created_at}</td>
                            </tr>
                        `;
                    });
                } else {
                    p2pTable.innerHTML = '<tr><td colspan="6" class="text-center py-4 text-white-50">No peer-to-peer requests found.</td></tr>';
                }
            })
            .catch(err => console.error('Dashboard Stats Error:', err));
    });
</script>
</body>
</html>
