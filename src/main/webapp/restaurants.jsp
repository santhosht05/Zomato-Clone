<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    String searchQ   = request.getParameter("search")  != null ? request.getParameter("search").trim()  : "";
    String cuisineF  = request.getParameter("cuisine") != null ? request.getParameter("cuisine").trim()  : "";
    String ratingF   = request.getParameter("rating")  != null ? request.getParameter("rating").trim()   : "";
    String priceF    = request.getParameter("price")   != null ? request.getParameter("price").trim()    : "";
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Browse all restaurants on SwadhaFood - Filter by cuisine, rating and price.">
    <title>Restaurants – SwadhaFood</title>
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
            <h1 class="page-hero-title">
                <% if (!searchQ.isEmpty()) { %>
                Search: "<%= searchQ %>"
                <% } else if (!cuisineF.isEmpty()) { %>
                <%= cuisineF %> Restaurants
                <% } else { %>
                All Restaurants
                <% } %>
            </h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb sf-breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                    <li class="breadcrumb-item active">Restaurants</li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container">
        <div class="row">
            <!-- Sidebar Filters -->
            <div class="col-lg-3 col-md-4">
                <div class="filter-sidebar">
                    <div class="filter-sidebar-header">
                        <h5><i class="bi bi-funnel me-2"></i>Filters</h5>
                        <button class="btn btn-sm btn-link" onclick="clearFilters()">Clear All</button>
                    </div>

                    <!-- Search -->
                    <div class="filter-section">
                        <label class="filter-label">Search</label>
                        <div class="input-group">
                            <input type="text" class="form-control sf-input-sm" id="sideSearch"
                                   value="<%= searchQ %>" placeholder="Restaurant or food...">
                            <button class="btn btn-primary-sf-sm" onclick="applyFilters()">
                                <i class="bi bi-search"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Cuisine Filter -->
                    <div class="filter-section">
                        <label class="filter-label">Cuisine</label>
                        <div class="filter-options">
                            <% String[] cuisines = {"North Indian","South Indian","Chinese","Italian","Fast Food","Biryani","BBQ","Desserts","American","Asian"};
                               for (String c : cuisines) { %>
                            <label class="filter-checkbox">
                                <input type="checkbox" class="cuisine-check" value="<%= c %>"
                                       <%= c.equals(cuisineF) ? "checked" : "" %>
                                       onchange="applyFilters()">
                                <span><%= c %></span>
                            </label>
                            <% } %>
                        </div>
                    </div>

                    <!-- Rating Filter -->
                    <div class="filter-section">
                        <label class="filter-label">Minimum Rating</label>
                        <div class="filter-options">
                            <% String[] ratings = {"4.5","4.0","3.5","3.0"};
                               for (String r : ratings) { %>
                            <label class="filter-checkbox">
                                <input type="radio" name="ratingFilter" value="<%= r %>"
                                       <%= r.equals(ratingF) ? "checked" : "" %>
                                       onchange="applyFilters()">
                                <span><i class="bi bi-star-fill text-warning"></i> <%= r %>+</span>
                            </label>
                            <% } %>
                        </div>
                    </div>

                    <!-- Price Filter -->
                    <div class="filter-section">
                        <label class="filter-label">Price Range (for two)</label>
                        <div class="filter-options">
                            <label class="filter-checkbox">
                                <input type="radio" name="priceFilter" value="100" onchange="applyFilters()" <%= "100".equals(priceF) ? "checked" : "" %>>
                                <span>Under ₹100</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="radio" name="priceFilter" value="200" onchange="applyFilters()" <%= "200".equals(priceF) ? "checked" : "" %>>
                                <span>₹100 – ₹200</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="radio" name="priceFilter" value="500" onchange="applyFilters()" <%= "500".equals(priceF) ? "checked" : "" %>>
                                <span>₹200 – ₹500</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="radio" name="priceFilter" value="9999" onchange="applyFilters()" <%= "9999".equals(priceF) ? "checked" : "" %>>
                                <span>₹500+</span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Restaurant Grid -->
            <div class="col-lg-9 col-md-8">
                <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
                    <p class="results-count mb-0" id="resultsCount"></p>
                    <select class="form-select sf-select w-auto" onchange="sortCards(this.value)">
                        <option value="rating">Relevance</option>
                        <option value="rating_asc">Rating ↑</option>
                        <option value="price_asc">Price ↑</option>
                        <option value="price_desc">Price ↓</option>
                    </select>
                </div>

                <div class="row gy-4" id="restaurantsGrid">
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            StringBuilder sqlB = new StringBuilder("SELECT * FROM restaurants WHERE is_active = 1");
                            java.util.List<Object> params = new java.util.ArrayList<>();

                            if (!searchQ.isEmpty()) {
                                sqlB.append(" AND (name LIKE ? OR cuisine LIKE ?)");
                                params.add("%" + searchQ + "%");
                                params.add("%" + searchQ + "%");
                            }
                            if (!cuisineF.isEmpty()) {
                                sqlB.append(" AND cuisine LIKE ?");
                                params.add("%" + cuisineF + "%");
                            }
                            if (!ratingF.isEmpty()) {
                                sqlB.append(" AND rating >= ?");
                                params.add(Double.parseDouble(ratingF));
                            }
                            sqlB.append(" ORDER BY rating DESC");

                            PreparedStatement ps = conn.prepareStatement(sqlB.toString());
                            for (int i = 0; i < params.size(); i++) {
                                Object p = params.get(i);
                                if (p instanceof String) ps.setString(i + 1, (String) p);
                                else ps.setDouble(i + 1, (Double) p);
                            }
                            ResultSet rs = ps.executeQuery();
                            String[] emojis = {"🍛","🍕","🍚","🥟","🍔","🫓","🥩","🍰"};
                            int count = 0;
                            while (rs.next()) {
                                count++;
                                String emoji = emojis[(rs.getInt("id") - 1) % emojis.length];
                                int uid2 = (session != null && session.getAttribute("userId") != null) ? (int) session.getAttribute("userId") : 0;
                                // Check if favorited
                                boolean isFav = false;
                                if (uid2 > 0) {
                                    PreparedStatement fPs = conn.prepareStatement("SELECT 1 FROM favorites WHERE user_id=? AND restaurant_id=?");
                                    fPs.setInt(1, uid2);
                                    fPs.setInt(2, rs.getInt("id"));
                                    ResultSet fRs = fPs.executeQuery();
                                    isFav = fRs.next();
                                }
                    %>
                    <div class="col-md-6 col-xl-4 restaurant-item"
                         data-cuisine="<%= rs.getString("cuisine") %>"
                         data-rating="<%= rs.getDouble("rating") %>"
                         data-price="<%= rs.getInt("min_price") %>">
                        <div class="restaurant-card">
                            <div class="restaurant-img-wrap">
                                 <%
                                     String imageUrl = rs.getString("image_url");
                                     if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                                 %>
                                     <img src="<%= imageUrl %>" class="restaurant-card-img" alt="<%= rs.getString("name") %>" style="width: 100%; height: 220px; object-fit: cover; transition: transform 0.6s cubic-bezier(0.2, 0.8, 0.2, 1);">
                                 <% } else { %>
                                     <div class="restaurant-img-placeholder">
                                         <span class="restaurant-emoji"><%= emoji %></span>
                                     </div>
                                 <% } %>
                                <div class="restaurant-badge">
                                    <i class="bi bi-star-fill text-warning"></i>
                                    <%= String.format("%.1f", rs.getDouble("rating")) %>
                                </div>
                                <% if (session != null && session.getAttribute("userId") != null) { %>
                                <form action="FavoriteServlet" method="POST" class="fav-form">
                                    <input type="hidden" name="action" value="<%= isFav ? "remove" : "add" %>">
                                    <input type="hidden" name="restaurantId" value="<%= rs.getInt("id") %>">
                                    <input type="hidden" name="redirect" value="restaurants.jsp">
                                    <button type="submit" class="fav-btn <%= isFav ? "favorited" : "" %>" title="<%= isFav ? "Remove from Favorites" : "Add to Favorites" %>">
                                        <i class="bi bi-heart<%= isFav ? "-fill" : "" %>"></i>
                                    </button>
                                </form>
                                <% } %>
                                <div class="restaurant-overlay">
                                    <a href="menu.jsp?restaurantId=<%= rs.getInt("id") %>" class="view-menu-btn">View Menu</a>
                                </div>
                            </div>
                            <div class="restaurant-info">
                                <h5 class="restaurant-name"><%= rs.getString("name") %></h5>
                                <p class="restaurant-cuisine text-truncate"><%= rs.getString("cuisine") %></p>
                                <% if (rs.getString("address") != null) { %>
                                <p class="restaurant-address"><i class="bi bi-geo-alt me-1"></i><%= rs.getString("address") %></p>
                                <% } %>
                                <div class="restaurant-meta">
                                    <span class="meta-item"><i class="bi bi-clock me-1"></i><%= rs.getString("delivery_time") %></span>
                                    <span class="meta-divider">·</span>
                                    <span class="meta-item"><i class="bi bi-currency-rupee"></i><%= rs.getInt("min_price") %> for two</span>
                                </div>
                                <div class="restaurant-tags">
                                    <span class="tag tag-offer"><i class="bi bi-tag me-1"></i>Offers</span>
                                    <% if (rs.getDouble("rating") >= 4.5) { %><span class="tag tag-top">Top Rated</span><% } %>
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
                            <p class="text-muted">Try different filters</p>
                            <a href="restaurants.jsp" class="btn btn-primary-sf">Clear Filters</a>
                        </div>
                    </div>
                    <%      }
                        } catch (Exception e) { %>
                    <div class="col-12">
                        <div class="alert alert-danger">DB Error: <%= e.getMessage() %></div>
                    </div>
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
// Count visible restaurants
function updateCount() {
    const visible = document.querySelectorAll('.restaurant-item:not([style*="display: none"])').length;
    document.getElementById('resultsCount').textContent = visible + ' restaurants found';
}
updateCount();

function applyFilters() {
    const q      = document.getElementById('sideSearch').value.trim();
    const cuisines = [...document.querySelectorAll('.cuisine-check:checked')].map(c => c.value.toLowerCase());
    const rating = document.querySelector('input[name="ratingFilter"]:checked');
    const price  = document.querySelector('input[name="priceFilter"]:checked');

    const params = new URLSearchParams();
    if (q) params.set('search', q);
    if (cuisines.length === 1) params.set('cuisine', cuisines[0]);
    if (rating) params.set('rating', rating.value);
    if (price) params.set('price', price.value);
    window.location.href = 'restaurants.jsp?' + params.toString();
}

function clearFilters() {
    window.location.href = 'restaurants.jsp';
}

function sortCards(by) {
    const grid = document.getElementById('restaurantsGrid');
    const items = [...grid.querySelectorAll('.restaurant-item')];
    items.sort((a, b) => {
        if (by === 'rating') return parseFloat(b.dataset.rating) - parseFloat(a.dataset.rating);
        if (by === 'rating_asc') return parseFloat(a.dataset.rating) - parseFloat(b.dataset.rating);
        if (by === 'price_asc') return parseInt(a.dataset.price) - parseInt(b.dataset.price);
        if (by === 'price_desc') return parseInt(b.dataset.price) - parseInt(a.dataset.price);
        return 0;
    });
    items.forEach(i => grid.appendChild(i));
}
</script>
</body>
</html>
