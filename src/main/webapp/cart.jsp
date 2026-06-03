<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?redirect=cart");
        return;
    }
    int userId = (int) session.getAttribute("userId");
    double subtotal = 0;
    double deliveryFee = 40.0;
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="View your cart and proceed to checkout on SwadhaFood.">
    <title>My Cart – SwadhaFood</title>
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
            <h1 class="page-hero-title">🛒 My Cart</h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb sf-breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                    <li class="breadcrumb-item active">Cart</li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container">
        <%
            // Fetch alerts
            String emptyParam = request.getParameter("empty");
            if ("true".equals(emptyParam)) { %>
        <div class="alert alert-warning"><i class="bi bi-exclamation-triangle me-2"></i>Your cart is empty. Please add items before proceeding.</div>
        <% } %>

        <div class="row gy-4">
            <!-- Cart Items -->
            <div class="col-lg-8">
                <%
                    int cartRowCount = 0;
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT c.id AS cart_id, c.quantity, f.id AS food_id, f.name, f.price, f.description, f.is_veg, r.name AS restaurant_name " +
                                     "FROM cart c " +
                                     "JOIN foods f ON c.food_id = f.id " +
                                     "JOIN restaurants r ON f.restaurant_id = r.id " +
                                     "WHERE c.user_id = ? ORDER BY c.added_at";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setInt(1, userId);
                        ResultSet rs = ps.executeQuery();
                        String lastRestaurant = "";
                %>
                <div class="empty-cart-container text-center py-5" id="emptyCartDiv" style="display: none;">
                    <div class="empty-cart-icon">🛒</div>
                    <h4 class="mt-3">Your cart is empty!</h4>
                    <p class="text-muted">Looks like you haven't added anything yet.</p>
                    <a href="restaurants.jsp" class="btn btn-primary-sf btn-lg mt-2">
                        <i class="bi bi-shop me-2"></i>Browse Restaurants
                    </a>
                </div>

                <div id="cartItemsList">
                <% if (!rs.next()) { %>
                <script>document.getElementById('emptyCartDiv').style.display = 'block';</script>
                <%
                    } else {
                        // Move cursor back – rs.next() was already called
                        // We need to iterate; the first row is already at rs
                        do {
                            cartRowCount++;
                            double itemTotal = rs.getDouble("price") * rs.getInt("quantity");
                            subtotal += itemTotal;
                            String restName = rs.getString("restaurant_name");
                            boolean isVeg = rs.getBoolean("is_veg");
                %>
                <% if (!restName.equals(lastRestaurant)) {
                    lastRestaurant = restName; %>
                <div class="cart-restaurant-header">
                    <i class="bi bi-shop-window me-2"></i><%= restName %>
                </div>
                <% } %>
                <div class="cart-item-card" id="cart-item-<%= rs.getInt("food_id") %>" data-food-id="<%= rs.getInt("food_id") %>" data-price="<%= rs.getDouble("price") %>" data-name="<%= rs.getString("name") %>">
                    <div class="cart-item-veg-dot <%= isVeg ? "veg" : "non-veg" %>"></div>
                    <div class="cart-item-info">
                        <h6 class="cart-item-name"><%= rs.getString("name") %></h6>
                        <% String desc = rs.getString("description");
                           if (desc != null && !desc.isEmpty()) { %>
                        <p class="cart-item-desc"><%= desc.length() > 60 ? desc.substring(0, 60) + "..." : desc %></p>
                        <% } %>
                        <p class="cart-item-unit-price"><i class="bi bi-currency-rupee"></i><%= String.format("%.0f", rs.getDouble("price")) %> per item</p>
                    </div>
                    <div class="cart-item-controls">
                        <div class="qty-controls-lg">
                            <form action="CartServlet" method="POST" class="d-inline qty-form qty-form-dec">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="foodId" value="<%= rs.getInt("food_id") %>">
                                <input type="hidden" name="quantity" class="qty-input-val" value="<%= rs.getInt("quantity") - 1 %>">
                                <button type="submit" class="qty-btn-lg btn-qty-dec">-</button>
                            </form>
                            <span class="qty-value"><%= rs.getInt("quantity") %></span>
                            <form action="CartServlet" method="POST" class="d-inline qty-form qty-form-inc">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="foodId" value="<%= rs.getInt("food_id") %>">
                                <input type="hidden" name="quantity" class="qty-input-val" value="<%= rs.getInt("quantity") + 1 %>">
                                <button type="submit" class="qty-btn-lg btn-qty-inc">+</button>
                            </form>
                        </div>
                        <p class="cart-item-total">₹<span class="cart-item-total-val"><%= String.format("%.0f", itemTotal) %></span></p>
                        <form action="CartServlet" method="POST" class="d-inline qty-form qty-form-remove">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="foodId" value="<%= rs.getInt("food_id") %>">
                            <button type="submit" class="btn btn-remove btn-remove-item" title="Remove item">
                                <i class="bi bi-trash3"></i>
                            </button>
                        </form>
                    </div>
                </div>
                <%      } while (rs.next());
                    }
                %>
                </div>
                <%  } catch (Exception e) { %>
                <div class="alert alert-danger">DB Error: <%= e.getMessage() %></div>
                <% } %>

                <!-- Coupon Section -->
                <% if (cartRowCount > 0) { %>
                <div class="coupon-section mt-4">
                    <h6><i class="bi bi-tag-fill me-2 text-primary"></i>Apply Coupon</h6>
                    <div class="coupon-input-wrap">
                        <input type="text" class="form-control sf-input" id="couponInput"
                               placeholder="Enter coupon code (e.g. SWADHA20)">
                        <button class="btn btn-coupon" onclick="applyCoupon()">Apply</button>
                    </div>
                    <div id="couponMsg" class="mt-2 small"></div>
                </div>
                <% } %>
            </div>

            <!-- Order Summary -->
            <div class="col-lg-4">
                <div class="order-summary-card sticky-top">
                    <h5 class="order-summary-title"><i class="bi bi-receipt me-2"></i>Order Summary</h5>
                    <div class="order-summary-rows">
                        <div class="summary-row">
                            <span>Subtotal (<span id="summaryItemCount"><%= cartRowCount %></span> items)</span>
                            <span>₹<span id="subtotalDisp"><%= String.format("%.0f", subtotal) %></span></span>
                        </div>
                        <div class="summary-row">
                            <span>Delivery Fee</span>
                            <span><% if (subtotal == 0) { %>-<% } else { %>₹<%= String.format("%.0f", deliveryFee) %><% } %></span>
                        </div>
                        <div class="summary-row coupon-discount-row" id="discountRow" style="display:none; color:var(--color-success)">
                            <span>Coupon Discount</span>
                            <span>- ₹<span id="discountAmt">0</span></span>
                        </div>
                        <hr class="summary-divider">
                        <div class="summary-row summary-total">
                            <strong>Total Amount</strong>
                            <strong>₹<span id="totalDisp"><%= String.format("%.0f", subtotal > 0 ? subtotal + deliveryFee : 0) %></span></strong>
                        </div>
                    </div>
                    <% if (cartRowCount > 0) { %>
                    <a href="payment.jsp" class="btn btn-primary-sf w-100 mt-3 btn-lg" id="proceedBtn">
                        <i class="bi bi-lock me-2"></i>Proceed to Payment
                    </a>
                    <p class="text-center text-muted small mt-2"><i class="bi bi-shield-check me-1"></i>Secured 256-bit encryption</p>
                    <% } else { %>
                    <a href="restaurants.jsp" class="btn btn-primary-sf w-100 mt-3">
                        <i class="bi bi-shop me-2"></i>Start Ordering
                    </a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="footer.jsp" %>
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
<script>
const VALID_COUPONS = {
    'SWADHA20': 20,
    'FREEDEL': 0,  // free delivery
    'SAVE50': 50
};

let appliedDiscount = 0;
let currentSubtotal = <%= subtotal %>;
const deliveryFee  = <%= deliveryFee %>;

function applyCoupon() {
    const code = document.getElementById('couponInput').value.trim().toUpperCase();
    const msgEl = document.getElementById('couponMsg');
    if (!code) { msgEl.innerHTML = '<span class="text-danger">Please enter a coupon code.</span>'; return; }

    if (VALID_COUPONS.hasOwnProperty(code)) {
        appliedDiscount = VALID_COUPONS[code];
        document.getElementById('discountRow').style.display = '';
        document.getElementById('discountAmt').textContent = appliedDiscount;
        updateTotal();
        msgEl.innerHTML = '<span class="text-success"><i class="bi bi-check-circle me-1"></i>Coupon applied! You save ₹' + appliedDiscount + '</span>';
        showToast('Coupon ' + code + ' applied!', 'success');
        // Store for payment page
        sessionStorage.setItem('coupon', code);
        sessionStorage.setItem('discount', appliedDiscount);
    } else {
        msgEl.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Invalid coupon code.</span>';
        appliedDiscount = 0;
        document.getElementById('discountRow').style.display = 'none';
        updateTotal();
    }
}

function applyCouponSilent() {
    const code = document.getElementById('couponInput').value.trim().toUpperCase();
    if (VALID_COUPONS.hasOwnProperty(code)) {
        appliedDiscount = VALID_COUPONS[code];
        document.getElementById('discountRow').style.display = '';
        document.getElementById('discountAmt').textContent = appliedDiscount;
        sessionStorage.setItem('coupon', code);
        sessionStorage.setItem('discount', appliedDiscount);
    } else {
        appliedDiscount = 0;
        document.getElementById('discountRow').style.display = 'none';
        sessionStorage.removeItem('coupon');
        sessionStorage.removeItem('discount');
    }
    updateTotal();
}

function updateTotal() {
    const total = Math.max(0, currentSubtotal + (currentSubtotal > 0 ? deliveryFee : 0) - appliedDiscount);
    document.getElementById('totalDisp').textContent = total.toFixed(0);
}

// Attach coupon from previous session
const savedCoupon = sessionStorage.getItem('coupon');
if (savedCoupon) {
    document.getElementById('couponInput').value = savedCoupon;
    applyCouponSilent();
}

document.addEventListener('DOMContentLoaded', () => {
    setupCartAjax();
});

function setupCartAjax() {
    // Intercept quantity updates
    document.querySelectorAll('.qty-form-dec, .qty-form-inc').forEach(form => {
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const card = form.closest('.cart-item-card');
            const foodId = card.getAttribute('data-food-id');
            const price = parseFloat(card.getAttribute('data-price'));
            const name = card.getAttribute('data-name');
            const action = form.querySelector('input[name="action"]').value;
            const newQty = parseInt(form.querySelector('input[name="quantity"]').value);

            performCartAjax(action, foodId, newQty, price, name, card);
        });
    });

    // Intercept removals
    document.querySelectorAll('.qty-form-remove').forEach(form => {
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const card = form.closest('.cart-item-card');
            const foodId = card.getAttribute('data-food-id');
            const name = card.getAttribute('data-name');

            performCartAjax('remove', foodId, 0, 0, name, card);
        });
    });
}

