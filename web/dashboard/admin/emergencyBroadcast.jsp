<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <title>Emergency Broadcast | Admin | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>
<body class="bg-dark text-white">
<% request.setAttribute("activePage", "emergency"); %>
<jsp:include page="/WEB-INF/fragments/admin-topnav.jspf" />

<div class="admin-view">
    <!-- MAIN CONTENT -->
    <div class="container-fluid px-4 px-md-5">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Emergency Operations Center</h2>
                <p class="text-white-50">Broadcast critical alerts instantly to registered donors within range.</p>
            </div>
        </div>
        
        <div class="card card-modern border-0 mb-4 fade-in-up delay-100">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                    <h4 class="fw-bold mb-0 text-danger"><i class="fa-solid fa-triangle-exclamation me-2"></i> Critical Low Stocks Action Required</h4>
                    <span class="badge badge-soft-danger fs-6 border border-danger">Safety Limit &lt; 5</span>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-modern align-middle mb-0 text-white">
                        <thead class="text-white-50 text-uppercase" style="font-size: 0.75rem; letter-spacing: 1px;">
                            <tr>
                                <th>Facility Details</th>
                                <th>City / Area</th>
                                <th>Crit. Blood Group</th>
                                <th>Current Stock Vol.</th>
                                <th class="text-end">Rapid Action</th>
                            </tr>
                        </thead>
                        <tbody>

                        <%
    boolean any = false;
    try {
        Firestore db = FirebaseConfig.getFirestore();
        
        // 1) Fetch Low Stock & Manual Alerts
        ApiFuture<QuerySnapshot> stockFuture = db.collection("blood_stock").whereLessThan("units", 5L).get();
        ApiFuture<QuerySnapshot> manualAlertsFuture = db.collection("emergency_alerts").whereEqualTo("status", "ACTIVE_MANUAL").get();
        
        List<QueryDocumentSnapshot> lowStockDocs = stockFuture.get().getDocuments();
        List<QueryDocumentSnapshot> manualAlertDocs = manualAlertsFuture.get().getDocuments();

        // 2) Collect all unique Bank IDs for batch fetching
        java.util.Set<String> bankIds = new java.util.HashSet<>();
        for (QueryDocumentSnapshot s : lowStockDocs) if (s.getString("blood_bank_id") != null) bankIds.add(s.getString("blood_bank_id"));
        for (QueryDocumentSnapshot a : manualAlertDocs) if (a.getString("bank_id") != null) bankIds.add(a.getString("bank_id"));

        java.util.Map<String, DocumentSnapshot> bankMap = new java.util.HashMap<>();
        if (!bankIds.isEmpty()) {
            java.util.List<DocumentReference> refs = new java.util.ArrayList<>();
            for (String id : bankIds) refs.add(db.collection("blood_banks").document(id));
            java.util.List<DocumentSnapshot> docs = db.getAll(refs.toArray(new DocumentReference[0])).get();
            for (DocumentSnapshot d : docs) if (d.exists()) bankMap.put(d.getId(), d);
        }

        // 3) Render Low Stock Items
        for (QueryDocumentSnapshot sDoc : lowStockDocs) {
            String bankId = sDoc.getString("blood_bank_id");
            DocumentSnapshot bankDoc = bankMap.get(bankId);
            if (bankDoc == null || !"APPROVED".equalsIgnoreCase(bankDoc.getString("status"))) continue;

            any = true;
            String bankName = bankDoc.getString("bank_name");
            String city = bankDoc.getString("city");
            String bloodGroup = sDoc.getString("blood_group");
            Long units = sDoc.getLong("units");
            long safetyStock = 5;
%>
                            <tr>
                                <td>
                                    <div class="fw-bold text-white"><%= bankName != null ? bankName : "Unknown Bank" %></div>
                                    <div class="text-light text-opacity-75 small"><i class="fa-solid fa-boxes-stacked me-1"></i> Auto System Trigger</div>
                                </td>
                                <td class="text-light text-opacity-75"><i class="fa-solid fa-location-dot me-1 text-danger"></i> <%= city != null ? city : "N/A" %></td>
                                <td>
                                    <span class="badge bg-danger rounded-pill px-3 fs-6 shadow-sm"><i class="fa-solid fa-droplet me-1"></i> <%= bloodGroup %></span>
                                </td>
                                <td>
                                    <h5 class="fw-bold mb-0 text-white">
                                        <%= units != null ? units : 0 %> <span class="text-white-50 fs-6 fw-normal">/ <%= safetyStock %> Required</span>
                                    </h5>
                                </td>
                                <td class="text-end">
                                    <div class="d-flex justify-content-end gap-2">
                                        <button class="btn btn-outline-info btn-sm rounded-pill px-3 ai-helper-btn"
                                                title="AI Intelligence Suggestion"
                                                data-bank-name="<%= bankName != null ? bankName.replace("\"", "&quot;") : "" %>"
                                                data-blood-group="<%= bloodGroup != null ? bloodGroup : "" %>"
                                                data-current-stock="<%= units != null ? units : 0 %>">
                                            <i class="fa-solid fa-wand-magic-sparkles"></i>
                                        </button>
                                        <button class="btn btn-premium btn-sm rounded-pill px-4 fw-bold shadow-sm dispatch-btn"
                                                data-bank-id="<%= bankId %>"
                                                data-bank-name="<%= bankName != null ? bankName.replace("\"", "&quot;") : "" %>"
                                                data-blood-group="<%= bloodGroup != null ? bloodGroup : "" %>">
                                            <i class="fa-solid fa-podcast me-1"></i> Dispatch Request
                                        </button>
                                    </div>
                                </td>
                            </tr>
