<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LifeFlow - Premium Blood Bank Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/assets/css/theme.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        /* ── Page entrance ── */
        body { opacity: 0; transition: opacity 0.6s ease; }
        body.loaded { opacity: 1; }

        /* ── Hero ── */
        .hero-section {
            position: relative;
            padding: 12rem 0 8rem;
            background: radial-gradient(circle at top right, rgba(225,29,72,0.12), transparent 60%),
                        radial-gradient(circle at bottom left, rgba(15,23,42,1), #020617);
            text-align: center;
            overflow: hidden;
        }
        .hero-title {
            font-family: 'Poppins', sans-serif;
            font-weight: 800;
            font-size: 5rem;
            line-height: 1.1;
            margin-bottom: 2rem;
            letter-spacing: -2px;
        }
        .hero-title span.outline {
            -webkit-text-stroke: 1px rgba(255,255,255,0.3);
            color: transparent;
        }
        .hero-subtitle {
            color: var(--text-secondary);
            font-size: 1.25rem;
            max-width: 700px;
            margin: 0 auto 4rem;
            line-height: 1.6;
        }

        /* ── Typewriter ── */
        #typewriter {
            color: var(--primary-crimson);
            border-right: 3px solid var(--primary-crimson);
            padding-right: 4px;
            animation: blink 0.75s step-end infinite;
            white-space: nowrap;
            display: inline-block;
        }
        @keyframes blink { 50% { border-color: transparent; } }

        /* ── Floating particles ── */
        #particles-canvas {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            pointer-events: none;
            z-index: 0;
        }
        .hero-section .container { position: relative; z-index: 1; }

        /* ── Vision cards animated border ── */
        .vision-card {
            background: linear-gradient(180deg, rgba(225,29,72,0.05) 0%, transparent 100%);
            border-radius: var(--radius-lg);
            padding: 3rem;
            height: 100%;
            position: relative;
            border: 1px solid rgba(255,255,255,0.08);
            transition: transform 0.4s ease, box-shadow 0.4s ease;
            overflow: hidden;
        }
        /* Animated glow border via box-shadow only — card background stays dark */
        .vision-card::after {
            content: '';
            position: absolute;
            inset: 0;
            border-radius: var(--radius-lg);
            padding: 2px;
            background: linear-gradient(135deg, #e11d48, #7c3aed, #0ea5e9, #e11d48);
            background-size: 300% 300%;
            -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask-composite: xor;
            mask-composite: exclude;
            opacity: 0;
            transition: opacity 0.4s ease;
            animation: gradientShift 4s ease infinite;
            z-index: 0;
        }
        .vision-card:hover::after { opacity: 1; }
        .vision-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 50px rgba(225,29,72,0.2), 0 0 60px rgba(124,58,237,0.1);
            background: rgba(30,41,59,0.95);
        }
        .vision-card > * { position: relative; z-index: 1; }
        /* Text transitions on hover */
        .vision-card h3 { transition: color 0.3s ease; }
        .vision-card p   { transition: color 0.3s ease; }
        .vision-card:hover h3 { color: #ffffff !important; }
        .vision-card:hover p  { color: #e2e8f0 !important; }
        @keyframes gradientShift {
            0%   { background-position: 0% 50%; }
            50%  { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .icon-circle {
            width: 64px; height: 64px;
            background: rgba(225,29,72,0.1);
            color: var(--primary-crimson);
            display: flex; align-items: center; justify-content: center;
            border-radius: 50%;
            margin-bottom: 2rem;
            font-size: 1.5rem;
            transition: background 0.3s, transform 0.3s;
        }
        .vision-card:hover .icon-circle, .card-premium:hover .icon-circle {
            background: rgba(225,29,72,0.25);
            transform: scale(1.15) rotate(-5deg);
        }

        /* ── Features ── */
        .feature-grid { padding: 8rem 0; }
        .section-header { text-align: center; margin-bottom: 5rem; }
        .section-tag {
            color: var(--primary-crimson);
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            font-size: 0.85rem;
            margin-bottom: 1rem;
            display: block;
        }
        .card-premium {
            transition: transform 0.4s cubic-bezier(0.16,1,0.3,1), box-shadow 0.4s ease !important;
        }
        .card-premium:hover {
            transform: translateY(-10px) !important;
            box-shadow: 0 30px 60px rgba(0,0,0,0.4), 0 0 30px rgba(225,29,72,0.15) !important;
        }

        /* ── Scroll reveal ── */
        .reveal {
            opacity: 0;
            transform: translateY(40px);
            transition: opacity 0.7s ease, transform 0.7s ease;
        }
        .reveal.visible { opacity: 1; transform: translateY(0); }
        .reveal-delay-1 { transition-delay: 0.1s; }
        .reveal-delay-2 { transition-delay: 0.25s; }
        .reveal-delay-3 { transition-delay: 0.4s; }

        /* ── Pulsing CTA ── */
        .btn-join {
            background: linear-gradient(135deg, #e11d48, #9f1239);
            color: white !important;
            font-weight: 700;
            border-radius: var(--radius-pill);
            padding: 0.85rem 2.5rem;
            box-shadow: 0 0 0 0 rgba(225,29,72,0.7);
            animation: ctaPulse 2s infinite;
            border: none;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .btn-join:hover {
            transform: scale(1.05) translateY(-2px);
            box-shadow: 0 15px 30px rgba(225,29,72,0.5) !important;
            animation: none;
        }
        @keyframes ctaPulse {
            0%   { box-shadow: 0 0 0 0 rgba(225,29,72,0.7); }
            70%  { box-shadow: 0 0 0 14px rgba(225,29,72,0); }
            100% { box-shadow: 0 0 0 0 rgba(225,29,72,0); }
        }

        /* ── Hero badge ── */
        .hero-badge {
            display: inline-flex; align-items: center; gap: 0.5rem;
            background: rgba(225,29,72,0.1);
            border: 1px solid rgba(225,29,72,0.3);
            color: #f87171;
            padding: 0.4rem 1.2rem;
            border-radius: 50rem;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 2rem;
            animation: fadeInDown 0.8s ease both;
        }
        .hero-badge .dot {
            width: 8px; height: 8px;
            background: #e11d48;
            border-radius: 50%;
            animation: ctaPulse 1.5s infinite;
        }
        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-20px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/fragments/header.jspf" %>

<!-- Floating Particle Canvas -->
<canvas id="particles-canvas"></canvas>

<!-- Hero Section -->
<section class="hero-section">
    <div class="container">
        <div class="hero-badge">
            <span class="dot"></span> India's Smart Blood Network
        </div>
        <h1 class="hero-title fade-in-up">
            <span class="outline">Save Lives.</span>
            <span style="color: var(--primary-crimson)"> Give Blood.</span><br>
            <span id="typewriter"></span>
        </h1>
        <p class="hero-subtitle fade-in-up">
            A premium intelligence platform connecting donors, blood banks, and administrators
            across India — powered by real-time data and AI-assisted dispatch.
        </p>

        <div class="d-flex justify-content-center gap-3 mb-5 fade-in-up">
            <a href="<%=request.getContextPath()%>/register.jsp" class="btn btn-join py-3 px-5 fs-5">
                <i class="fa-solid fa-heart-pulse me-2"></i> Join as Donor
            </a>
            <a href="<%=request.getContextPath()%>/login.jsp" class="btn btn-outline-light rounded-pill py-3 px-5 fs-5">
                <i class="fa-solid fa-right-to-bracket me-2"></i> Sign In
            </a>
        </div>

        <div class="row g-4 justify-content-center text-start mt-5">
            <div class="col-lg-5">
                <div class="vision-card">
                    <div class="icon-circle"><i class="fa-solid fa-eye"></i></div>
                    <h3 class="text-white fw-bold mb-3"><fmt:message key="vision.title" /></h3>
                    <p class="text-secondary mb-0"><fmt:message key="vision.text" /></p>
                </div>
            </div>
            <div class="col-lg-5">
                <div class="vision-card">
                    <div class="icon-circle"><i class="fa-solid fa-bullseye"></i></div>
                    <h3 class="text-white fw-bold mb-3"><fmt:message key="mission.title" /></h3>
                    <p class="text-secondary mb-0"><fmt:message key="mission.text" /></p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Features Section -->
<section class="feature-grid">
    <div class="container">
        <div class="section-header reveal">
            <span class="section-tag">Core Capabilities</span>
            <h2 class="display-4 fw-bold text-white">Advanced Healthcare Framework</h2>
        </div>
        <div class="row g-4 justify-content-center">
            <div class="col-lg-4 reveal reveal-delay-1">
                <div class="card-premium p-5 h-100">
                    <div class="icon-circle"><i class="fa-solid fa-clock"></i></div>
                    <h4 class="text-white fw-bold mb-3"><fmt:message key="features.alerts.title" /></h4>
                    <p class="text-secondary mb-0"><fmt:message key="features.alerts.text" /></p>
                </div>
            </div>
            <div class="col-lg-4 reveal reveal-delay-2">
                <div class="card-premium p-5 h-100">
                    <div class="icon-circle"><i class="fa-solid fa-user-shield"></i></div>
                    <h4 class="text-white fw-bold mb-3"><fmt:message key="features.donors.title" /></h4>
                    <p class="text-secondary mb-0"><fmt:message key="features.donors.text" /></p>
                </div>
            </div>
            <div class="col-lg-4 reveal reveal-delay-3">
                <div class="card-premium p-5 h-100">
                    <div class="icon-circle"><i class="fa-solid fa-chart-pie"></i></div>
                    <h4 class="text-white fw-bold mb-3"><fmt:message key="features.tracking.title" /></h4>
                    <p class="text-secondary mb-0"><fmt:message key="features.tracking.text" /></p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Support Section -->
<section class="container mb-5 pb-5">
    <div class="card-premium p-5 text-center reveal" style="background: radial-gradient(circle at center, rgba(225,29,72,0.1), transparent);">
        <div class="icon-circle mx-auto"><i class="fa-solid fa-headset"></i></div>
        <h2 class="display-5 fw-bold text-white mb-3"><fmt:message key="support.title" /></h2>
        <p class="text-secondary fs-5 mx-auto mb-5" style="max-width: 600px;">
            <fmt:message key="support.subtitle" />
        </p>
        <a href="<%=request.getContextPath()%>/contact.jsp" class="btn btn-join py-3 px-5 fs-5">
            <i class="fa-solid fa-comments me-2"></i> <fmt:message key="support.btn" />
        </a>
    </div>
</section>

<%@ include file="/WEB-INF/fragments/footer.jspf" %>
<jsp:include page="/chatWidget.jsp" />

<script>
// ── Page entrance
window.addEventListener('load', () => document.body.classList.add('loaded'));

// ── Typewriter
(function() {
    const phrases = ['Be a Hero.', 'Donate Today.', 'Save a Life.', 'Make a Difference.'];
    let pi = 0, ci = 0, deleting = false;
    const el = document.getElementById('typewriter');
    function tick() {
        const phrase = phrases[pi];
        if (!deleting) {
            el.textContent = phrase.slice(0, ++ci);
            if (ci === phrase.length) { deleting = true; setTimeout(tick, 1800); return; }
        } else {
            el.textContent = phrase.slice(0, --ci);
            if (ci === 0) { deleting = false; pi = (pi + 1) % phrases.length; }
        }
        setTimeout(tick, deleting ? 55 : 90);
    }
    tick();
})();

// ── Floating particles
(function() {
    const canvas = document.getElementById('particles-canvas');
    const ctx = canvas.getContext('2d');
    let W, H, particles = [];
    function resize() {
        const hero = canvas.parentElement;
        W = canvas.width = hero.offsetWidth;
        H = canvas.height = hero.offsetHeight;
    }
    function Particle() {
        this.x = Math.random() * W;
        this.y = Math.random() * H;
        this.r = Math.random() * 2.5 + 0.5;
        this.dx = (Math.random() - 0.5) * 0.4;
        this.dy = (Math.random() - 0.5) * 0.4;
        this.alpha = Math.random() * 0.4 + 0.1;
    }
    function init() {
        resize();
        particles = Array.from({length: 70}, () => new Particle());
    }
    function draw() {
        ctx.clearRect(0, 0, W, H);
        particles.forEach(p => {
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fillStyle = `rgba(225,29,72,${p.alpha})`;
            ctx.fill();
            p.x += p.dx; p.y += p.dy;
            if (p.x < 0 || p.x > W) p.dx *= -1;
            if (p.y < 0 || p.y > H) p.dy *= -1;
        });
        requestAnimationFrame(draw);
    }
    window.addEventListener('resize', resize);
    init(); draw();
})();

// ── Scroll reveal
(function() {
    const els = document.querySelectorAll('.reveal');
    const io = new IntersectionObserver(entries => {
        entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target); } });
    }, { threshold: 0.15 });
    els.forEach(el => io.observe(el));
})();
</script>
</body>
</html>
