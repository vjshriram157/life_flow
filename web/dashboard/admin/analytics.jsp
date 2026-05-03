<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
<title>Analytics Dashboard | LifeFlow</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>
<body class="bg-dark text-white">
<% request.setAttribute("activePage", "analytics"); %>
<jsp:include page="/WEB-INF/fragments/admin-topnav.jspf" />

<div class="admin-view">
    <!-- MAIN CONTENT -->
    <div class="container-fluid px-4 px-md-5">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Intelligence & Forecasting</h2>
                <p class="text-white-50">Real-time data visualization of donation volume and shortage heatmaps.</p>
            </div>
            <div>
                <button class="btn btn-outline-secondary rounded-pill px-4" onclick="window.location.href='?refresh=true'"><i class="fa-solid fa-rotate-right me-2"></i>Refresh Data</button>
            </div>
        </div>
        
        <div class="row g-4">
            <!-- Chart Section -->
            <div class="col-md-7 fade-in-up delay-100">
                <div class="card card-modern h-100">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0"><i class="fa-solid fa-chart-simple text-danger me-2"></i> Donation Trends by Volume</h5>
                        </div>
                        <div style="height: 450px; position: relative;">
                        <div id="donationChartContainer" style="height: 450px; position: relative;"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Heatmap Section -->
            <div class="col-md-5 fade-in-up delay-200">
                <div class="card card-modern h-100">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0"><i class="fa-solid fa-map-location-dot text-danger me-2"></i> Intelligence Map</h5>
                            <span class="badge badge-soft-danger"><i class="fa-solid fa-circle-dot fa-fade me-1"></i> Live</span>
                        </div>
                        <div id="map-container" style="height: 420px; width: 100%; position: relative;">
                            <div id="globe-3d" class="w-100 h-100" style="background: #000; border-radius: 10px; border: 1px solid rgba(255,255,255,0.05);"></div>
                            <!-- Legend -->
                            <div style="position:absolute;bottom:12px;left:12px;background:rgba(15,23,42,0.85);border:1px solid rgba(255,255,255,0.08);border-radius:8px;padding:8px 12px;font-size:0.68rem;font-family:'Poppins',sans-serif;z-index:10;">
                                <div style="color:#94a3b8;margin-bottom:4px;font-weight:600;letter-spacing:1px;">DEMAND URGENCY</div>
                                <div style="display:flex;flex-direction:column;gap:3px;">
                                    <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#ef4444;margin-right:6px;"></span><span style="color:#e2e8f0;">Critical (&ge;8)</span></span>
                                    <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#f97316;margin-right:6px;"></span><span style="color:#e2e8f0;">High (&ge;6)</span></span>
                                    <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#eab308;margin-right:6px;"></span><span style="color:#e2e8f0;">Moderate (&ge;4)</span></span>
                                    <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#22c55e;margin-right:6px;"></span><span style="color:#e2e8f0;">Normal</span></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- AI Forecast Section - Premium Upgrade -->
        <div class="row mt-4 mb-5 fade-in-up delay-300">
            <div class="col-12">
                <div class="card card-modern overflow-hidden" style="border: 1px solid rgba(139, 92, 246, 0.3); background: linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.8) 100%);">
                    <div class="card-body p-4 p-md-5 position-relative">
                        <!-- Intelligence Aura -->
                        <div style="position: absolute; top: -50px; right: -50px; width: 200px; height: 200px; background: radial-gradient(circle, rgba(139, 92, 246, 0.15) 0%, transparent 70%); z-index: 0;"></div>
                        
                        <div class="d-flex justify-content-between align-items-center mb-5 position-relative" style="z-index: 1;">
                            <div class="d-flex align-items-center gap-3">
                                <div class="bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center p-3" style="box-shadow: 0 0 20px rgba(139, 92, 246, 0.2);">
                                    <i class="fa-solid fa-microchip text-primary fs-4 fa-pulse"></i>
                                </div>
                                <div>
                                    <h5 class="fw-bold mb-1 text-white">Gemini Demand Forecaster <span class="badge bg-info bg-opacity-10 text-info border border-info border-opacity-25 ms-2 fs-6" style="font-size: 0.65rem !important;">Experimental AI</span></h5>
                                    <p class="text-white-50 small mb-0"><i class="fa-solid fa-bolt-lightning text-warning me-1"></i> Analyzing 30-day historical donor flux and hospital drain...</p>
                                </div>
                            </div>
                            <div class="text-end">
                                <div class="text-primary fw-bold" style="font-size: 0.8rem; letter-spacing: 1px;">CONFIDENCE: 94.2%</div>
                                <div class="d-flex gap-1 justify-content-end mt-1">
                                    <div class="bg-primary" style="width: 4px; height: 12px; border-radius: 2px;"></div>
                                    <div class="bg-primary" style="width: 4px; height: 12px; border-radius: 2px;"></div>
                                    <div class="bg-primary" style="width: 4px; height: 12px; border-radius: 2px;"></div>
                                    <div class="bg-primary" style="width: 4px; height: 12px; border-radius: 2px; opacity: 0.3;"></div>
                                </div>
                            </div>
                        </div>

                        <div class="table-responsive position-relative" style="z-index: 1;">
                            <table class="table table-modern table-borderless align-middle mb-0 bg-transparent" id="forecastTable">
                                <thead class="text-white-50 text-uppercase border-bottom border-secondary border-opacity-10" style="font-size: 0.7rem; letter-spacing: 1.5px;">
                                    <tr>
                                        <th class="pb-3">Facility Intelligence</th>
                                        <th class="pb-3 text-center">Group</th>
                                        <th class="pb-3">Supply Velocity</th>
                                        <th class="pb-3">Predicted Demand</th>
                                        <th class="pb-3 text-end">Risk Assessment</th>
                                    </tr>
                                </thead>
                                <tbody id="forecastBody">
                                    <tr><td colspan='5' class='text-center py-5'><div class="spinner-grow text-primary me-3" role="status"></div><span class="text-white-50 fs-5">Synapsing with LifeFlow Data Grid...</span></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet.heat/dist/leaflet-heat.js"></script>