<%
        }

        // 4) Render Manual Alerts
        for (QueryDocumentSnapshot aDoc : manualAlertDocs) {
            String bankId = aDoc.getString("bank_id");
            DocumentSnapshot bankDoc = bankMap.get(bankId);
            if (bankDoc == null || !"APPROVED".equalsIgnoreCase(bankDoc.getString("status"))) continue;

            any = true;
            String bankName = bankDoc.getString("bank_name");
            String city = bankDoc.getString("city");
            String bloodGroup = aDoc.getString("blood_group");
            String msg = aDoc.getString("message");
%>
                            <tr>
                                <td>
                                    <div class="fw-bold text-white"><%= bankName != null ? bankName : "Unknown Bank" %></div>
                                    <div class="text-danger small fw-bold"><i class="fa-solid fa-triangle-exclamation me-1"></i> Manual Override</div>
                                </td>
                                <td class="text-light text-opacity-75"><i class="fa-solid fa-location-dot me-1 text-danger"></i> <%= city != null ? city : "N/A" %></td>
                                <td>
                                    <span class="badge bg-danger rounded-pill px-3 fs-6 shadow-sm"><i class="fa-solid fa-droplet me-1"></i> <%= bloodGroup %></span>
                                </td>
                                <td>
                                    <span class="small text-white-50"><em>"<%= msg != null ? msg : "Urgent request." %>"</em></span>
                                </td>
                                <td class="text-end">
                                    <div class="d-flex justify-content-end gap-2">
                                        <button class="btn btn-outline-info btn-sm rounded-pill px-3 ai-helper-btn"
                                                title="AI Intelligence Suggestion"
                                                data-bank-name="<%= bankName != null ? bankName.replace("\"", "&quot;") : "" %>"
                                                data-blood-group="<%= bloodGroup != null ? bloodGroup : "" %>"
                                                data-current-stock="5">
                                            <i class="fa-solid fa-wand-magic-sparkles"></i>
                                        </button>
                                        <button class="btn btn-outline-danger btn-sm rounded-pill px-4 fw-bold dispatch-btn"
                                                data-bank-id="<%= bankId %>"
                                                data-bank-name="<%= bankName != null ? bankName.replace("\"", "&quot;") : "" %>"
                                                data-blood-group="<%= bloodGroup != null ? bloodGroup : "" %>">
                                            <i class="fa-solid fa-podcast me-1"></i> Push Again
                                        </button>
                                    </div>
                                </td>
                            </tr>
