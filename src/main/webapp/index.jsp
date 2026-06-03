<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="SwadhaFood - Order delicious food from top restaurants near you. Fast delivery, great prices, amazing taste!">
    <title>SwadhaFood – Order Food Online | Fast Delivery</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>

<%@ include file="navbar.jsp" %>

<!-- Hero Section -->
<section class="zomato-hero animate-fade-up">
    <div class="zomato-hero-bg" style="background-image: linear-gradient(rgba(0, 0, 0, 0.45), rgba(0, 0, 0, 0.55)), url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1600&q=80');"></div>
    <div class="container text-center zomato-hero-content">
        <h1 class="zomato-hero-logo text-lowercase mb-2" style="font-family: 'Outfit', 'Inter', sans-serif; font-weight: 900; color: #ffffff; letter-spacing: -2.5px; font-size: 5.5rem;">
            swadha<span style="color: #ffffff; font-weight: 300;">food</span>
        </h1>
        <p class="zomato-hero-subtitle mb-4">
            Discover the best food & drinks in Bengaluru
        </p>
        
        <!-- Double-Segment Search Card -->
        <div class="hero-search-box-unified">
            <div class="hero-search-location" id="heroLocationSelect">
                <i class="bi bi-geo-alt-fill text-danger fs-5"></i>
                <span class="text-truncate" id="heroLocationText">Bengaluru, Karnataka</span>
                <i class="bi bi-caret-down-fill text-muted ms-auto" style="font-size: 0.75rem;"></i>
                
                <div class="location-dropdown" id="heroLocationDropdown" style="display: none;">
                    <div class="location-option" data-value="Indiranagar, Bengaluru"><i class="bi bi-geo-alt-fill"></i>Indiranagar, Bengaluru</div>
                    <div class="location-option" data-value="Koramangala, Bengaluru"><i class="bi bi-geo-alt-fill"></i>Koramangala, Bengaluru</div>
                    <div class="location-option" data-value="Whitefield, Bengaluru"><i class="bi bi-geo-alt-fill"></i>Whitefield, Bengaluru</div>
                    <div class="location-option" data-value="HSR Layout, Bengaluru"><i class="bi bi-geo-alt-fill"></i>HSR Layout, Bengaluru</div>
                    <div class="location-option" data-value="Delhi NCR"><i class="bi bi-geo-alt-fill"></i>Delhi NCR</div>
                    <div class="location-option" data-value="Mumbai, Maharashtra"><i class="bi bi-geo-alt-fill"></i>Mumbai, Maharashtra</div>
                </div>
            </div>
            <div class="search-box-divider"></div>
            <div class="hero-search-input-wrap">
                <i class="bi bi-search text-muted fs-5"></i>
                <input type="text" id="heroSearch" class="hero-search-input"
                       placeholder="Search for restaurant, cuisine or a dish..." autocomplete="off">
            </div>
            <button class="btn btn-search-go" onclick="heroSearchRedirect()">
                Search
            </button>
        </div>
    </div>
</section>

<!-- Iconic Zomato Category Cards -->
<section class="section-gap" style="background-color: var(--color-bg-card); transition: background-color var(--transition-smooth); border-bottom: 1px solid var(--color-border);">
    <div class="container">
        <div class="row gy-4 justify-content-center">
            <!-- Card 1: Order Online -->
            <div class="col-lg-4 col-md-6">
                <a href="restaurants.jsp" class="zomato-category-card-link">
                    <div class="zomato-category-card">
                        <div class="z-card-img-wrap">
                            <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80" class="z-card-img" alt="Order Online">
                        </div>
                        <div class="z-card-body">
                            <h4 class="z-card-title">Order Online</h4>
                            <p class="z-card-subtitle">Stay home and order to your doorstep</p>
                        </div>
                    </div>
                </a>
            </div>
            <!-- Card 2: Dining Out -->
            <div class="col-lg-4 col-md-6">
                <a href="javascript:void(0)" onclick="showToast('Dining Reservations are coming soon!', 'info')" class="zomato-category-card-link">
                    <div class="zomato-category-card">
                        <div class="z-card-img-wrap">
                            <img src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80" class="z-card-img" alt="Dining Out">
                        </div>
                        <div class="z-card-body">
                            <h4 class="z-card-title">Dining</h4>
                            <p class="z-card-subtitle">View the city's favourite dining venues</p>
                        </div>
                    </div>
                </a>
            </div>
            <!-- Card 3: Nightlife & Clubs -->
            <div class="col-lg-4 col-md-6">
                <a href="javascript:void(0)" onclick="showToast('Nightlife & Clubs booking coming soon!', 'info')" class="zomato-category-card-link">
                    <div class="zomato-category-card">
                        <div class="z-card-img-wrap">
                            <img src="https://images.unsplash.com/photo-1566737236500-c8ac43014a67?auto=format&fit=crop&w=600&q=80" class="z-card-img" alt="Nightlife & Clubs">
                        </div>
                        <div class="z-card-body">
                            <h4 class="z-card-title">Nightlife</h4>
                            <p class="z-card-subtitle">Explore the city's top nightlife & clubs</p>
                        </div>
                    </div>
                </a>
            </div>
        </div>
    </div>
</section>

