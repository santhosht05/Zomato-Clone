<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = (int) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="View and manage your favorite restaurants on SwadhaFood.">
    <title>My Favorites – SwadhaFood</title>
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
            <h1 class="page-hero-title">❤️ My Favorites</h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb sf-breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                    <li class="breadcrumb-item active">Favorites</li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container">
        <div class="row gy-4">
            <%
                int favoriteCount = 0;
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT r.id, r.name, r.cuisine, r.rating, r.delivery_time, r.min_price, r.image_url " +
                                 "FROM favorites f " +
                                 "JOIN restaurants r ON f.restaurant_id = r.id " +
                                 "WHERE f.user_id = ? " +
                                 "ORDER BY f.added_at DESC";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setInt(1, userId);
                    ResultSet rs = ps.executeQuery();
                    
                    String[] emojis = {"🍛","🍕","🍚","🥟","🍔","🫓","🥩","🍰"};
                    while (rs.next()) {
                        favoriteCount++;
                        int resId = rs.getInt("id");
                        String emoji = emojis[(resId - 1) % emojis.length];
                        double rating = rs.getDouble("rating");
            %>
            <div class="col-lg-4 col-md-6" id="fav-restaurant-<%= resId %>">
                <div class="restaurant-card">
                    <div class="restaurant-img-wrap">
                        <%
                            String imageUrl = rs.getString("image_url");
                            if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                        %>
                            <img src="<%= imageUrl %>" class="restaurant-card-img" alt="<%= rs.getString("name") %>" style="width: 100%; height: 220px; object-fit: cover; transition: transform 0.6s cubic-bezier(0.2, 0.8, 0.2, 1);">
                        <% } else { %>
                            <div class="restaurant-img-placeholder" style="background: var(--color-card-bg-<%= (resId % 6) + 1 %>)">
                                <span class="restaurant-emoji"><%= emoji %></span>
                            </div>
                        <% } %>
                        <div class="restaurant-badge">
                            <i class="bi bi-star-fill text-warning"></i>
                            <%= String.format("%.1f", rating) %>
                        </div>
                        
                        <!-- Remove Favorite Button Form -->
                        <form action="FavoriteServlet" method="POST" class="fav-form">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="restaurantId" value="<%= resId %>">
                            <input type="hidden" name="redirect" value="favorites.jsp">
                            <button type="submit" class="fav-btn" title="Remove from Favorites">
                                <i class="bi bi-heart-fill"></i>
                            </button>
                        </form>
                        
                        <div class="restaurant-overlay">
                            <a href="menu.jsp?restaurantId=<%= resId %>" class="view-menu-btn">View Menu</a>
                        </div>
                    </div>
                    <div class="restaurant-info">
                        <h5 class="restaurant-name"><%= rs.getString("name") %></h5>
                        <p class="restaurant-cuisine"><%= rs.getString("cuisine") %></p>
                        <div class="restaurant-meta">
                            <span class="meta-item"><i class="bi bi-clock me-1"></i><%= rs.getString("delivery_time") %></span>
                            <span class="meta-divider">·</span>
                            <span class="meta-item"><i class="bi bi-currency-rupee"></i><%= rs.getInt("min_price") %> for two</span>
                        </div>
                        <div class="restaurant-tags">
                            <span class="tag tag-offer"><i class="bi bi-tag me-1"></i>Favorite</span>
                            <a href="menu.jsp?restaurantId=<%= resId %>" class="btn btn-primary-sf btn-sm ms-auto px-3">View Menu</a>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }
                } catch (Exception e) {
            %>
            <div class="col-12">
                <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>DB Error: <%= e.getMessage() %></div>
            </div>
            <%
                }
                if (favoriteCount == 0) {
            %>
            <div class="col-12 text-center py-5">
                <div class="empty-state">
                    <div class="empty-icon">❤️</div>
                    <h4 class="mt-3">No Favorites Yet</h4>
                    <p class="text-muted">Explore restaurants and save the ones you love!</p>
                    <a href="restaurants.jsp" class="btn btn-primary-sf btn-lg mt-2">
                        <i class="bi bi-search me-2"></i>Discover Restaurants
                    </a>
                </div>
            </div>
            <%
                }
            %>
        </div>
    </div>
</main>

<%@ include file="footer.jsp" %>
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
</body>
</html>