<%
        }
    } catch (Exception e) {
        out.print("<tr><td colspan='5' class='text-danger text-center py-5'><strong>Error loading critical data:</strong> " + e.getMessage() + "</td></tr>");
    }

    if (!any) {
%>
                            <tr>
                                <td colspan="5" class="text-center text-white-50 py-5">
                                    <i class="fa-solid fa-shield-heart fs-1 text-success mb-3 opacity-50"></i>
                                    <h5 class="fw-bold">All Supplies Stable</h5>
                                    <p class="mb-0">No blood groups are reporting levels beneath the safety stock threshold.</p>
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

<!-- AI Suggestion Modal -->
<div class="modal fade" id="aiAssistantModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content bg-dark border-secondary shadow-lg" style="border: 1px solid rgba(13, 202, 240, 0.3) !important;">
            <div class="modal-header border-secondary border-opacity-25">
                <h5 class="modal-title text-info fw-bold"><i class="fa-solid fa-wand-magic-sparkles me-2"></i> LifeFlow AI Dispatch Assistant</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div id="aiLoader" class="text-center py-4">
                    <div class="spinner-grow text-info mb-3"></div>
                    <p class="text-white-50">Synapsing with donor density grid...</p>
                </div>
                <div id="aiContent" class="d-none">
                    <div class="mb-4">
                        <label class="text-white-50 small text-uppercase fw-bold mb-2" style="letter-spacing: 1px;">Suggested Radius</label>
                        <div class="input-group">
                            <input type="number" id="aiRadius" class="form-control bg-dark text-white border-secondary" style="border-radius: 10px 0 0 10px;">
                            <span class="input-group-text bg-secondary bg-opacity-25 text-white border-secondary" style="border-radius: 0 10px 10px 0;">KM</span>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="text-white-50 small text-uppercase fw-bold mb-2" style="letter-spacing: 1px;">Suggested Message</label>
                        <textarea id="aiMessage" class="form-control bg-dark text-white border-secondary" rows="3" style="border-radius: 10px;"></textarea>
                    </div>
                    <div class="p-3 bg-info bg-opacity-10 border border-info border-opacity-25 rounded-3 mb-4">
                        <h6 class="text-info fw-bold small mb-1"><i class="fa-solid fa-brain me-2"></i> AI Rationale:</h6>
                        <p id="aiRationale" class="small text-white text-opacity-75 mb-0"></p>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-secondary border-opacity-25">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                <button type="button" id="applyAiBtn" class="btn btn-info text-dark fw-bold rounded-pill px-4">Apply Suggestions</button>
            </div>
        </div>
    </div>
</div>

<!-- Toast Notification (was referenced in JS but never existed in HTML) -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 9999;">
    <div id="dispatchToast" class="toast align-items-center border-0 text-white bg-success" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex">
            <div class="toast-body fw-bold" id="toastMessage">
                Dispatch successful!
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
(function() {
    console.log('📡 Dispatch System: Optimized for Single-Click Action');

    function showToast(message, isSuccess) {
        const toastEl = document.getElementById('dispatchToast');
        const msgEl = document.getElementById('toastMessage');
        if (!toastEl || !msgEl) return;
        
        msgEl.textContent = message;
        toastEl.className = 'toast align-items-center border-0 text-white ' + (isSuccess ? 'bg-success' : 'bg-danger');
        
        try {
            const toast = new bootstrap.Toast(toastEl);
            toast.show();
        } catch (e) {
            console.error('Toast Error:', e);
        }
    }

    document.body.addEventListener('click', function(event) {
        const btn = event.target.closest('.dispatch-btn');
        if (!btn || btn.disabled) return;

        event.preventDefault();
        console.log('⚡ Single-Click Dispatch Initiated:', btn.getAttribute('data-bank-name'));

        const bankId = btn.getAttribute('data-bank-id');
        const bloodGroup = btn.getAttribute('data-blood-group');
        const customRadius = btn.getAttribute('data-radius') || '100';
        const customMessage = btn.getAttribute('data-message') || '';

        const originalHtml = btn.innerHTML;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Dispatching...';
        btn.disabled = true;

        const formData = new URLSearchParams();
        formData.append('bankId', bankId);
        formData.append('bloodGroup', bloodGroup);
        formData.append('radiusKm', customRadius);
        formData.append('message', customMessage);

        fetch('<%= request.getContextPath() %>/api/emergency-broadcast', {
            method: 'POST',
            body: formData,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        })
        .then(function(response) {
            return response.json().then(function(data) {
                if (response.ok) {
                    showToast('🚀 Dispatch Success: ' + (data.message || 'Queued'), true);
                } else {
                    showToast('❌ Dispatch Failed: ' + (data.error || 'Unknown error'), false);
                }
            });
        })
        .catch(function(err) {
            showToast('❌ Network error: Could not reach dispatch server.', false);
            console.error('Fetch Error:', err);
        })
        .finally(function() {
            setTimeout(() => {
                btn.innerHTML = originalHtml;
                btn.disabled = false;
            }, 1500);
        });
    });

    // --- AI ASSISTANT LOGIC ---
    let activeDispatchBtn = null;
    const aiModal = new bootstrap.Modal(document.getElementById('aiAssistantModal'));

    document.body.addEventListener('click', function(event) {
        const btn = event.target.closest('.ai-helper-btn');
        if (!btn) return;

        activeDispatchBtn = btn.closest('tr').querySelector('.dispatch-btn');
        
        const bankName = btn.getAttribute('data-bank-name');
        const bloodGroup = btn.getAttribute('data-blood-group');
        const currentStock = btn.getAttribute('data-current-stock');

        // Reset and show modal
        document.getElementById('aiLoader').classList.remove('d-none');
        document.getElementById('aiContent').classList.add('d-none');
        aiModal.show();

        const params = new URLSearchParams({
            bankName: bankName,
            bloodGroup: bloodGroup,
            currentStock: currentStock
        });

        fetch('<%= request.getContextPath() %>/api/ai-dispatch-helper?' + params.toString())
            .then(res => res.json())
            .then(data => {
                document.getElementById('aiRadius').value = data.suggestedRadius;
                document.getElementById('aiMessage').value = data.suggestedMessage;
                document.getElementById('aiRationale').textContent = data.rationale;

                document.getElementById('aiLoader').classList.add('d-none');
                document.getElementById('aiContent').classList.remove('d-none');
            })
            .catch(err => {
                console.error('AI Suggestion Error:', err);
                aiModal.hide();
                showToast('❌ Failed to reach LifeFlow AI Assistant.', false);
            });
    });

    document.getElementById('applyAiBtn').addEventListener('click', function() {
        if (!activeDispatchBtn) return;
        
        // Update the active dispatch button's data attributes
        activeDispatchBtn.setAttribute('data-radius', document.getElementById('aiRadius').value);
        activeDispatchBtn.setAttribute('data-message', document.getElementById('aiMessage').value);
        
        aiModal.hide();
        showToast('✨ AI suggestions applied. Ready to dispatch.', true);
        
        // Visual cue that suggestions are active
        activeDispatchBtn.classList.remove('btn-premium');
        activeDispatchBtn.classList.add('btn-info', 'text-dark');
        activeDispatchBtn.innerHTML = '<i class="fa-solid fa-bolt-lightning me-1"></i> AI Optimized Dispatch';
    });

    // Override dispatch logic to use AI parameters if present
    const originalFetch = window.fetch;
    // We modify the dispatch listener instead of overriding fetch globally
})();
</script>
</body>
</html>
