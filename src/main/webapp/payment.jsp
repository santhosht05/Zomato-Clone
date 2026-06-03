<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = (int) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");

    // Calculate cart total
    double cartTotal = 0;
    int itemCount = 0;
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT SUM(c.quantity * f.price) AS total, COUNT(*) AS cnt " +
            "FROM cart c JOIN foods f ON c.food_id = f.id WHERE c.user_id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            cartTotal = rs.getDouble("total");
            itemCount = rs.getInt("cnt");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (itemCount == 0) {
        response.sendRedirect("cart.jsp?empty=true");
        return;
    }

    double deliveryFee = 40.0;
    double grandTotal = cartTotal + deliveryFee;
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Complete your SwadhaFood order payment securely.">
    <title>Payment – SwadhaFood</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>

<main class="main-content">
    <div class="page-hero-sm">
        <div class="container">
            <h1 class="page-hero-title">💳 Secure Payment</h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb sf-breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                    <li class="breadcrumb-item"><a href="CartServlet">Cart</a></li>
                    <li class="breadcrumb-item active">Payment</li>
                </ol>
            </nav>
        </div>
    </div>

    <!-- Progress Steps -->
    <div class="container mb-4">
        <div class="checkout-steps">
            <div class="checkout-step done"><div class="step-circle"><i class="bi bi-check-lg"></i></div><span>Cart</span></div>
            <div class="step-line done"></div>
            <div class="checkout-step active"><div class="step-circle">2</div><span>Payment</span></div>
            <div class="step-line"></div>
            <div class="checkout-step"><div class="step-circle">3</div><span>Confirmation</span></div>
        </div>
    </div>

    <div class="container">
        <div class="row gy-4">
            <!-- Payment Form -->
            <div class="col-lg-7">
                <!-- Delivery Address -->
                <div class="payment-section-card mb-4">
                    <h5 class="payment-section-title"><i class="bi bi-geo-alt-fill me-2 text-danger"></i>Delivery Address</h5>
                    <div class="mb-3">
                        <label class="form-label">Full Address</label>
                        <textarea class="form-control sf-input" id="deliveryAddress" name="deliveryAddress"
                                  rows="3" placeholder="Flat No, Building, Street, City..." required></textarea>
                    </div>
                </div>

                <!-- Payment Method Tabs -->
                <div class="payment-section-card">
                    <h5 class="payment-section-title"><i class="bi bi-credit-card-2-front me-2 text-primary"></i>Payment Method</h5>

                    <div class="payment-tabs">
                        <button class="payment-tab active" data-tab="card" onclick="switchPayTab('card', this)">
                            <i class="bi bi-credit-card me-2"></i>Card
                        </button>
                        <button class="payment-tab" data-tab="upi" onclick="switchPayTab('upi', this)">
                            <i class="bi bi-phone me-2"></i>UPI
                        </button>
                        <button class="payment-tab" data-tab="cod" onclick="switchPayTab('cod', this)">
                            <i class="bi bi-cash-stack me-2"></i>Cash on Delivery
                        </button>
                    </div>

                    <!-- Card Tab -->
                    <div class="payment-tab-content active" id="tab-card">
                        <div class="card-preview" id="cardPreview">
                            <div class="card-preview-chip">
                                <div class="chip-lines"></div>
                            </div>
                            <div class="card-preview-number" id="previewNumber">•••• •••• •••• ••••</div>
                            <div class="card-preview-bottom">
                                <div>
                                    <small>Card Holder</small>
                                    <div id="previewName">YOUR NAME</div>
                                </div>
                                <div>
                                    <small>Expires</small>
                                    <div id="previewExpiry">MM/YY</div>
                                </div>
                            </div>
                        </div>

                        <div class="row g-3 mt-2">
                            <div class="col-12">
                                <label class="form-label">Card Number</label>
                                <div class="input-icon-wrap">
                                    <i class="bi bi-credit-card input-icon"></i>
                                    <input type="text" class="form-control sf-input" id="cardNumber"
                                           placeholder="1234 5678 9012 3456" maxlength="19"
                                           oninput="formatCardNumber(this)" autocomplete="cc-number">
                                </div>
                                <div class="invalid-feedback" id="cardNumError"></div>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Card Holder Name</label>
                                <div class="input-icon-wrap">
                                    <i class="bi bi-person input-icon"></i>
                                    <input type="text" class="form-control sf-input" id="cardName"
                                           placeholder="As printed on card" oninput="updatePreviewName(this.value)"
                                           autocomplete="cc-name">
                                </div>
                            </div>
                            <div class="col-6">
                                <label class="form-label">Expiry Date</label>
                                <input type="text" class="form-control sf-input" id="cardExpiry"
                                       placeholder="MM/YY" maxlength="5"
                                       oninput="formatExpiry(this)" autocomplete="cc-exp">
                                <div class="invalid-feedback" id="expiryError"></div>
                            </div>
                            <div class="col-6">
                                <label class="form-label">CVV</label>
                                <div class="input-icon-wrap">
                                    <i class="bi bi-shield-lock input-icon"></i>
                                    <input type="password" class="form-control sf-input" id="cardCvv"
                                           placeholder="•••" maxlength="4" autocomplete="cc-csc">
                                </div>
                                <div class="invalid-feedback" id="cvvError"></div>
                            </div>
                        </div>
                    </div>

                    <!-- UPI Tab -->
                    <div class="payment-tab-content" id="tab-upi">
                        <div class="upi-options">
                            <label class="upi-option">
                                <input type="radio" name="upiMethod" value="gpay" checked>
                                <div class="upi-option-card">
                                    <span class="upi-icon">G</span>
                                    <span>Google Pay</span>
                                </div>
                            </label>
                            <label class="upi-option">
                                <input type="radio" name="upiMethod" value="phonepe">
                                <div class="upi-option-card">
                                    <span class="upi-icon upi-pp">P</span>
                                    <span>PhonePe</span>
                                </div>
                            </label>
                            <label class="upi-option">
                                <input type="radio" name="upiMethod" value="paytm">
                                <div class="upi-option-card">
                                    <span class="upi-icon upi-pt">₹</span>
                                    <span>Paytm</span>
                                </div>
                            </label>
                        </div>
                        <div class="mt-3">
                            <label class="form-label">Enter UPI ID</label>
                            <div class="input-icon-wrap">
                                <i class="bi bi-at input-icon"></i>
                                <input type="text" class="form-control sf-input" id="upiId"
                                       placeholder="yourname@upi">
                            </div>
                            <div class="invalid-feedback" id="upiError"></div>
                        </div>
                        <div class="upi-cashback-notice mt-3">
                            <i class="bi bi-info-circle-fill text-info me-2"></i>
                            Get 10% cashback up to ₹150 on UPI payments!
                        </div>
                    </div>

                    <!-- COD Tab -->
                    <div class="payment-tab-content" id="tab-cod">
                        <div class="cod-info">
                            <div class="cod-icon">💵</div>
                            <h5>Cash on Delivery</h5>
                            <p>Pay with cash when your order is delivered. Keep exact change handy!</p>
                            <div class="cod-note">
                                <i class="bi bi-info-circle me-2"></i>
                                COD available for orders up to ₹2,000. ₹20 COD fee applies.
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Order Summary -->
            <div class="col-lg-5">
                <div class="order-summary-card sticky-top">
                    <h5 class="order-summary-title"><i class="bi bi-receipt me-2"></i>Order Summary</h5>
                    <div class="order-summary-rows">
                        <div class="summary-row">
                            <span>Food Subtotal</span>
                            <span>₹<%= String.format("%.0f", cartTotal) %></span>
                        </div>
                        <div class="summary-row">
                            <span>Delivery Fee</span>
                            <span>₹<%= String.format("%.0f", deliveryFee) %></span>
                        </div>
                        <div class="summary-row coupon-discount-row" id="discountRowPay" style="display:none; color:var(--color-success)">
                            <span>Coupon Discount</span>
                            <span>-₹<span id="discountAmtPay">0</span></span>
                        </div>
                        <hr class="summary-divider">
                        <div class="summary-row summary-total">
                            <strong>Total</strong>
                            <strong class="text-primary">₹<span id="grandTotalDisp"><%= String.format("%.0f", grandTotal) %></span></strong>
                        </div>
                    </div>

                    <div class="secure-badge">
                        <i class="bi bi-shield-check-fill text-success me-2"></i>
                        <span>256-bit SSL Encryption – Your payment is safe</span>
                    </div>

                    <button type="button" class="btn btn-primary-sf w-100 btn-lg mt-3" id="payBtn" onclick="processPayment()">
                        <i class="bi bi-lock-fill me-2"></i>
                        Pay ₹<span id="payBtnAmount"><%= String.format("%.0f", grandTotal) %></span>
                    </button>

                    <p class="text-center text-muted small mt-3">
                        By placing your order, you agree to our <a href="#">Terms & Conditions</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Processing Overlay -->
