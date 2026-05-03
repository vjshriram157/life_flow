<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
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
    <title>Book Donation | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
</head>

<body>
<div class="d-flex">
    <!-- SIDEBAR -->
    <% request.setAttribute("activePage", "donate_blood"); %>
    <jsp:include page="/WEB-INF/fragments/sidebar-donor.jspf" />

    <!-- MAIN CONTENT -->
    <div class="container-fluid p-4 p-md-5 w-100">
        <div class="d-flex justify-content-between align-items-center mb-5 fade-in-up">
            <div>
                <h2 class="fw-bold mb-1">Book a Donation Appointment</h2>
                <p class="text-white-50">Select a partnered blood bank and a convenient schedule block to donate.</p>
            </div>
        </div>

        <div class="row g-4 justify-content-center">
            <!-- Form Section -->
            <div class="col-lg-8 fade-in-up delay-100">
                <div class="card card-modern p-4 p-md-5 border-0 h-100">
                    <div class="card-body">
                        <div class="text-center mb-5">
                            <div class="d-inline-flex bg-danger bg-opacity-10 text-danger p-3 rounded-circle mb-3 border border-danger border-opacity-25" style="border-width: 2px !important">
                                <i class="fa-solid fa-hand-holding-droplet fs-1"></i>
                            </div>
                            <h3 class="fw-bold">Schedule Visit</h3>
                        </div>

                        <%
                            String bookingError = (String) request.getAttribute("bookingError");
                            if (bookingError != null) {
                        %>
                            <div class="alert alert-danger shadow-sm border-0 d-flex align-items-center mb-5 fade-in-up" role="alert" style="background: rgba(225, 29, 72, 0.05); color: #e11d48; border-left: 4px solid #e11d48 !important;">
                                <i class="fa-solid fa-circle-exclamation fs-4 me-3"></i>
                                <div>
                                    <h6 class="fw-bold mb-1">Action Denied</h6>
                                    <span style="font-size: 0.9rem;"><%= bookingError %></span>
                                </div>
                            </div>
                        <%
                            }
                        %>

                        <form action="<%= request.getContextPath() %>/BookAppointmentServlet" method="post">
                            <div class="mb-4">
                                <label class="form-label fw-bold"><i class="fa-solid fa-hospital-user text-danger me-2"></i> Select Partnering Facility</label>
                                <div class="input-group input-group-lg mb-4">
                                    <span class="input-group-text bg-dark border border-secondary border-opacity-25 text-white"><i class="fa-solid fa-map-pin text-white-50"></i></span>
                                    <select name="bankId" id="bankSelect" class="form-select form-control-modern bg-dark text-white border border-secondary border-opacity-25 py-3" required>
                                        <option value="">Select an Approved Blood Bank</option>
                                        <%
                                            String prefillBankId = (String) request.getAttribute("prefillBankId");
                                            List<String[]> banks = (List<String[]>) request.getAttribute("banks");
                                            if (banks != null && !banks.isEmpty()) {
                                                for (String[] bank : banks) {
                                                    String selectedStr = (prefillBankId != null && prefillBankId.equals(bank[0])) ? "selected" : "";
                                        %>
                                                    <option value="<%= bank[0] %>" data-lat="<%= bank[2] %>" data-lng="<%= bank[3] %>" data-location="<%= bank[4] %>" <%= selectedStr %>><%= bank[1] %></option>
                                        <%
                                                }
                                            } else {
                                        %>
                                                <option disabled>No Blood Banks Active or Approved Presently</option>
                                        <%
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-5">
                                <label class="form-label fw-bold"><i class="fa-regular fa-clock text-danger me-2"></i> Reservation Date &amp; Time</label>
                                <div class="input-group input-group-lg mb-5">
                                    <span class="input-group-text bg-dark border border-secondary border-opacity-25 text-white"><i class="fa-solid fa-calendar text-white-50"></i></span>
                                    <input type="datetime-local" name="appointmentTime" class="form-control form-control-modern bg-dark text-white border border-secondary border-opacity-25 py-3" required>
                                </div>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-premium btn-lg rounded-pill fw-bold">
                                    Establish Appointment <i class="fa-solid fa-arrow-right ms-2"></i>
                                </button>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-3">
                                <a href="<%= request.getContextPath() %>/dashboard/donor/home.jsp" class="btn btn-outline-secondary rounded-pill py-2 text-white fw-bold">
                                    Cancel &amp; Back to Dashboard
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Globe removed for performance -->
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const appointmentForm = document.querySelector('form');
        const submitBtn = appointmentForm.querySelector('button[type="submit"]');

        appointmentForm.addEventListener('submit', () => {
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Processing...';
        });


        if (bankSelect.value) {
            setTimeout(() => bankSelect.dispatchEvent(new Event('change')), 1000);
        }
    });
</script>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
