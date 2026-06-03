<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("userName");
    int userId = (int) session.getAttribute("userId");
    String search = request.getParameter("search");
    if (search == null) search = "";
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Your SwadhaFood dashboard - browse restaurants and order food.">
    <title>Dashboard – SwadhaFood</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
<%@ include file="navbar.jsp" %>

<main class="main-content">

    <!-- Dashboard Hero / Greeting -->
    <section class="dashboard-hero">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-7">
                    <div class="greeting-badge"><i class="bi bi-sun-fill text-warning me-2"></i>Good <%= java.time.LocalTime.now().getHour() < 12 ? "Morning" : java.time.LocalTime.now().getHour() < 17 ? "Afternoon" : "Evening" %>!</div>
                    <h1 class="dashboard-greeting">Hey, <%= userName.split(" ")[0] %>! 👋</h1>
                    <p class="dashboard-subtitle">What would you like to eat today?</p>

                    <!-- Dashboard Search -->
                    <div class="dash-search-box">
                        <i class="bi bi-search dash-search-icon"></i>
                        <input type="text" id="dashSearch" class="dash-search-input"
                               value="<%= search %>"
                               placeholder="Search for restaurants, food, cuisines...">
                        <button class="btn dash-search-btn" onclick="dashSearchGo()">Search</button>
                    </div>
                </div>
                <div class="col-lg-5 d-none d-lg-flex justify-content-end">
                    <div class="dashboard-hero-art">
                        <div class="dash-floating-emoji fe-1">🍕</div>
                        <div class="dash-floating-emoji fe-2">🍔</div>
                        <div class="dash-floating-emoji fe-3">🍛</div>
                        <div class="dash-floating-emoji fe-4">🍜</div>
                        <div class="dash-quick-stats">
                            <div class="quick-stat"><i class="bi bi-shop text-primary"></i><span>500+ Restaurants</span></div>
                            <div class="quick-stat"><i class="bi bi-clock text-warning"></i><span>25 min avg delivery</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Category Filters -->
    <section class="section-gap">
        <div class="container">
            <div class="filter-tabs" id="categoryFilters">
                <button class="filter-tab active" onclick="filterCategory('all', this)">🍽️ All</button>
                <button class="filter-tab" onclick="filterCategory('North Indian', this)">🍛 North Indian</button>
                <button class="filter-tab" onclick="filterCategory('Biryani', this)">🍚 Biryani</button>
                <button class="filter-tab" onclick="filterCategory('Pizza', this)">🍕 Pizza</button>
                <button class="filter-tab" onclick="filterCategory('Chinese', this)">🥟 Chinese</button>
                <button class="filter-tab" onclick="filterCategory('Burger', this)">🍔 Burger</button>
                <button class="filter-tab" onclick="filterCategory('South Indian', this)">🫓 South Indian</button>
                <button class="filter-tab" onclick="filterCategory('Desserts', this)">🍰 Desserts</button>
            </div>
        </div>
    </section>

    <!-- Offers Banners -->
    <section class="section-gap pt-0">
        <div class="container">
            <div class="row gy-3">
                <div class="col-lg-6">
                    <div class="offer-banner ob-red">
                        <div class="ob-content">
                            <h4>🎉 20% OFF First Order!</h4>
                            <p>Use code <strong>SWADHA20</strong></p>
                            <a href="restaurants.jsp" class="btn btn-white-sm">Order Now</a>
                        </div>
                        <div class="ob-bg-emoji">🍕</div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="offer-banner ob-orange">
                        <div class="ob-content">
                            <h4>🚀 Free Delivery Today!</h4>
                            <p>Use code <strong>FREEDEL</strong></p>
                            <a href="restaurants.jsp" class="btn btn-white-sm">Explore</a>
                        </div>
                        <div class="ob-bg-emoji">🛵</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Restaurants Grid -->
    <section class="section-gap pt-0">
        <div class="container">
            <div class="d-flex align-items-center justify-content-between mb-4">
                <h2 class="section-title mb-0">
                    <% if (!search.isEmpty()) { %>
                    Results for "<%= search %>"
                    <% } else { %>
                    Popular Restaurants
                    <% } %>
                </h2>
                <div class="sort-select-wrap">
                    <select class="form-select sf-select" id="sortSelect" onchange="sortRestaurants(this.value)">
                        <option value="rating">Sort: Top Rated</option>
                        <option value="delivery">Sort: Fastest Delivery</option>
                        <option value="price">Sort: Low Price</option>
                    </select>
                </div>
            </div>

            <div class="row gy-4" id="restaurantsGrid">
                <%
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql;
                        PreparedStatement ps;
                        if (!search.isEmpty()) {
                            sql = "SELECT * FROM restaurants WHERE is_active = 1 AND (name LIKE ? OR cuisine LIKE ?) ORDER BY rating DESC";
                            ps = conn.prepareStatement(sql);
                            ps.setString(1, "%" + search + "%");
                            ps.setString(2, "%" + search + "%");
                        } else {
                            sql = "SELECT * FROM restaurants WHERE is_active = 1 ORDER BY rating DESC";
                            ps = conn.prepareStatement(sql);
                        }
                        ResultSet rs = ps.executeQuery();
                        String[] emojis = {"🍛","🍕","🍚","🥟","🍔","🫓","🥩","🍰"};
                        int count = 0;
                        while (rs.next()) {
                            count++;
                            String emoji = emojis[(rs.getInt("id") - 1) % emojis.length];
                            double rating = rs.getDouble("rating");
                            int minPrice = rs.getInt("min_price");
                %>
                <div class="col-lg-4 col-md-6 restaurant-item"
                     data-cuisine="<%= rs.getString("cuisine") %>"
                     data-rating="<%= rating %>"
                     data-price="<%= minPrice %>">
                    <div class="restaurant-card">
                        <div class="restaurant-img-wrap">
                             <%
                                 String imageUrl = rs.getString("image_url");
                                 if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                             %>
                                 <img src="<%= imageUrl %>" class="restaurant-card-img" alt="<%= rs.getString("name") %>" style="width: 100%; height: 220px; object-fit: cover; transition: transform 0.6s cubic-bezier(0.2, 0.8, 0.2, 1);">
                             <% } else { %>
                                 <div class="restaurant-img-placeholder" style="background: var(--color-card-bg-<%= (rs.getInt("id") % 6) + 1 %>)">
                                     <span class="restaurant-emoji"><%= emoji %></span>
                                 </div>
                             <% } %>
                            <div class="restaurant-badge">
                                <i class="bi bi-star-fill text-warning"></i>
                                <%= String.format("%.1f", rating) %>
                            </div>
                            <!-- Favorite Button -->
                            <form action="FavoriteServlet" method="POST" class="fav-form">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="restaurantId" value="<%= rs.getInt("id") %>">
                                <input type="hidden" name="redirect" value="dashboard.jsp">
                                <button type="submit" class="fav-btn" title="Add to Favorites">
                                    <i class="bi bi-heart"></i>
                                </button>
                            </form>
                            <div class="restaurant-overlay">
                                <a href="menu.jsp?restaurantId=<%= rs.getInt("id") %>" class="view-menu-btn">View Menu</a>
                            </div>
                        </div>
                        <div class="restaurant-info">
                            <h5 class="restaurant-name"><%= rs.getString("name") %></h5>
                            <p class="restaurant-cuisine"><%= rs.getString("cuisine") %></p>
                            <div class="restaurant-meta">
                                <span class="meta-item"><i class="bi bi-clock me-1"></i><%= rs.getString("delivery_time") %></span>
                                <span class="meta-divider">·</span>
                                <span class="meta-item"><i class="bi bi-currency-rupee"></i><%= minPrice %> for two</span>
                            </div>
                            <div class="restaurant-tags">
                                <span class="tag tag-offer"><i class="bi bi-tag me-1"></i>Offers</span>
                                <% if (rs.getDouble("rating") >= 4.5) { %>
                                <span class="tag tag-top">Top Rated</span>
                                <% } else if (rs.getInt("min_price") < 100) { %>
                                <span class="tag tag-free">Budget Pick</span>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
                <%      }
                        if (count == 0) { %>
                <div class="col-12 text-center py-5">
                    <div class="empty-state">
                        <div class="empty-icon">🔍</div>
                        <h5>No restaurants found</h5>
                        <p class="text-muted">Try a different search term</p>
                        <a href="dashboard.jsp" class="btn btn-primary-sf">Clear Search</a>
                    </div>
                </div>
                <%      }
                    } catch (Exception e) { %>
                <div class="col-12">
                    <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>DB Error: <%= e.getMessage() %></div>
                </div>
                <% } %>
            </div>
        </div>
    </section>

</main>

<%@ include file="footer.jsp" %>
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
<script>
function dashSearchGo() {
    const q = document.getElementById('dashSearch').value.trim();
    window.location.href = 'dashboard.jsp' + (q ? '?search=' + encodeURIComponent(q) : '');
}
document.getElementById('dashSearch').addEventListener('keypress', e => {
    if (e.key === 'Enter') dashSearchGo();
});

function filterCategory(cuisine, btn) {
    document.querySelectorAll('.filter-tab').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.querySelectorAll('.restaurant-item').forEach(item => {
        if (cuisine === 'all' || item.dataset.cuisine.toLowerCase().includes(cuisine.toLowerCase())) {
            item.style.display = '';
        } else {
            item.style.display = 'none';
        }
    });
}

function sortRestaurants(by) {
    const grid = document.getElementById('restaurantsGrid');
    const items = [...grid.querySelectorAll('.restaurant-item')];
    items.sort((a, b) => {
        if (by === 'rating') return parseFloat(b.dataset.rating) - parseFloat(a.dataset.rating);
        if (by === 'price')  return parseInt(a.dataset.price)  - parseInt(b.dataset.price);
        return 0;
    });
    items.forEach(i => grid.appendChild(i));
}
</script>
</body>
</html>
