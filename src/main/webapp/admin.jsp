<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    // Protection: verify user is logged in AND is an admin
    if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    String userName = (String) session.getAttribute("userName");
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.isEmpty()) activeTab = "restaurants"; // default tab
    
    String successMsg = request.getParameter("success");
    String errMsg = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="SwadhaFood Administrative Control Center.">
    <title>Admin Dashboard – SwadhaFood</title>
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
            <h1 class="page-hero-title">🛡️ Admin Dashboard</h1>
            <p class="text-white-50">Manage your restaurants, food items, order logs, and users.</p>
        </div>
    </div>

    <div class="container">
        <!-- Error & Success Messages -->
        <% if (successMsg != null) { %>
        <div class="alert alert-success alert-dismissible fade show border-0 rounded-3 shadow-sm mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i><%= successMsg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>
        <% if (errMsg != null) { %>
        <div class="alert alert-danger alert-dismissible fade show border-0 rounded-3 shadow-sm mb-4" role="alert">
            <i class="bi bi-exclamation-octagon-fill me-2"></i><%= errMsg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <!-- Stats Grid Block -->
        <%
            int totalRestaurants = 0;
            int totalFoods = 0;
            int totalOrders = 0;
            int totalUsers = 0;
            double grossRevenue = 0;

            try (Connection conn = DBConnection.getConnection()) {
                // Fetch stats
                try (Statement stmt = conn.createStatement()) {
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM restaurants");
                    if (rs.next()) totalRestaurants = rs.getInt(1);
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) FROM foods");
                    if (rs.next()) totalFoods = rs.getInt(1);

                    rs = stmt.executeQuery("SELECT COUNT(*), COALESCE(SUM(total_amount),0) FROM orders WHERE payment_status = 'paid'");
                    if (rs.next()) {
                        totalOrders = rs.getInt(1);
                        grossRevenue = rs.getDouble(2);
                    }

                    rs = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'user'");
                    if (rs.next()) totalUsers = rs.getInt(1);
                }
            } catch (Exception ignored) {}
        %>
        <div class="row g-3 mb-4">
            <div class="col-lg-3 col-sm-6">
                <div class="admin-stat-card">
                    <div class="admin-stat-icon"><i class="bi bi-shop"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0"><%= totalRestaurants %></h4>
                        <span class="text-muted small">Restaurants</span>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6">
                <div class="admin-stat-card">
                    <div class="admin-stat-icon"><i class="bi bi-egg-fried"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0"><%= totalFoods %></h4>
                        <span class="text-muted small">Menu Items</span>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6">
                <div class="admin-stat-card">
                    <div class="admin-stat-icon"><i class="bi bi-cart-check"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0"><%= totalOrders %></h4>
                        <span class="text-muted small">Completed Orders</span>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-sm-6">
                <div class="admin-stat-card">
                    <div class="admin-stat-icon"><i class="bi bi-currency-rupee"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0">₹<%= String.format("%.0f", grossRevenue) %></h4>
                        <span class="text-muted small">Gross Revenue</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Admin Control Tabs -->
        <div class="admin-tab-nav">
            <a href="admin.jsp?tab=restaurants" class="admin-tab-btn <%= "restaurants".equals(activeTab) ? "active" : "" %>">
                <i class="bi bi-shop me-2"></i>Restaurants
            </a>
            <a href="admin.jsp?tab=foods" class="admin-tab-btn <%= "foods".equals(activeTab) ? "active" : "" %>">
                <i class="bi bi-egg-fried me-2"></i>Food Menu
            </a>
            <a href="admin.jsp?tab=orders" class="admin-tab-btn <%= "orders".equals(activeTab) ? "active" : "" %>">
                <i class="bi bi-receipt me-2"></i>Orders Logs
            </a>
            <a href="admin.jsp?tab=users" class="admin-tab-btn <%= "users".equals(activeTab) ? "active" : "" %>">
                <i class="bi bi-people me-2"></i>Users
            </a>
        </div>

        <!-- Contents per tab -->
        <div class="tab-content mt-2">
            
            <!-- Tab 1: Restaurants -->
            <% if ("restaurants".equals(activeTab)) { %>
            <div class="row gy-4">
                <div class="col-lg-8">
                    <div class="admin-table-wrap">
                        <table class="table admin-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Cuisine</th>
                                    <th>Rating</th>
                                    <th>Price</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DBConnection.getConnection()) {
                                        PreparedStatement ps = conn.prepareStatement("SELECT * FROM restaurants ORDER BY id DESC");
                                        ResultSet rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int id = rs.getInt("id");
                                %>
                                <tr>
                                    <td class="fw-bold">#<%= id %></td>
                                    <td class="fw-semibold"><%= rs.getString("name") %></td>
                                    <td><%= rs.getString("cuisine") %></td>
                                    <td><i class="bi bi-star-fill text-warning me-1"></i><%= rs.getDouble("rating") %></td>
                                    <td>₹<%= rs.getInt("min_price") %></td>
                                    <td>
                                        <form action="AdminServlet" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this restaurant and all its food items?')">
                                            <input type="hidden" name="action" value="deleteRestaurant">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="bi bi-trash3 me-1"></i>Delete
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                %>
                                <tr><td colspan="6" class="text-danger">DB Error: <%= e.getMessage() %></td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Add Restaurant Sidebar Form -->
                <div class="col-lg-4">
                    <div class="admin-modal-card">
                        <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle-fill text-primary me-2"></i>Add Restaurant</h5>
                        <form action="AdminServlet" method="POST">
                            <input type="hidden" name="action" value="addRestaurant">
                            
                            <div class="mb-3">
                                <label class="form-label">Restaurant Name</label>
                                <input type="text" class="form-control sf-input" name="name" placeholder="Spice Garden" required>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Cuisine (comma separated)</label>
                                <input type="text" class="form-control sf-input" name="cuisine" placeholder="North Indian, Chinese" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Image URL (Optional)</label>
                                <input type="text" class="form-control sf-input" name="imageUrl" placeholder="http://example.com/img.jpg">
                            </div>

                            <div class="row g-2">
                                <div class="col-6 mb-3">
                                    <label class="form-label">Initial Rating</label>
                                    <input type="number" step="0.1" min="1" max="5" class="form-control sf-input" name="rating" value="4.0" required>
                                </div>
                                <div class="col-6 mb-3">
                                    <label class="form-label">Min Price (For Two)</label>
                                    <input type="number" class="form-control sf-input" name="minPrice" value="200" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Delivery Time Estimate</label>
                                <input type="text" class="form-control sf-input" name="deliveryTime" value="25-35 min" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Short Description</label>
                                <textarea class="form-control sf-input" name="description" rows="2" placeholder="Authentic and delicious food..."></textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Address</label>
                                <input type="text" class="form-control sf-input" name="address" placeholder="Indiranagar, Bengaluru" required>
                            </div>

                            <button type="submit" class="btn btn-primary-sf w-100">
                                <i class="bi bi-check-lg me-2"></i>Save Restaurant
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Tab 2: Food Menu -->
            <% if ("foods".equals(activeTab)) { %>
            <div class="row gy-4">
                <div class="col-lg-8">
                    <div class="admin-table-wrap">
                        <table class="table admin-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Restaurant</th>
                                    <th>Category</th>
                                    <th>Type</th>
                                    <th>Price</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DBConnection.getConnection()) {
                                        String sql = "SELECT f.id, f.name AS fname, f.price, f.category, f.is_veg, r.name AS rname " +
                                                     "FROM foods f JOIN restaurants r ON f.restaurant_id = r.id ORDER BY f.id DESC";
                                        PreparedStatement ps = conn.prepareStatement(sql);
                                        ResultSet rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int id = rs.getInt("id");
                                %>
                                <tr>
                                    <td class="fw-bold">#<%= id %></td>
                                    <td class="fw-semibold"><%= rs.getString("fname") %></td>
                                    <td><%= rs.getString("rname") %></td>
                                    <td><%= rs.getString("category") %></td>
                                    <td>
                                        <span class="badge <%= rs.getBoolean("is_veg") ? "bg-success" : "bg-danger" %> rounded-pill small">
                                            <%= rs.getBoolean("is_veg") ? "VEG" : "NON-VEG" %>
                                        </span>
                                    </td>
                                    <td>₹<%= rs.getDouble("price") %></td>
                                    <td>
                                        <form action="AdminServlet" method="POST" class="d-inline" onsubmit="return confirm('Delete this menu item?')">
                                            <input type="hidden" name="action" value="deleteFood">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="bi bi-trash3"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                %>
                                <tr><td colspan="7" class="text-danger">DB Error: <%= e.getMessage() %></td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Add Food Sidebar Form -->
                <div class="col-lg-4">
                    <div class="admin-modal-card">
                        <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle-fill text-primary me-2"></i>Add Food Item</h5>
                        <form action="AdminServlet" method="POST">
                            <input type="hidden" name="action" value="addFood">
                            
                            <div class="mb-3">
                                <label class="form-label">Target Restaurant</label>
                                <select class="form-select sf-select w-100" name="restaurantId" required>
                                    <option value="" disabled selected>Select Restaurant</option>
                                    <%
                                        try (Connection conn = DBConnection.getConnection()) {
                                            PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM restaurants ORDER BY name");
                                            ResultSet rs = ps.executeQuery();
                                            while (rs.next()) {
                                    %>
                                    <option value="<%= rs.getInt("id") %>"><%= rs.getString("name") %></option>
                                    <%
                                            }
                                        } catch (Exception ignored) {}
                                    %>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Food Item Name</label>
                                <input type="text" class="form-control sf-input" name="name" placeholder="Garlic Bread" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Price (INR)</label>
                                <input type="number" step="0.01" class="form-control sf-input" name="price" placeholder="150" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Category</label>
                                <input type="text" class="form-control sf-input" name="category" placeholder="Main Course / Starters / Desserts" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Image URL (Optional)</label>
                                <input type="text" class="form-control sf-input" name="imageUrl" placeholder="http://example.com/food.jpg">
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Description</label>
                                <textarea class="form-control sf-input" name="description" rows="2" placeholder="Freshly baked crispy garlic bread..."></textarea>
                            </div>

                            <div class="mb-3 form-check form-switch ps-5">
                                <input class="form-check-input" type="checkbox" id="isVeg" name="isVeg" checked>
                                <label class="form-check-label fw-semibold" for="isVeg">Is Vegetarian</label>
                            </div>

                            <button type="submit" class="btn btn-primary-sf w-100">
                                <i class="bi bi-check-lg me-2"></i>Save Food Item
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Tab 3: Orders Logs -->
            <% if ("orders".equals(activeTab)) { %>
            <div class="row">
                <div class="col-12">
                    <div class="admin-table-wrap">
                        <table class="table admin-table">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>User ID</th>
                                    <th>Restaurant</th>
                                    <th>Amount</th>
                                    <th>Payment</th>
                                    <th>Address</th>
                                    <th>Status Trigger</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DBConnection.getConnection()) {
                                        PreparedStatement ps = conn.prepareStatement("SELECT * FROM orders ORDER BY id DESC");
                                        ResultSet rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int orderId = rs.getInt("id");
                                            String delStatus = rs.getString("delivery_status");
                                %>
                                <tr>
                                    <td class="fw-bold">#SF-<%= orderId %></td>
                                    <td><%= rs.getInt("user_id") %></td>
                                    <td class="fw-semibold"><%= rs.getString("restaurant_name") %></td>
                                    <td class="fw-bold text-primary">₹<%= rs.getDouble("total_amount") %></td>
                                    <td>
                                        <span class="badge bg-secondary text-uppercase small"><%= rs.getString("payment_method") %></span>
                                        <span class="badge <%= "paid".equals(rs.getString("payment_status")) ? "bg-success" : "bg-warning" %> small">
                                            <%= rs.getString("payment_status").toUpperCase() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="text-truncate" style="max-width:180px;" title="<%= rs.getString("delivery_address") %>">
                                            <%= rs.getString("delivery_address") %>
                                        </div>
                                    </td>
                                    <td>
                                        <form action="AdminServlet" method="POST" class="d-flex gap-2 align-items-center">
                                            <input type="hidden" name="action" value="updateOrderStatus">
                                            <input type="hidden" name="orderId" value="<%= orderId %>">
                                            <select class="form-select sf-select py-1 px-2" name="deliveryStatus" style="font-size: 0.85rem; width:130px;" onchange="this.form.submit()">
                                                <option value="placed" <%= "placed".equals(delStatus) ? "selected" : "" %>>Placed</option>
                                                <option value="confirmed" <%= "confirmed".equals(delStatus) ? "selected" : "" %>>Confirmed</option>
                                                <option value="preparing" <%= "preparing".equals(delStatus) ? "selected" : "" %>>Preparing</option>
                                                <option value="out_for_delivery" <%= "out_for_delivery".equals(delStatus) ? "selected" : "" %>>On the Way</option>
                                                <option value="delivered" <%= "delivered".equals(delStatus) ? "selected" : "" %>>Delivered</option>
                                                <option value="cancelled" <%= "cancelled".equals(delStatus) ? "selected" : "" %>>Cancelled</option>
                                            </select>
                                        </form>
                                    </td>
                                    <td class="small text-muted"><%= rs.getTimestamp("created_at") %></td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                %>
                                <tr><td colspan="8" class="text-danger">DB Error: <%= e.getMessage() %></td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Tab 4: Users Logs -->
            <% if ("users".equals(activeTab)) { %>
            <div class="row">
                <div class="col-12">
                    <div class="admin-table-wrap">
                        <table class="table admin-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Address</th>
                                    <th>Registered Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DBConnection.getConnection()) {
                                        PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE role = 'user' ORDER BY id DESC");
                                        ResultSet rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int id = rs.getInt("id");
                                %>
                                <tr>
                                    <td class="fw-bold">#<%= id %></td>
                                    <td class="fw-semibold"><%= rs.getString("name") %></td>
                                    <td><%= rs.getString("email") %></td>
                                    <td><%= rs.getString("phone") %></td>
                                    <td><%= rs.getString("address") != null ? rs.getString("address") : "Not set" %></td>
                                    <td class="small text-muted"><%= rs.getTimestamp("created_at") %></td>
                                    <td>
                                        <form action="AdminServlet" method="POST" class="d-inline" onsubmit="return confirm('Delete this user account permanent?')">
                                            <input type="hidden" name="action" value="deleteUser">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="bi bi-person-x-fill me-1"></i>Delete
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                %>
                                <tr><td colspan="7" class="text-danger">DB Error: <%= e.getMessage() %></td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <% } %>

        </div>
    </div>
</main>

<%@ include file="footer.jsp" %>
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
</body>
</html>