<div class="payment-overlay" id="paymentOverlay" style="display:none">
    <div class="payment-processing-box">
        <div class="payment-spinner">
            <div class="spinner-ring"></div>
            <div class="spinner-ring ring-2"></div>
        </div>
        <h4>Processing Payment...</h4>
        <p class="text-muted">Please do not close this window</p>
    </div>
</div>

<!-- Hidden Order Form -->
<form id="orderForm" action="OrderServlet" method="POST" style="display:none">
    <input type="hidden" name="action" value="place">
    <input type="hidden" name="paymentMethod" id="hiddenPaymentMethod" value="card">
    <input type="hidden" name="paymentStatus" value="paid">
    <input type="hidden" name="deliveryAddress" id="hiddenAddress">
    <input type="hidden" name="couponCode" id="hiddenCoupon">
    <input type="hidden" name="discount" id="hiddenDiscount" value="0">
</form>

<%@ include file="footer.jsp" %>
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
<script>
const BASE_TOTAL = <%= grandTotal %>;
let discount = 0;
let activeTab = 'card';

// Load coupon from sessionStorage
const savedDiscount = parseInt(sessionStorage.getItem('discount') || '0');
const savedCoupon   = sessionStorage.getItem('coupon') || '';
if (savedDiscount > 0) {
    discount = savedDiscount;
    document.getElementById('discountRowPay').style.display = '';
    document.getElementById('discountAmtPay').textContent = discount;
    document.getElementById('hiddenCoupon').value = savedCoupon;
    document.getElementById('hiddenDiscount').value = discount;
    updateGrandTotal();
}

