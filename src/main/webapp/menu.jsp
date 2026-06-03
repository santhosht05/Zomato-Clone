<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    int restaurantId = 0;
    try { restaurantId = Integer.parseInt(request.getParameter("restaurantId")); } catch (Exception e) {}
    if (restaurantId == 0) { response.sendRedirect("restaurants.jsp"); return; }

    String restaurantName = ""; String cuisine = ""; double rating = 0; String deliveryTime = "";
    int minPrice = 0; String description = ""; String address = ""; String restaurantImageUrl = "";

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM restaurants WHERE id = ?");
        ps.setInt(1, restaurantId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            restaurantName = rs.getString("name");
            cuisine = rs.getString("cuisine");
            rating = rs.getDouble("rating");
            deliveryTime = rs.getString("delivery_time");
            minPrice = rs.getInt("min_price");
            description = rs.getString("description");
            address = rs.getString("address") != null ? rs.getString("address") : "";
            restaurantImageUrl = rs.getString("image_url") != null ? rs.getString("image_url") : "";
        } else { response.sendRedirect("restaurants.jsp"); return; }
    } catch (Exception e) {}

    int loggedUserId = (session != null && session.getAttribute("userId") != null) ? (int) session.getAttribute("userId") : 0;

    // Load active cart for the user to pre-populate cartState in javascript
    String cartJson = "{}";
    if (loggedUserId > 0) {
        try (Connection conn = DBConnection.getConnection()) {
            String cartQuery = "SELECT c.food_id, c.quantity, f.name, f.price, f.restaurant_id, r.name AS rname " +
                               "FROM cart c JOIN foods f ON c.food_id = f.id " +
                               "JOIN restaurants r ON f.restaurant_id = r.id " +
                               "WHERE c.user_id = ?";
            PreparedStatement ps = conn.prepareStatement(cartQuery);
            ps.setInt(1, loggedUserId);
            ResultSet rs = ps.executeQuery();
            StringBuilder sb = new StringBuilder("{");
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                first = false;
                sb.append("\"").append(rs.getInt("food_id")).append("\":{");
                sb.append("\"name\":\"").append(rs.getString("name").replace("\"", "\\\"")).append("\",");
                sb.append("\"price\":").append(rs.getDouble("price")).append(",");
                sb.append("\"qty\":").append(rs.getInt("quantity")).append(",");
                sb.append("\"restaurantId\":").append(rs.getInt("restaurant_id")).append(",");
                sb.append("\"restaurantName\":\"").append(rs.getString("rname").replace("\"", "\\\"")).append("\"");
                sb.append("}");
            }
            sb.append("}");
            cartJson = sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Order from <%= restaurantName %> on SwadhaFood - Browse their menu and add to cart.">
    <title><%= restaurantName %> – SwadhaFood</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>

<main class="main-content">
    <!-- Restaurant Header -->
    <div class="restaurant-hero">
        <div class="restaurant-hero-bg" style="<%= !restaurantImageUrl.isEmpty() ? "background-image: linear-gradient(to bottom, rgba(0,0,0,0.3), rgba(0,0,0,0.8)), url('" + restaurantImageUrl + "'); background-size: cover; background-position: center; filter: none;" : "" %>"></div>
        <div class="container restaurant-hero-content">
            <nav aria-label="breadcrumb" class="mb-3">
                <ol class="breadcrumb sf-breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                    <li class="breadcrumb-item"><a href="restaurants.jsp">Restaurants</a></li>
                    <li class="breadcrumb-item active"><%= restaurantName %></li>
                </ol>
            </nav>
            <div class="d-flex align-items-start gap-4 flex-wrap">
                <div class="restaurant-hero-logo" style="padding: 0; overflow: hidden; display: flex; align-items: center; justify-content: center; width: 100px; height: 100px; border-radius: 12px; background: #fff; box-shadow: 0 4px 15px rgba(0,0,0,0.15);">
                    <% if (!restaurantImageUrl.isEmpty()) { %>
                        <img src="<%= restaurantImageUrl %>" style="width: 100%; height: 100%; object-fit: cover;" alt="<%= restaurantName %>">
                    <% } else {
                        String[] emojis2 = {"🍛","🍕","🍚","🥟","🍔","🫓","🥩","🍰"};
                        out.print("<span style='font-size: 3rem;'>" + emojis2[(restaurantId - 1) % emojis2.length] + "</span>");
                    } %>
                </div>
                <div class="restaurant-hero-info">
                    <h1 class="restaurant-hero-name"><%= restaurantName %></h1>
                    <p class="restaurant-hero-cuisine"><%= cuisine %></p>
                    <% if (!description.isEmpty()) { %><p class="restaurant-hero-desc"><%= description %></p><% } %>
                    <div class="restaurant-hero-meta">
                        <span class="hero-meta-badge"><i class="bi bi-star-fill text-warning me-1"></i><%= String.format("%.1f", rating) %> Rating</span>
                        <span class="hero-meta-badge"><i class="bi bi-clock me-1"></i><%= deliveryTime %></span>
                        <span class="hero-meta-badge"><i class="bi bi-currency-rupee"></i><%= minPrice %> for two</span>
                        <% if (!address.isEmpty()) { %><span class="hero-meta-badge"><i class="bi bi-geo-alt me-1"></i><%= address %></span><% } %>
                    </div>
                </div>
                <% if (loggedUserId > 0) { %>
                <div class="ms-auto">
                    <form action="FavoriteServlet" method="POST">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                        <input type="hidden" name="redirect" value="menu.jsp?restaurantId=<%= restaurantId %>">
                        <button type="submit" class="btn btn-outline-danger">
                            <i class="bi bi-heart me-2"></i>Save to Favourites
                        </button>
                    </form>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <div class="container mt-4">
        <div class="row">
            <!-- Menu Section -->
            <div class="col-lg-8">
                <!-- Category Tabs -->
                <div class="menu-category-tabs mb-4" id="menuTabs"></div>

                <!-- Food Items -->
                <div id="menuSections">
                <%
                    try (Connection conn = DBConnection.getConnection()) {
                        // Get distinct categories
                        PreparedStatement catPs = conn.prepareStatement(
                            "SELECT DISTINCT category FROM foods WHERE restaurant_id = ? AND is_available = 1 ORDER BY category");
                        catPs.setInt(1, restaurantId);
                        ResultSet catRs = catPs.executeQuery();
                        java.util.List<String> categories = new java.util.ArrayList<>();
                        while (catRs.next()) categories.add(catRs.getString("category"));

                        for (String cat : categories) {
                            PreparedStatement fPs = conn.prepareStatement(
                                "SELECT * FROM foods WHERE restaurant_id = ? AND category = ? AND is_available = 1");
                            fPs.setInt(1, restaurantId);
                            fPs.setString(2, cat);
                            ResultSet fRs = fPs.executeQuery();
                %>
                    <div class="menu-section" id="cat-<%= cat.replace(" ","_") %>">
                        <h3 class="menu-section-title"><%= cat %></h3>
                        <div class="menu-items">
                        <% while (fRs.next()) {
                            boolean isVeg = fRs.getBoolean("is_veg");
                        %>
                            <div class="menu-item-card">
                                <div class="menu-item-body">
                                    <div class="menu-item-veg-indicator <%= isVeg ? "veg" : "non-veg" %>">
                                        <div class="veg-dot"></div>
                                    </div>
                                    <h5 class="menu-item-name"><%= fRs.getString("name") %></h5>
                                    <p class="menu-item-price"><i class="bi bi-currency-rupee"></i><%= String.format("%.0f", fRs.getDouble("price")) %></p>
                                    <% String desc = fRs.getString("description");
                                       if (desc != null && !desc.isEmpty()) { %>
                                    <p class="menu-item-desc"><%= desc %></p>
                                    <% } %>
                                </div>
                                <div class="menu-item-actions">
                                    <%
                                        String foodImageUrl = fRs.getString("image_url");
                                        if (foodImageUrl != null && !foodImageUrl.trim().isEmpty()) {
                                    %>
                                        <div class="menu-item-img-wrap" style="width: 96px; height: 96px; border-radius: 12px; overflow: hidden; margin-bottom: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.08); border: 1px solid var(--color-border);">
                                            <img src="<%= foodImageUrl %>" style="width: 100%; height: 100%; object-fit: cover;" alt="<%= fRs.getString("name") %>">
                                        </div>
                                    <% } else { %>
                                        <div class="menu-item-emoji" style="font-size: 2.2rem; margin-bottom: 8px;"><%= isVeg ? "🌿" : "🍖" %></div>
                                    <% } %>
                                    <% if (loggedUserId > 0) { %>
                                    <div class="quantity-control" id="qty-ctrl-<%= fRs.getInt("id") %>" style="display:none">
                                        <button class="qty-btn" onclick="decreaseQty(<%= fRs.getInt("id") %>, <%= fRs.getDouble("price") %>)">-</button>
                                        <span class="qty-display" id="qty-<%= fRs.getInt("id") %>">1</span>
                                        <button class="qty-btn" onclick="increaseQty(<%= fRs.getInt("id") %>)">+</button>
                                    </div>
                                    <button class="btn btn-add-cart" id="add-btn-<%= fRs.getInt("id") %>"
                                            onclick="addToCart(<%= fRs.getInt("id") %>, '<%= fRs.getString("name").replace("'", "\\'") %>', <%= fRs.getDouble("price") %>)">
                                        <i class="bi bi-plus me-1"></i>ADD
                                    </button>
                                    <% } else { %>
                                    <a href="login.jsp" class="btn btn-add-cart">
                                        <i class="bi bi-plus me-1"></i>ADD
                                    </a>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                        </div>
                    </div>
                <% }
                    } catch (Exception e) { %>
                <div class="alert alert-danger">DB Error: <%= e.getMessage() %></div>
                <% } %>
                </div>
            </div>

            <!-- Cart Sidebar -->
            <div class="col-lg-4">
                <div class="cart-sidebar sticky-top" id="cartSidebar">
                    <div class="cart-sidebar-header">
                        <h5><i class="bi bi-bag me-2"></i>Your Order</h5>
                        <span class="cart-item-count" id="sidebarItemCount">0 items</span>
                    </div>
                    <div id="cartSidebarItems" class="cart-sidebar-items">
                        <div class="cart-empty-state" id="cartEmptyState">
                            <div class="text-center py-4">
                                <div class="cart-empty-icon">🛒</div>
                                <p class="text-muted mt-2">Your cart is empty<br><small>Add items to get started</small></p>
                            </div>
                        </div>
                    </div>
                    <div class="cart-sidebar-footer" id="cartSidebarFooter" style="display:none">
                        <div class="cart-subtotal">
                            <span>Subtotal</span>
                            <span id="sidebarSubtotal">₹0</span>
                        </div>
                        <div class="cart-delivery">
                            <span>Delivery Fee</span>
                            <span>₹40</span>
                        </div>
                        <div class="cart-total">
                            <span><strong>Total</strong></span>
                            <span id="sidebarTotal"><strong>₹40</strong></span>
                        </div>
                        <a href="CartServlet" class="btn btn-primary-sf w-100 mt-3">
                            <i class="bi bi-bag-check me-2"></i>View Full Cart
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Replace Cart Confirmation Modal -->
<div class="modal fade sf-modal-overlay" id="replaceCartModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="replaceCartModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content sf-modal-content">
            <div class="modal-header sf-modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="replaceCartModalLabel">Replace cart items?</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body sf-modal-body py-3">
                <p class="mb-0 text-muted" id="replaceCartModalMessage">
                    Your cart contains dishes from <strong id="oldRestaurantName" class="text-danger"></strong>. 
                    Do you want to discard these dishes and start a new order from <strong id="newRestaurantName" class="text-success"></strong>?
                </p>
            </div>
            <div class="modal-footer sf-modal-footer border-0 pt-0 gap-2">
                <button type="button" class="btn btn-outline-secondary px-4 py-2 border-0" data-bs-dismiss="modal" style="border-radius: var(--border-radius-md); font-weight: 600;">No</button>
                <button type="button" class="btn btn-primary-sf px-4 py-2 m-0" id="btnReplaceCart" style="border-radius: var(--border-radius-md);">Replace & Add</button>
            </div>
        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
<script>
// Cart state pre-populated from database
const cartState = <%= cartJson %>;
const currentRestaurantId = <%= restaurantId %>;
const currentRestaurantName = `<%= restaurantName.replace("`", "\\`").replace("\"", "\\\"") %>`;

function syncCartOnServer(action, foodId, quantity) {
    const params = new URLSearchParams();
    params.append('action', action);
    params.append('foodId', foodId);
    params.append('quantity', quantity);
    params.append('format', 'fetch');
    
    fetch('CartServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: params.toString()
    })
    .then(response => {
        if (!response.ok) {
            console.error('Failed to sync cart on server');
        }
    })
    .catch(err => console.error('Error syncing cart:', err));
}

function getDifferentRestaurantInCart() {
    for (const [id, item] of Object.entries(cartState)) {
        if (item.restaurantId && item.restaurantId !== currentRestaurantId) {
            return {
                id: item.restaurantId,
                name: item.restaurantName || 'Another Restaurant'
            };
        }
    }
    return null;
}

function addToCart(foodId, name, price) {
    const diffRest = getDifferentRestaurantInCart();
    if (diffRest) {
        document.getElementById('oldRestaurantName').textContent = diffRest.name;
        document.getElementById('newRestaurantName').textContent = currentRestaurantName;
        
        const btnReplace = document.getElementById('btnReplaceCart');
        btnReplace.onclick = function() {
            clearCartAndAdd(foodId, name, price);
        };
        
        const modal = new bootstrap.Modal(document.getElementById('replaceCartModal'));
        modal.show();
        return;
    }
    
    executeAddToCart(foodId, name, price);
}

function clearCartAndAdd(foodId, name, price) {
    const btnReplace = document.getElementById('btnReplaceCart');
    if (btnReplace) btnReplace.disabled = true;
    
    const params = new URLSearchParams();
    params.append('action', 'clear');
    params.append('format', 'fetch');
    
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
        if (data && data.success) {
            // Purge local cartState
            for (const key in cartState) {
                delete cartState[key];
            }
            
            // Hide the modal
            const modalEl = document.getElementById('replaceCartModal');
            const modalInstance = bootstrap.Modal.getInstance(modalEl);
            if (modalInstance) modalInstance.hide();
            
            if (btnReplace) btnReplace.disabled = false;
            
            // Add new item
            executeAddToCart(foodId, name, price);
            showToast('Cart cleared and new order started!', 'success');
        } else {
            showToast('Failed to clear old cart. Please try again.', 'danger');
            if (btnReplace) btnReplace.disabled = false;
        }
    })
    .catch(err => {
        console.error('Error clearing cart:', err);
        showToast('Error clearing cart. Please try again.', 'danger');
        if (btnReplace) btnReplace.disabled = false;
    });
}

function executeAddToCart(foodId, name, price) {
    if (!cartState[foodId]) {
        cartState[foodId] = { name, price, qty: 1, restaurantId: currentRestaurantId, restaurantName: currentRestaurantName };
    }
    
    const qtyCtrl = document.getElementById('qty-ctrl-' + foodId);
    const addBtn = document.getElementById('add-btn-' + foodId);
    if (qtyCtrl && addBtn) {
        qtyCtrl.style.display = 'flex';
        addBtn.style.display = 'none';
        const qtyDisp = document.getElementById('qty-' + foodId);
        if (qtyDisp) qtyDisp.textContent = '1';
    }
    updateCartSidebar();

    syncCartOnServer('add', foodId, 1);
    showToast(name + ' added to cart!', 'success');
}

function increaseQty(foodId) {
    if (cartState[foodId]) {
        cartState[foodId].qty++;
        document.getElementById('qty-' + foodId).textContent = cartState[foodId].qty;
        updateCartSidebar();
        
        syncCartOnServer('update', foodId, cartState[foodId].qty);
    }
}

function decreaseQty(foodId, price) {
    if (cartState[foodId]) {
        cartState[foodId].qty--;
        const newQty = cartState[foodId].qty;
        if (newQty <= 0) {
            const name = cartState[foodId].name;
            delete cartState[foodId];
            document.getElementById('qty-ctrl-' + foodId).style.display = 'none';
            document.getElementById('add-btn-' + foodId).style.display = '';
            updateCartSidebar();
            
            syncCartOnServer('remove', foodId, 0);
            showToast(name + ' removed from cart!', 'info');
        } else {
            document.getElementById('qty-' + foodId).textContent = newQty;
            updateCartSidebar();
            
            syncCartOnServer('update', foodId, newQty);
        }
    }
}

function updateCartSidebar() {
    const items = Object.entries(cartState);
    const itemsDiv = document.getElementById('cartSidebarItems');
    const footer   = document.getElementById('cartSidebarFooter');
    const emptyDiv = document.getElementById('cartEmptyState');
    const countEl  = document.getElementById('sidebarItemCount');

    if (items.length === 0) {
        emptyDiv.style.display = '';
        footer.style.display = 'none';
        countEl.textContent = '0 items';
        
        const badge = document.getElementById('navCartBadge');
        if (badge) badge.style.display = 'none';
        
        return;
    }

    emptyDiv.style.display = 'none';
    footer.style.display = '';

    let html = '';
    let subtotal = 0;
    let totalQty = 0;
    items.forEach(([id, item]) => {
        const lineTotal = item.price * item.qty;
        subtotal += lineTotal;
        totalQty += item.qty;
        html += `<div class="cart-sidebar-item">
            <span class="csi-name">${item.name}</span>
            <span class="csi-qty">×${item.qty}</span>
            <span class="csi-price">₹${lineTotal.toFixed(0)}</span>
        </div>`;
    });

    itemsDiv.innerHTML = html;

    countEl.textContent = totalQty + ' item' + (totalQty > 1 ? 's' : '');
    document.getElementById('sidebarSubtotal').textContent = '₹' + subtotal.toFixed(0);
    document.getElementById('sidebarTotal').innerHTML = '<strong>₹' + (subtotal + 40).toFixed(0) + '</strong>';

    const badge = document.getElementById('navCartBadge');
    if (badge) {
        badge.textContent = totalQty;
        badge.style.display = 'inline-block';
    }
}

document.addEventListener("DOMContentLoaded", () => {
    Object.entries(cartState).forEach(([foodId, item]) => {
        const qtyCtrl = document.getElementById('qty-ctrl-' + foodId);
        const addBtn = document.getElementById('add-btn-' + foodId);
        const qtyDisp = document.getElementById('qty-' + foodId);
        if (qtyCtrl && addBtn && qtyDisp) {
            qtyCtrl.style.display = 'flex';
            addBtn.style.display = 'none';
            qtyDisp.textContent = item.qty;
        }
    });
    updateCartSidebar();
});

const sections = document.querySelectorAll('.menu-section');
const tabsContainer = document.getElementById('menuTabs');
sections.forEach(sec => {
    const catId  = sec.id;
    const catName = sec.querySelector('.menu-section-title').textContent;
    const btn = document.createElement('button');
    btn.className = 'menu-tab-btn';
    btn.textContent = catName;
    btn.onclick = () => {
        document.getElementById(catId).scrollIntoView({ behavior: 'smooth', block: 'start' });
    };
    tabsContainer.appendChild(btn);
});
</script>
</body>
</html>