function performCartAjax(action, foodId, quantity, price, name, card) {
    const params = new URLSearchParams();
    params.append('action', action);
    params.append('foodId', foodId);
    params.append('quantity', quantity);
    params.append('format', 'fetch');

    card.style.opacity = '0.7';

    fetch('CartServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: params.toString()
    })
    .then(response => response.json())
    .then(data => {
        card.style.opacity = '1';
        if (data && data.success) {
            if (action === 'remove' || quantity <= 0) {
                animateRemoveCard(card, price);
                showToast(`${name} removed from cart.`, 'info');
            } else {
                const oldQtyVal = parseInt(card.querySelector('.qty-value').textContent);
                const diff = quantity - oldQtyVal;
                
                card.querySelector('.qty-value').textContent = quantity;
                card.querySelector('.cart-item-total-val').textContent = (price * quantity).toFixed(0);
                
                card.querySelector('.qty-form-dec .qty-input-val').value = quantity - 1;
                card.querySelector('.qty-form-inc .qty-input-val').value = quantity + 1;
                
                currentSubtotal += (diff * price);
                recalculateSummary();
                showToast(`Updated quantity of ${name} to ${quantity}.`, 'success');
            }
            updateNavbarBadge();
        } else {
            showToast('Failed to update cart. Please try again.', 'danger');
        }
    })
    .catch(err => {
        card.style.opacity = '1';
        console.error('Cart sync error:', err);
        showToast('Connection error. Could not sync cart.', 'danger');
    });
}