function updateGrandTotal() {
    const total = Math.max(0, BASE_TOTAL - discount);
    document.getElementById('grandTotalDisp').textContent = total.toFixed(0);
    document.getElementById('payBtnAmount').textContent = total.toFixed(0);
}

function switchPayTab(tab, btn) {
    activeTab = tab;
    document.querySelectorAll('.payment-tab').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.payment-tab-content').forEach(c => c.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById('tab-' + tab).classList.add('active');
    document.getElementById('hiddenPaymentMethod').value = tab;
}

function formatCardNumber(input) {
    let val = input.value.replace(/\D/g, '').substring(0, 16);
    val = val.replace(/(.{4})/g, '$1 ').trim();
    input.value = val;
    document.getElementById('previewNumber').textContent = val.padEnd(19, '•').replace(/[0-9]/g, (c, i) => i < 11 ? '•' : c) || '•••• •••• •••• ••••';
    // Show last 4 digits
    const parts = val.split(' ');
    const masked = parts.map((p, i) => i < parts.length - 1 ? '••••' : p).join(' ');
    document.getElementById('previewNumber').textContent = masked || '•••• •••• •••• ••••';
}

function updatePreviewName(name) {
    document.getElementById('previewName').textContent = name.toUpperCase() || 'YOUR NAME';
}