<script src="https://unpkg.com/globe.gl"></script>
<script>
    // Fetch and render Donation Chart with ApexCharts
    const urlParams = new URLSearchParams(window.location.search);
    const refreshParam = urlParams.get('refresh') === 'true' ? '&refresh=true' : '';
    
    fetch('<%=request.getContextPath()%>/api/analytics?metric=donationsByMonth' + refreshParam)
        .then(res => res.json())
        .then(data => {
            const rawData = data.data || [];
            const labelsMap = {};
            const groupData = {};

            rawData.forEach(item => {
                const month = item.year + '-' + item.month.toString().padStart(2, '0');
                if(!labelsMap[month]) labelsMap[month] = true;
                if(!groupData[item.bloodGroup]) groupData[item.bloodGroup] = {};
                groupData[item.bloodGroup][month] = item.count;
            });

            const categories = Object.keys(labelsMap).sort();
            const series = Object.keys(groupData).map(group => ({
                name: group,
                data: categories.map(cat => groupData[group][cat] || 0)
            }));

            const options = {
                series: series,
                chart: { type: 'bar', height: 450, stacked: true, toolbar: { show: false }, background: 'transparent' },
                theme: { mode: 'dark' },
                colors: ['#ef4444', '#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#06b6d4', '#f43f5e', '#6366f1'],
                plotOptions: { bar: { borderRadius: 6, columnWidth: '45%' } },
                dataLabels: { enabled: false },
                grid: { borderColor: 'rgba(255,255,255,0.05)', strokeDashArray: 4 },
                xaxis: { categories: categories, axisBorder: { show: false }, axisTicks: { show: false } },
                yaxis: { title: { text: 'Units Donated', style: { color: '#64748b' } } },
                legend: { position: 'top', horizontalAlign: 'right' },
                fill: { opacity: 1 }
            };

            const chartContainer = document.querySelector("#donationChartContainer");
            const chart = new ApexCharts(chartContainer, options);
            chart.render();
        }).catch(err => console.error("Chart Error:", err));


    // Initialization will be handled at the bottom of the script

    // Fetch and render Forecast
    fetch('<%=request.getContextPath()%>/api/demand-prediction')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('forecastBody');
            if(data.error) {
                tbody.innerHTML = `<tr><td colspan="5" class="text-danger py-4"><i class="fa-solid fa-triangle-exclamation me-2"></i> Error: ${data.error}</td></tr>`;
                return;
            }
            const predictions = data.predictions || [];
            if(predictions.length === 0) {
                tbody.innerHTML = `<tr><td colspan="5" class="text-center text-white-50 py-5">Insufficient historical data to generate reliable forecasts.</td></tr>`;
                return;
            }
            
            // Sort by risk (highest deficit first)
            predictions.sort((a, b) => (b.forecastUnits - b.currentStock) - (a.forecastUnits - a.currentStock));
            
            let html = '';
            predictions.forEach(p => {
                const deficit = p.forecastUnits - p.currentStock;
                const riskLevel = deficit > 5 ? 'critical' : (deficit > 0 ? 'warning' : 'safe');
                const velocityPercent = Math.min(Math.max((p.currentStock / (p.forecastUnits || 1)) * 100, 5), 100);
                
                let riskHtml = '';
                let dotClass = '';
                
                if(riskLevel === 'critical') {
                    riskHtml = `<div class="d-flex align-items-center justify-content-end gap-2 text-danger fw-bold"><i class="fa-solid fa-triangle-exclamation fa-fade"></i> HIGH DEFICIT</div>`;
                    dotClass = 'bg-danger';
                } else if(riskLevel === 'warning') {
                    riskHtml = `<div class="d-flex align-items-center justify-content-end gap-2 text-warning fw-bold"><i class="fa-solid fa-circle-exclamation"></i> MARGINAL</div>`;
                    dotClass = 'bg-warning';
                } else {
                    riskHtml = `<div class="d-flex align-items-center justify-content-end gap-2 text-success fw-bold"><i class="fa-solid fa-circle-check"></i> NOMINAL</div>`;
                    dotClass = 'bg-success';
                }

                html += `<tr>
                    <td>
                        <div class="d-flex align-items-center gap-3">
                            <div class="\${dotClass} rounded-circle pulse-animation" style="width: 8px; height: 8px; box-shadow: 0 0 10px currentColor;"></div>
                            <div>
                                <div class="text-white fw-bold" style="font-family: 'Poppins'; font-size: 0.9rem;">\${p.bankName}</div>
                                <div class="text-white-50 extra-small">ID: \${p.bankId.substring(0,6)}...</div>
                            </div>
                        </div>
                    </td>
                    <td class="text-center"><span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 rounded-pill px-3 py-2 fw-bold" style="min-width: 50px;">\${p.bloodGroup}</span></td>
                    <td style="width: 250px;">
                        <div class="d-flex justify-content-between mb-1 text-white-50 extra-small">
                            <span>Flux Velocity</span>
                            <span>\${p.currentStock} / \${p.forecastUnits} Units</span>
                        </div>
                        <div class="progress" style="height: 6px; background: rgba(255,255,255,0.05); border-radius: 10px;">
                            <div class="progress-bar bg-gradient-\${riskLevel}" role="progressbar" style="width: \${velocityPercent}%; border-radius: 10px;"></div>
                        </div>
                    </td>
                    <td>
                        <div class="d-flex align-items-baseline gap-1">
                            <span class="text-primary fw-bold fs-5">\${p.forecastUnits}</span>
                            <span class="text-white-50 small">Units</span>
                        </div>
                    </td>
                    <td class="text-end">\${riskHtml}</td>
                </tr>`;
            });
            tbody.innerHTML = html;
        }).catch(err => {
            document.getElementById('forecastBody').innerHTML = `<tr><td colspan="5" class="text-danger py-5 border-0 text-center"><i class="fa-solid fa-circle-xmark fs-2 mb-3"></i><br>Intelligence relay offline. Verify data connection.</td></tr>`;
        });

    // --- 3D GLOBE: LIFEFLOW INTELLIGENCE ENGINE ---
    let globeInstance = null;

    const INDIA_HUBS = [
        { name: 'Mumbai',     lat: 19.0760, lng: 72.8777, weight: 9, group: 'O−'  },
        { name: 'Delhi',      lat: 28.6139, lng: 77.2090, weight: 8, group: 'A+'  },
        { name: 'Bangalore',  lat: 12.9716, lng: 77.5946, weight: 7, group: 'B+'  },
        { name: 'Hyderabad',  lat: 17.3850, lng: 78.4867, weight: 6, group: 'AB+' },
        { name: 'Chennai',    lat: 13.0827, lng: 80.2707, weight: 5, group: 'O+'  },
        { name: 'Kolkata',    lat: 22.5726, lng: 88.3639, weight: 7, group: 'B−'  },
        { name: 'Pune',       lat: 18.5204, lng: 73.8567, weight: 4, group: 'A−'  },
        { name: 'Ahmedabad',  lat: 23.0225, lng: 72.5714, weight: 6, group: 'O+'  },
        { name: 'Jaipur',     lat: 26.9124, lng: 75.7873, weight: 5, group: 'A+'  },
        { name: 'Lucknow',    lat: 26.8467, lng: 80.9462, weight: 4, group: 'O−'  },
        { name: 'Chandigarh', lat: 30.7333, lng: 76.7794, weight: 3, group: 'B+'  },
        { name: 'Bhopal',     lat: 23.2599, lng: 77.4126, weight: 3, group: 'AB+' },
    ];

    const SUPPLY_ARCS = [
        [0, 6], [0, 7], [0, 3], [1, 8], [1, 9],
        [1, 10], [2, 4], [2, 3], [5, 9], [3, 11], [7, 11], [8, 10]
    ];

    function urgencyColor(w) {
        if (w >= 8) return '#ef4444';
        if (w >= 6) return '#f97316';
        if (w >= 4) return '#eab308';
        return '#22c55e';
    }

    function renderGlobe(hubs) {
        // Points
        globeInstance
            .pointsData(hubs)
            .pointLat('lat').pointLng('lng')
            .pointColor(d => urgencyColor(d.weight))
            .pointAltitude(d => 0.01 + d.weight * 0.008)
            .pointRadius(d => 0.28 + d.weight * 0.035)
            .pointResolution(12)
            .pointLabel(d => '<div style="background:rgba(15,23,42,0.93);border:1px solid ' + urgencyColor(d.weight) + ';border-radius:8px;padding:7px 11px;font-family:\'Poppins\',sans-serif;box-shadow:0 0 14px ' + urgencyColor(d.weight) + '55;"><div style="color:#fff;font-weight:700;font-size:13px;">' + d.name + '</div><div style="color:' + urgencyColor(d.weight) + ';font-size:11px;margin-top:3px;"><span style="background:' + urgencyColor(d.weight) + '22;border:1px solid ' + urgencyColor(d.weight) + '55;border-radius:4px;padding:1px 6px;">' + d.group + '</span>&nbsp;Demand: ' + d.weight + ' units</div></div>');

        // Supply route arcs
        const arcData = SUPPLY_ARCS
            .map(([f, t]) => ({
                startLat: hubs[f] && hubs[f].lat, startLng: hubs[f] && hubs[f].lng,
                endLat:   hubs[t] && hubs[t].lat, endLng:   hubs[t] && hubs[t].lng,
                color: [urgencyColor((hubs[f]||{}).weight||5), urgencyColor((hubs[t]||{}).weight||5)],
                stroke: 0.4 + ((hubs[f]||{}).weight||5) * 0.04
            }))
            .filter(a => a.startLat && a.endLat);

        globeInstance
            .arcsData(arcData)
            .arcStartLat('startLat').arcStartLng('startLng')
            .arcEndLat('endLat').arcEndLng('endLng')
            .arcColor('color')
            .arcDashLength(0.3).arcDashGap(2).arcDashAnimateTime(2000)
            .arcStroke('stroke').arcAltitude(0.18);

        // Pulsing rings on critical hubs
        globeInstance
            .ringsData(hubs.filter(h => h.weight >= 5))
            .ringLat('lat').ringLng('lng')
            .ringColor(d => urgencyColor(d.weight))
            .ringMaxRadius(2.8)
            .ringPropagationSpeed(1.4)
            .ringRepeatPeriod(d => (11 - d.weight) * 280);

        // City name HTML labels
        globeInstance
            .htmlElementsData(hubs)
            .htmlLat('lat').htmlLng('lng')
            .htmlAltitude(0.028)
            .htmlElement(d => {
                const el = document.createElement('div');
                el.innerHTML = '<div style="color:#fff;font-family:\'Poppins\',sans-serif;font-size:8.5px;font-weight:600;background:rgba(0,0,0,0.55);border-left:2px solid ' + urgencyColor(d.weight) + ';padding:1px 5px;border-radius:0 3px 3px 0;white-space:nowrap;pointer-events:none;transform:translate(9px,-50%)">' + d.name + '</div>';
                return el;
            });
    }

    function init3DGlobe() {
        if (globeInstance) return;
        const container = document.getElementById('globe-3d');

        globeInstance = Globe()(container)
            .globeImageUrl('//unpkg.com/three-globe/example/img/earth-night.jpg')
            .bumpImageUrl('//unpkg.com/three-globe/example/img/earth-topology.png')
            .backgroundImageUrl('//unpkg.com/three-globe/example/img/night-sky.png')
            .width(container.offsetWidth).height(container.offsetHeight)
            .showAtmosphere(true)
            .atmosphereColor('#e11d48')
            .atmosphereAltitude(0.18)
            .pointOfView({ lat: 20.5937, lng: 78.9629, altitude: 2.2 }, 2000);

        const mat = globeInstance.globeMaterial();
        mat.shininess = 18;
        mat.emissiveIntensity = 0.06;

        globeInstance.controls().autoRotate = true;
        globeInstance.controls().autoRotateSpeed = 0.35;
        globeInstance.controls().enableZoom = true;

        // Render India hubs immediately
        renderGlobe(INDIA_HUBS);

        // Attempt to enrich with real API data
        fetch('<%=request.getContextPath()%>/api/analytics?metric=heatmapDemand' + refreshParam + '&t=' + Date.now())
            .then(r => r.json())
            .then(data => {
                const raw = Array.isArray(data) ? data : (data.points || data.data || []);
                if (raw.length >= 3) {
                    const mapped = raw.map((p, i) => ({
                        name: p.name || p.bankName || ('Hub ' + (i+1)),
                        lat: p.lat, lng: p.lng,
                        weight: Math.min(Math.round(p.weight || 5), 9),
                        group: p.bloodGroup || p.group || 'O+'
                    }));
                    renderGlobe(mapped);
                }
            })
            .catch(() => {});
    }

    init3DGlobe();

    window.addEventListener('resize', () => {
        if (globeInstance) {
            const c = document.getElementById('globe-3d');
            globeInstance.width(c.offsetWidth).height(c.offsetHeight);
        }
    });
</script>

<style>
    .bg-gradient-critical { background: linear-gradient(90deg, #ef4444, #b91c1c) !important; }
    .bg-gradient-warning { background: linear-gradient(90deg, #f59e0b, #d97706) !important; }
    .bg-gradient-safe { background: linear-gradient(90deg, #10b981, #059669) !important; }
    .extra-small { font-size: 0.7rem; }
    .pulse-animation { animation: pulse-soft 2s infinite; }
    .emergency-beacon-container { position: relative; }
    .emergency-beacon {
        position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
        width: 15px; height: 15px; background: #e11d48; border-radius: 50%;
        animation: beacon-pulse 1.5s infinite;
    }
    .emergency-beacon-core {
        position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
        width: 10px; height: 10px; background: #fff; border-radius: 50%; box-shadow: 0 0 10px #e11d48; z-index: 2;
    }
    @keyframes beacon-pulse {
        0% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
        100% { transform: translate(-50%, -50%) scale(4); opacity: 0; }
    }
    @keyframes pulse-soft {
        0% { transform: scale(0.95); opacity: 0.8; }
        50% { transform: scale(1.1); opacity: 1; }
        100% { transform: scale(0.95); opacity: 0.8; }
    }
</style>
</body>
</html>