function animateRemoveCard(card, price) {
    const qty = parseInt(card.querySelector('.qty-value').textContent);
    currentSubtotal -= (qty * price);
    
    card.classList.add('removing');
    
    setTimeout(() => {
        card.remove();
        
        const remainingItems = document.querySelectorAll('.cart-item-card');
        if (remainingItems.length === 0) {
            document.getElementById('cartItemsList').style.display = 'none';
            if (document.querySelector('.coupon-section')) document.querySelector('.coupon-section').style.display = 'none';
            document.getElementById('emptyCartDiv').style.display = 'block';
            
            const proceedBtn = document.getElementById('proceedBtn');
            if (proceedBtn) {
                proceedBtn.outerHTML = `<a href="restaurants.jsp" class="btn btn-primary-sf w-100 mt-3"><i class="bi bi-shop me-2"></i>Start Ordering</a>`;
            }
        }
        
        cleanEmptyRestaurantHeaders();
        recalculateSummary();
    }, 400); // 0.4s transition
}

function cleanEmptyRestaurantHeaders() {
    const headers = document.querySelectorAll('.cart-restaurant-header');
    headers.forEach(header => {
        let sibling = header.nextElementSibling;
        let hasItems = false;
        while (sibling && !sibling.classList.contains('cart-restaurant-header') && !sibling.classList.contains('coupon-section') && sibling.id !== 'emptyCartDiv') {
            if (sibling.classList.contains('cart-item-card') && !sibling.classList.contains('removing')) {
                hasItems = true;
                break;
            }
            sibling = sibling.nextElementSibling;
        }
        if (!hasItems) {
            header.remove();
        }
    });
}