function formatExpiry(input) {
    let val = input.value.replace(/\D/g, '').substring(0, 4);
    if (val.length > 2) val = val.substring(0,2) + '/' + val.substring(2);
    input.value = val;
    document.getElementById('previewExpiry').textContent = val || 'MM/YY';
}

function validateCard() {
    const num    = document.getElementById('cardNumber').value.replace(/\s/g, '');
    const name   = document.getElementById('cardName').value.trim();
    const expiry = document.getElementById('cardExpiry').value;
    const cvv    = document.getElementById('cardCvv').value;
    let valid = true;

    if (num.length < 16) {
        document.getElementById('cardNumError').textContent = 'Please enter a valid 16-digit card number';
        document.getElementById('cardNumber').classList.add('is-invalid');
        valid = false;
    } else {
        document.getElementById('cardNumber').classList.remove('is-invalid');
    }

    if (expiry.length < 5) {
        document.getElementById('expiryError').textContent = 'Please enter expiry as MM/YY';
        document.getElementById('cardExpiry').classList.add('is-invalid');
        valid = false;
    } else {
        const [mm, yy] = expiry.split('/').map(Number);
        const now = new Date();
        if (mm < 1 || mm > 12 || (2000 + yy) < now.getFullYear() || ((2000+yy) === now.getFullYear() && mm < now.getMonth()+1)) {
            document.getElementById('expiryError').textContent = 'Card has expired';
            document.getElementById('cardExpiry').classList.add('is-invalid');
            valid = false;
        } else {
            document.getElementById('cardExpiry').classList.remove('is-invalid');
        }
    }

    if (cvv.length < 3) {
        document.getElementById('cvvError').textContent = 'CVV must be 3 or 4 digits';
        document.getElementById('cardCvv').classList.add('is-invalid');
        valid = false;
    } else {
        document.getElementById('cardCvv').classList.remove('is-invalid');
    }

    if (!name) {
        document.getElementById('cardName').classList.add('is-invalid');
        valid = false;
    } else {
        document.getElementById('cardName').classList.remove('is-invalid');
    }

    return valid;
}

function validateUpi() {
    const upi = document.getElementById('upiId').value.trim();
    const upiRegex = /^[\w.-]+@[\w.-]+$/;
    if (!upiRegex.test(upi)) {
        document.getElementById('upiError').textContent = 'Enter a valid UPI ID (e.g. name@upi)';
        document.getElementById('upiId').classList.add('is-invalid');
        return false;
    }
    document.getElementById('upiId').classList.remove('is-invalid');
    return true;
}

function processPayment() {
    const address = document.getElementById('deliveryAddress').value.trim();
    if (!address) {
        document.getElementById('deliveryAddress').classList.add('is-invalid');
        showToast('Please enter delivery address', 'warning');
        document.getElementById('deliveryAddress').scrollIntoView({behavior:'smooth'});
        return;
    }
    document.getElementById('deliveryAddress').classList.remove('is-invalid');

    // Validate payment details
    if (activeTab === 'card' && !validateCard()) {
        showToast('Please fix payment details', 'danger');
        return;
    }
    if (activeTab === 'upi' && !validateUpi()) {
        showToast('Please enter a valid UPI ID', 'danger');
        return;
    }

    // Set hidden form values
    document.getElementById('hiddenAddress').value = address;
    document.getElementById('hiddenPaymentMethod').value = activeTab;

    // Show overlay
    document.getElementById('paymentOverlay').style.display = 'flex';

    // Simulate payment processing delay
    setTimeout(() => {
        sessionStorage.removeItem('coupon');
        sessionStorage.removeItem('discount');
        document.getElementById('orderForm').submit();
    }, 2500);
}
</script>
</body>
</html>