<!-- Cuisine Categories -->
<section class="section-gap">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">What's on your mind?</h2>
            <p class="section-subtitle">Explore your favourite cuisines</p>
        </div>
        <div class="cuisine-grid">
            <a href="restaurants.jsp?cuisine=North+Indian" class="cuisine-card">
                <div class="cuisine-emoji">🍛</div>
                <span>North Indian</span>
            </a>
            <a href="restaurants.jsp?cuisine=Biryani" class="cuisine-card">
                <div class="cuisine-emoji">🍚</div>
                <span>Biryani</span>
            </a>
            <a href="restaurants.jsp?cuisine=Pizza" class="cuisine-card">
                <div class="cuisine-emoji">🍕</div>
                <span>Pizza</span>
            </a>
            <a href="restaurants.jsp?cuisine=Chinese" class="cuisine-card">
                <div class="cuisine-emoji">🥟</div>
                <span>Chinese</span>
            </a>
            <a href="restaurants.jsp?cuisine=Burger" class="cuisine-card">
                <div class="cuisine-emoji">🍔</div>
                <span>Burger</span>
            </a>
            <a href="restaurants.jsp?cuisine=South+Indian" class="cuisine-card">
                <div class="cuisine-emoji">🫓</div>
                <span>South Indian</span>
            </a>
            <a href="restaurants.jsp?cuisine=Desserts" class="cuisine-card">
                <div class="cuisine-emoji">🍰</div>
                <span>Desserts</span>
            </a>
            <a href="restaurants.jsp?cuisine=BBQ" class="cuisine-card">
                <div class="cuisine-emoji">🥩</div>
                <span>BBQ & Grills</span>
            </a>
        </div>
    </div>
</section>

<!-- Featured Restaurants -->
<section class="section-gap bg-section-alt">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">Top Restaurants Near You</h2>
            <a href="restaurants.jsp" class="see-all-link">See All <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="row gy-4">
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT * FROM restaurants WHERE is_active = 1 ORDER BY rating DESC LIMIT 6";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery();
                    int resCount = 0;
                    while (rs.next()) {
                        resCount++;
                        String[] emojis = {"🍛","🍕","🍚","🥟","🍔","🫓","🥩","🍰"};
                        String emoji = emojis[(rs.getInt("id") - 1) % emojis.length];
                        double rating = rs.getDouble("rating");
            %>
            <div class="col-lg-4 col-md-6">
                <a href="menu.jsp?restaurantId=<%= rs.getInt("id") %>" class="restaurant-card-link">
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
                                <%= String.format("%.1f", rating) %>
                            </div>
                            <div class="restaurant-overlay">
                                <span class="view-menu-btn">View Menu</span>
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
                                <span class="tag tag-offer"><i class="bi bi-tag me-1"></i>20% OFF</span>
                                <span class="tag tag-free">Free Delivery</span>
                            </div>
                        </div>
                    </div>
                </a>
            </div>
            <%  }
                if (resCount == 0) { %>
            <div class="col-12 text-center py-5">
                <p class="text-muted">No restaurants available. Please check the database connection.</p>
            </div>
            <%  }
                } catch (Exception e) { %>
            <div class="col-12 text-center py-5">
                <p class="text-danger"><i class="bi bi-exclamation-triangle me-2"></i>DB Error: <%= e.getMessage() %></p>
            </div>
            <% } %>
        </div>
        <div class="text-center mt-4">
            <a href="restaurants.jsp" class="btn btn-primary-sf btn-lg">
                <i class="bi bi-shop me-2"></i>Browse All Restaurants
            </a>
        </div>
    </div>
</section>

<!-- Offers Banner -->
<section class="section-gap">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">Exclusive Offers</h2>
            <p class="section-subtitle">Save more on every order</p>
        </div>
        <div class="row gy-3">
            <div class="col-lg-4">
                <div class="offer-card offer-card-red">
                    <div class="offer-icon">🎉</div>
                    <div>
                        <h5 class="offer-title">20% OFF</h5>
                        <p class="offer-desc">Use code <strong>SWADHA20</strong></p>
                        <small>On your first order · Min ₹300</small>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="offer-card offer-card-orange">
                    <div class="offer-icon">🚀</div>
                    <div>
                        <h5 class="offer-title">Free Delivery</h5>
                        <p class="offer-desc">Use code <strong>FREEDEL</strong></p>
                        <small>On orders above ₹200</small>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="offer-card offer-card-green">
                    <div class="offer-icon">💳</div>
                    <div>
                        <h5 class="offer-title">10% Cashback</h5>
                        <p class="offer-desc">Pay with UPI</p>
                        <small>Max cashback ₹150</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- How It Works -->
<section class="section-gap bg-section-alt">
    <div class="container">
        <div class="section-header text-center">
            <h2 class="section-title">How It Works</h2>
            <p class="section-subtitle">Order your food in 3 simple steps</p>
        </div>
        <div class="row justify-content-center gy-4">
            <div class="col-lg-3 col-md-4 col-sm-6">
                <div class="how-card">
                    <div class="how-number">01</div>
                    <div class="how-icon">📍</div>
                    <h5>Choose Location</h5>
                    <p>Set your delivery address and find restaurants near you</p>
                </div>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <div class="how-card">
                    <div class="how-number">02</div>
                    <div class="how-icon">🍽️</div>
                    <h5>Choose Your Food</h5>
                    <p>Browse menus and pick your favourite dishes</p>
                </div>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <div class="how-card">
                    <div class="how-number">03</div>
                    <div class="how-icon">🚚</div>
                    <h5>Fast Delivery</h5>
                    <p>We deliver hot and fresh food right to your door</p>
                </div>
            </div>
        </div>
    </div>
</section>

<%@ include file="footer.jsp" %>

<!-- Toast Container -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>
<script>
function heroSearchRedirect() {
    const q = document.getElementById('heroSearch').value.trim();
    if (q) window.location.href = 'restaurants.jsp?search=' + encodeURIComponent(q);
    else window.location.href = 'restaurants.jsp';
}
document.getElementById('heroSearch').addEventListener('keypress', function(e){
    if (e.key === 'Enter') heroSearchRedirect();
});

<% if (request.getParameter("logout") != null) { %>
showToast('Logged out successfully!', 'info');
<% } %>
</script>
</body>
</html>
