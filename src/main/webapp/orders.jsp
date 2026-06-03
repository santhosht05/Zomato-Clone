<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection, java.util.List, java.util.ArrayList" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = (int) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    
    String successParam = request.getParameter("success");
    String newOrderIdParam = request.getParameter("orderId");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="View your order history and track deliveries on SwadhaFood.">
    <title>My Orders – SwadhaFood</title>
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
            <h1 class="page-hero-title">📜 My Orders</h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb sf-breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                    <li class="breadcrumb-item active">Orders</li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container">
        <% if ("true".equals(successParam) && newOrderIdParam != null) { %>
        <div class="alert alert-success alert-dismissible fade show p-4 border-0 rounded-4 shadow-sm mb-4" role="alert">
            <div class="d-flex align-items-center">
                <span class="fs-1 me-3">🎉</span>
                <div>
                    <h5 class="alert-heading fw-bold mb-1">Order Placed Successfully!</h5>
                    <p class="mb-0 text-dark-emphasis">Thank you for your order! Your Order ID is <strong>#SF-<%= newOrderIdParam %></strong>. We have received your payment and our kitchen is starting to prepare your meal.</p>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <div class="row">
            <div class="col-lg-10 mx-auto">
                <%
                    int orderCount = 0;
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setInt(1, userId);
                            ResultSet rs = ps.executeQuery();

                            while (rs.next()) {
                                orderCount++;
                                int orderId = rs.getInt("id");
                                String restaurantName = rs.getString("restaurant_name");
                                double totalAmount = rs.getDouble("total_amount");
                                String payMethod = rs.getString("payment_method");
                                String payStatus = rs.getString("payment_status");
                                String delStatus = rs.getString("delivery_status");
                                String coupon = rs.getString("coupon_code");
                                double discount = rs.getDouble("discount");
                                Timestamp createdAt = rs.getTimestamp("created_at");
                                String delAddress = rs.getString("delivery_address");

                                // Compute Stepper Status
                                String s1 = "done", s2 = "", s3 = "", s4 = "", s5 = "";
                                String l1 = "done", l2 = "", l3 = "", l4 = "";

                                if ("placed".equals(delStatus)) {
                                    s1 = "active";
                                    l1 = "";
                                } else if ("confirmed".equals(delStatus)) {
                                    s1 = "done"; s2 = "active";
                                    l1 = "done"; l2 = "";
                                } else if ("preparing".equals(delStatus)) {
                                    s1 = "done"; s2 = "done"; s3 = "active";
                                    l1 = "done"; l2 = "done"; l3 = "";
                                } else if ("out_for_delivery".equals(delStatus)) {
                                    s1 = "done"; s2 = "done"; s3 = "done"; s4 = "active";
                                    l1 = "done"; l2 = "done"; l3 = "done"; l4 = "";
                                } else if ("delivered".equals(delStatus)) {
                                    s1 = "done"; s2 = "done"; s3 = "done"; s4 = "done"; s5 = "done";
                                    l1 = "done"; l2 = "done"; l3 = "done"; l4 = "done";
                                } else if ("cancelled".equals(delStatus)) {
                                    s1 = "cancelled"; s2 = "cancelled"; s3 = "cancelled"; s4 = "cancelled"; s5 = "cancelled";
                                }
                %>
                <!-- Order Card Box -->
                <div class="order-card-box">
                    <div class="order-header">
                        <div>
                            <span class="text-muted small">ORDER ID</span>
                            <h6 class="fw-bold mb-0">#SF-<%= orderId %></h6>
                            <small class="text-muted"><%= createdAt.toLocalDateTime().format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy · hh:mm a")) %></small>
                        </div>
                        <div class="text-end">
                            <span class="text-muted small">STATUS</span>
                            <div>
                                <span class="order-status-badge status-<%= delStatus %>">
                                    <%= delStatus.replace("_", " ").toUpperCase() %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Visual Stepper Progress Bar -->
                    <% if (!"cancelled".equals(delStatus)) { %>
                    <div class="delivery-stepper">
                        <div class="d-step <%= s1 %>">
                            <div class="d-step-circle"><i class="bi bi-cart"></i></div>
                            <span>Placed</span>
                            <div class="d-step-line <%= l1 %>"></div>
                        </div>
                        <div class="d-step <%= s2 %>">
                            <div class="d-step-circle"><i class="bi bi-check-circle"></i></div>
                            <span>Confirmed</span>
                            <div class="d-step-line <%= l2 %>"></div>
                        </div>
                        <div class="d-step <%= s3 %>">
                            <div class="d-step-circle"><i class="bi bi-fire"></i></div>
                            <span>Preparing</span>
                            <div class="d-step-line <%= l3 %>"></div>
                        </div>
                        <div class="d-step <%= s4 %>">
                            <div class="d-step-circle"><i class="bi bi-bicycle"></i></div>
                            <span>On The Way</span>
                            <div class="d-step-line <%= l4 %>"></div>
                        </div>
                        <div class="d-step <%= s5 %>">
                            <div class="d-step-circle"><i class="bi bi-house-heart"></i></div>
                            <span>Delivered</span>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="alert alert-secondary text-center rounded-3 border-0 py-3 mb-4">
                        <i class="bi bi-x-circle-fill text-danger me-2"></i>This order has been cancelled.
                    </div>
                    <% } %>

                    <!-- Order Details Grid -->
                    <div class="row pt-2 align-items-center">
                        <div class="col-md-7 border-md-end">
                            <h6 class="fw-bold mb-3"><i class="bi bi-shop-window text-danger me-2"></i><%= restaurantName != null ? restaurantName : "SwadhaFood Restaurant" %></h6>
                            
                            <!-- Items List -->
                            <div class="ps-1">
                                <%
                                    String itemSql = "SELECT * FROM order_items WHERE order_id = ?";
                                    try (PreparedStatement itemPs = conn.prepareStatement(itemSql)) {
                                        itemPs.setInt(1, orderId);
                                        ResultSet itemRs = itemPs.executeQuery();
                                        while (itemRs.next()) {
                                %>
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="small text-muted"><%= itemRs.getString("food_name") %> <strong class="text-dark-emphasis">x<%= itemRs.getInt("quantity") %></strong></span>
                                    <span class="small fw-semibold">₹<%= String.format("%.0f", itemRs.getDouble("subtotal")) %></span>
                                </div>
                                <%
                                        }
                                    }
                                %>
                            </div>

                            <% if (coupon != null && !coupon.isEmpty()) { %>
                            <div class="mt-3">
                                <span class="badge bg-success-subtle text-success p-2 rounded-2">
                                    <i class="bi bi-tag-fill me-1"></i>Coupon Applied: <strong><%= coupon %></strong> (-₹<%= String.format("%.0f", discount) %>)
                                </span>
                            </div>
                            <% } %>
                        </div>
                        
                        <div class="col-md-5 mt-3 mt-md-0 ps-md-4">
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted small">Payment Method</span>
                                <span class="fw-bold small text-uppercase"><%= payMethod %></span>
                            </div>
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted small">Payment Status</span>
                                <span class="badge <%= "paid".equals(payStatus) ? "bg-success" : "bg-warning" %> rounded-pill small"><%= payStatus.toUpperCase() %></span>
                            </div>
                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted small">Delivery Address</span>
                                <span class="text-truncate ps-3 small text-end text-muted" title="<%= delAddress %>" style="max-width:200px;"><%= delAddress %></span>
                            </div>
                            <hr class="my-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold">Total Paid</span>
                                <span class="fs-5 fw-extrabold text-primary">₹<%= String.format("%.0f", totalAmount) %></span>
                            </div>
                        </div>
                    </div>
                </div>
                <%
                            }
                        }
                    } catch (Exception e) {
                %>
                <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>DB Error: <%= e.getMessage() %></div>
                <%
                    }
                    if (orderCount == 0) {
                %>
                <div class="empty-state text-center py-5">
                    <div class="empty-icon">📜</div>
                    <h4 class="mt-3">No Orders Yet</h4>
                    <p class="text-muted">You haven't ordered anything yet. Let's change that!</p>
                    <a href="restaurants.jsp" class="btn btn-primary-sf btn-lg mt-2">
                        <i class="bi bi-shop me-2"></i>Order Now
                    </a>
                </div>
                <%
                    }
                %>
            </div>
        </div>
    </div>
</main>

<%@ include file="footer.jsp" %>
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
</body>
</html>
