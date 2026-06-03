<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession existingSession = request.getSession(false);
    if (existingSession != null && existingSession.getAttribute("userId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Create your SwadhaFood account and start ordering delicious food today.">
    <title>Create Account – SwadhaFood</title>
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
            <h2 class="auth-left-title">Join 50,000+ Food Lovers!</h2>
            <p class="auth-left-subtitle">Create your free account and enjoy exclusive deals on your first 3 orders.</p>
            <div class="auth-features">
                <div class="auth-feature"><i class="bi bi-gift-fill text-warning me-2"></i> 20% OFF on first order</div>
                <div class="auth-feature"><i class="bi bi-truck text-primary me-2"></i> Free delivery for 30 days</div>
                <div class="auth-feature"><i class="bi bi-heart-fill text-danger me-2"></i> Save your favourites</div>
                <div class="auth-feature"><i class="bi bi-bell-fill text-success me-2"></i> Real-time order tracking</div>
            </div>
            <div class="auth-left-emoji-cloud">
                🎉 🍕 🍔 🎊 🍛 🎁 🍰 🎶
            </div>
        </div>
    </div>

    <!-- Right Panel - Form -->
    <div class="auth-right">
        <div class="auth-form-wrap">
            <div class="auth-form-header">
                <h1 class="auth-form-title">Create Account</h1>
                <p class="auth-form-subtitle">Join SwadhaFood for free today</p>
            </div>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger d-flex align-items-center" role="alert">
                <i class="bi bi-exclamation-circle-fill me-2"></i>
                <%= error %>
            </div>
            <% } %>

            <form action="RegisterServlet" method="POST" id="registerForm" novalidate>
                <div class="row g-3">
                    <div class="col-12">
                        <label for="name" class="form-label">Full Name</label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-person input-icon"></i>
                            <input type="text" class="form-control sf-input" id="name" name="name"
                                   placeholder="John Doe" required minlength="2">
                        </div>
                        <div class="invalid-feedback">Please enter your full name (min 2 chars).</div>
                    </div>

                    <div class="col-12">
                        <label for="email" class="form-label">Email Address</label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-envelope input-icon"></i>
                            <input type="email" class="form-control sf-input" id="email" name="email"
                                   placeholder="you@example.com" required>
                        </div>
                        <div class="invalid-feedback">Please enter a valid email address.</div>
                    </div>

                    <div class="col-12">
                        <label for="phone" class="form-label">Phone Number <span class="text-muted small">(optional)</span></label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-telephone input-icon"></i>
                            <input type="tel" class="form-control sf-input" id="phone" name="phone"
                                   placeholder="+91 98765 43210" pattern="[0-9]{10}">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label for="password" class="form-label">Password</label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-lock input-icon"></i>
                            <input type="password" class="form-control sf-input" id="password" name="password"
                                   placeholder="Min 6 characters" required minlength="6">
                            <button type="button" class="password-toggle" onclick="togglePassword('password', this)">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                        <div id="passwordStrength" class="password-strength mt-1"></div>
                        <div class="invalid-feedback">Password must be at least 6 characters.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="confirmPassword" class="form-label">Confirm Password</label>
                        <div class="input-icon-wrap">
                            <i class="bi bi-lock-fill input-icon"></i>
                            <input type="password" class="form-control sf-input" id="confirmPassword" name="confirmPassword"
                                   placeholder="Repeat password" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword', this)">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                        <div class="invalid-feedback">Passwords do not match.</div>
                    </div>

                    <div class="col-12">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="agreeTerms" required>
                            <label class="form-check-label" for="agreeTerms">
                                I agree to the <a href="#" class="auth-link">Terms of Service</a> and <a href="#" class="auth-link">Privacy Policy</a>
                            </label>
                            <div class="invalid-feedback">You must agree before signing up.</div>
                        </div>
                    </div>

                    <div class="col-12">
                        <button type="submit" class="btn btn-primary-sf w-100 btn-lg" id="registerBtn">
                            <span class="btn-text">Create My Account</span>
                            <div class="spinner-border spinner-border-sm d-none" id="registerSpinner"></div>
                        </button>
                    </div>
                </div>
            </form>

            <div class="auth-footer-text mt-3">
                Already have an account? <a href="login.jsp" class="auth-link">Sign In</a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
<script>
const registerForm = document.getElementById('registerForm');
const passwordInput = document.getElementById('password');
const confirmInput  = document.getElementById('confirmPassword');

// Password strength meter
passwordInput.addEventListener('input', function() {
    const val = this.value;
    const strengthDiv = document.getElementById('passwordStrength');
    let strength = 0;
    if (val.length >= 6) strength++;
    if (/[A-Z]/.test(val)) strength++;
    if (/[0-9]/.test(val)) strength++;
    if (/[^A-Za-z0-9]/.test(val)) strength++;
    const levels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    const colors = ['', '#e53935', '#f57c00', '#43a047', '#1565c0'];
    strengthDiv.innerHTML = val.length ? `<small style="color:${colors[strength]}">Password strength: <strong>${levels[strength]}</strong></small>` : '';
});

// Confirm password match validation
confirmInput.addEventListener('input', function() {
    if (this.value !== passwordInput.value) {
        this.setCustomValidity('Passwords do not match');
    } else {
        this.setCustomValidity('');
    }
});

registerForm.addEventListener('submit', function(e) {
    // Recheck confirm
    if (confirmInput.value !== passwordInput.value) {
        confirmInput.setCustomValidity('Passwords do not match');
    }
    if (!this.checkValidity()) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.add('was-validated');
        return;
    }
    document.getElementById('registerBtn').disabled = true;
    document.querySelector('.btn-text').textContent = 'Creating Account...';
    document.getElementById('registerSpinner').classList.remove('d-none');
});
</script>
</body>
</html>