function recalculateSummary() {
    document.getElementById('subtotalDisp').textContent = currentSubtotal.toFixed(0);
    
    let totalItems = 0;
    document.querySelectorAll('.cart-item-card').forEach(card => {
        if (!card.classList.contains('removing')) {
            totalItems += parseInt(card.querySelector('.qty-value').textContent);
        }
    });
    const summaryItemCountEl = document.getElementById('summaryItemCount');
    if (summaryItemCountEl) summaryItemCountEl.textContent = totalItems;
    
    const feeEl = document.getElementById('subtotalDisp').closest('.order-summary-rows').querySelector('.summary-row:nth-child(2) span');
    if (currentSubtotal === 0) {
        if (feeEl) feeEl.textContent = '-';
    } else {
        if (feeEl) feeEl.textContent = '₹' + deliveryFee;
    }
    
    if (appliedDiscount > 0) {
        applyCouponSilent();
    } else {
        updateTotal();
    }
}

function updateNavbarBadge() {
    let totalItems = 0;
    document.querySelectorAll('.cart-item-card').forEach(card => {
        if (!card.classList.contains('removing')) {
            totalItems += parseInt(card.querySelector('.qty-value').textContent);
        }
    });
    
    const badge = document.getElementById('navCartBadge');
    if (badge) {
        if (totalItems > 0) {
            badge.textContent = totalItems;
            badge.style.display = 'inline-block';
        } else {
            badge.style.display = 'none';
        }
    }
}
</script>
</body>
</html>
