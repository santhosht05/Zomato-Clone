<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession existingSession = request.getSession(false);
    if (existingSession != null && existingSession.getAttribute("userId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    String error = (String) request.getAttribute("error");
    boolean registered = "true".equals(request.getParameter("registered"));
    boolean logoutSuccess = "true".equals(request.getParameter("logout"));
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Sign in to SwadhaFood to order delicious food from top restaurants near you.">
    <title>Sign In – SwadhaFood</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body class="auth-body">

<div class="auth-container">
    <!-- Left Panel -->
    <div class="auth-left">
        <div class="auth-left-content">
            <a href="index.jsp" class="auth-logo">
                <span class="logo-icon">🍽️</span>
                Swadha<span class="text-accent">Food</span>
            </a>
            <h2 class="auth-left-title">Hungry? We've got you covered!</h2>
            <p class="auth-left-subtitle">Order from 500+ restaurants and get hot food delivered to your door in minutes.</p>
            <div class="auth-features">
                <div class="auth-feature"><i class="bi bi-check-circle-fill text-success me-2"></i> 25 min average delivery</div>
                <div class="auth-feature"><i class="bi bi-check-circle-fill text-success me-2"></i> 500+ restaurants</div>
                <div class="auth-feature"><i class="bi bi-check-circle-fill text-success me-2"></i> Live order tracking</div>
                <div class="auth-feature"><i class="bi bi-check-circle-fill text-success me-2"></i> Secure payments</div>
            </div>
            <div class="auth-left-emoji-cloud">
                🍕 🍔 🍚 🥟 🍛 🍜 🍰 🥩
            </div>
        </div>
    </div>

    <!-- Right Panel - Form -->
    <div class="auth-right">
        <div class="auth-form-wrap">
            <div class="auth-form-header">
                <h1 class="auth-form-title">Welcome back!</h1>
                <p class="auth-form-subtitle">Sign in to your SwadhaFood account</p>
            </div>

            <!-- Alerts -->
            <% if (registered) { %>
            <div class="alert alert-success d-flex align-items-center" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                Account created successfully! Please sign in.
            </div>
            <% } %>
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger d-flex align-items-center" role="alert">
                <i class="bi bi-exclamation-circle-fill me-2"></i>
                <%= error %>
            </div>
            <% } %>
            <% if ("unauthorized".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning d-flex align-items-center" role="alert">
                <i class="bi bi-shield-exclamation me-2"></i>
                Access denied. Please sign in with an admin account.
            </div>
            <% } %>

            <form action="LoginServlet<%= request.getParameter("redirect") != null ? "?redirect=" + request.getParameter("redirect") : "" %>" method="POST" id="loginForm" novalidate>
                <div class="mb-3">
                    <label for="email" class="form-label">Email Address</label>
                    <div class="input-icon-wrap">
                        <i class="bi bi-envelope input-icon"></i>
                        <input type="email" class="form-control sf-input" id="email" name="email"
                               placeholder="you@example.com" required autocomplete="email">
                    </div>
                    <div class="invalid-feedback">Please enter a valid email address.</div>
                </div>

                <div class="mb-3">
                    <label for="password" class="form-label d-flex justify-content-between">
                        Password
                        <a href="#" class="forgot-link">Forgot Password?</a>
                    </label>
                    <div class="input-icon-wrap">
                        <i class="bi bi-lock input-icon"></i>
                        <input type="password" class="form-control sf-input" id="password" name="password"
                               placeholder="Enter your password" required autocomplete="current-password">
                        <button type="button" class="password-toggle" onclick="togglePassword('password', this)">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>
                    <div class="invalid-feedback">Password is required.</div>
                </div>

                <div class="mb-4 d-flex align-items-center justify-content-between">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="rememberMe">
                        <label class="form-check-label" for="rememberMe">Remember me</label>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary-sf w-100 btn-lg" id="loginBtn">
                    <span class="btn-text">Sign In</span>
                    <div class="spinner-border spinner-border-sm d-none" id="loginSpinner"></div>
                </button>
            </form>

            <div class="auth-divider"><span>or continue with</span></div>

            <div class="demo-creds">
                <div class="demo-cred-title"><i class="bi bi-info-circle me-1"></i> Demo Credentials</div>
                <div class="demo-cred-row" onclick="fillDemo('demo@swadhafood.com', 'demo123')">
                    <span>👤 User</span>
                    <span class="text-muted small">demo@swadhafood.com / demo123</span>
                    <i class="bi bi-arrow-right-circle text-primary"></i>
                </div>
                <div class="demo-cred-row" onclick="fillDemo('admin@swadhafood.com', 'admin123')">
                    <span>🔐 Admin</span>
                    <span class="text-muted small">admin@swadhafood.com / admin123</span>
                    <i class="bi bi-arrow-right-circle text-danger"></i>
                </div>
            </div>

            <div class="auth-footer-text">
                Don't have an account? <a href="register.jsp" class="auth-link">Create Account</a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
<script>
function fillDemo(email, pass) {
    document.getElementById('email').value = email;
    document.getElementById('password').value = pass;
    document.getElementById('loginBtn').click();
}

document.getElementById('loginForm').addEventListener('submit', function(e) {
    if (!this.checkValidity()) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.add('was-validated');
        return;
    }
    document.getElementById('loginBtn').disabled = true;
    document.querySelector('.btn-text').textContent = 'Signing In...';
    document.getElementById('loginSpinner').classList.remove('d-none');
});
</script>
</body>
</html>
