<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Privacy Policy | LifeFlow</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .legal-content {
            line-height: 1.8;
            color: var(--text-secondary);
        }
        .legal-content h3 {
            color: var(--text-primary);
            font-weight: 700;
            margin-top: 2.5rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .legal-content h3 i {
            color: var(--primary-crimson);
            font-size: 1.25rem;
        }
        .hero-legal {
            padding: 8rem 0 4rem;
            background: radial-gradient(circle at top right, rgba(225, 29, 72, 0.05), transparent),
                        radial-gradient(circle at bottom left, rgba(30, 41, 59, 0.5), transparent);
        }
    </style>
</head>
<body>

    <%@ include file="/WEB-INF/fragments/header.jspf" %>

    <section class="hero-legal text-center">
        <div class="container fade-in-up">
            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 px-3 py-2 rounded-pill mb-3">Compliance</span>
            <h1 class="display-3 fw-bold text-white mb-3" style="font-family: 'Poppins';">Privacy Policy</h1>
            <p class="lead text-secondary mx-auto" style="max-width: 650px;">
                How we safeguard your medical records, donor identity, and personal information across the LifeFlow network.
            </p>
        </div>
    </section>

    <main class="container pb-5 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-9">
                <div class="card-premium p-4 p-md-5 fade-in-up delay-100">
                    <div class="legal-content">
                        <p class="mb-5 italic text-white-50">Last Updated: April 21, 2026</p>

                        <h3><i class="fa-solid fa-database"></i> 1. Data Collection</h3>
                        <p>
                            To provide effective blood bank management services, LifeFlow collects specific personal information including your full name, blood group, contact details, and geolocation (when searching for nearby banks). For donors, we also securely store medical history snapshots provided voluntarily during registration.
                        </p>

                        <h3><i class="fa-solid fa-user-shield"></i> 2. Donor Confidentiality</h3>
                        <p>
                            Your identity is hidden by default in search results. Donor names and contact numbers are only revealed to verified emergency requesters once a match has been established and approved by the system administrator. We do not sell or trade donor lists to insurance companies or marketing firms.
                        </p>

                        <h3><i class="fa-solid fa-lock"></i> 3. Security & Encryption</h3>
                        <p>
                            LifeFlow employs high-level security protocols. All data transmitted between your browser and our servers is encrypted using <strong>Secure Sockets Layer (SSL)</strong>. Sensitive medical data stored in our Firebase Realtime Database is further protected by server-side rules and administrative access controls.
                        </p>

                        <h3><i class="fa-solid fa-share-nodes"></i> 4. Third-Party Services</h3>
                        <p>
                            We utilize third-party services like <strong>Google Firebase</strong> for real-time data sync and <strong>Email/SMS gateways</strong> for emergency alerts. These providers are strictly prohibited from using your data for any purpose other than facilitating LifeFlow operations.
                        </p>

                        <h3><i class="fa-solid fa-circle-check"></i> 5. Your Rights</h3>
                        <p>
                            You have the right to access, modify, or delete your profile at any time through the Donor Dashboard. If you wish to withdraw from the donation network permanently, you can request a full account deletion, which will purge all your medical records from our active databases.
                        </p>

                        <div class="mt-5 p-4 rounded-4 text-center" style="background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08);">
                            <p class="mb-0 small text-secondary">
                                For any questions regarding this policy, please contact our data protection officer at <a href="mailto:lifeflowad@gmail.com" class="text-danger">lifeflowad@gmail.com</a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="/WEB-INF/fragments/footer.jspf" %>

</body>
</html>
