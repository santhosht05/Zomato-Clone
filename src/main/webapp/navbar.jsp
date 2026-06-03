<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, swadhafood.DBConnection" %>
<%
    // Count cart items for badge
    int cartCount = 0;
    Integer navUserId = (session != null) ? (Integer) session.getAttribute("userId") : null;
    if (navUserId != null) {
        try (java.sql.Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT COALESCE(SUM(quantity),0) AS cnt FROM cart WHERE user_id = ?");
            ps.setInt(1, navUserId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) cartCount = rs.getInt("cnt");
        } catch (Exception ignored) {}
    }
    String currentPage = request.getServletPath();
%>
<nav class="navbar navbar-expand-lg sf-navbar fixed-top" id="mainNavbar">
    <div class="container-fluid px-4">
        <!-- Brand -->
        <a class="navbar-brand d-flex align-items-center gap-2" href="index.jsp" style="text-decoration: none;">
            <span class="brand-text text-lowercase" style="font-family: 'Outfit', 'Inter', sans-serif; font-weight: 900; color: var(--color-primary); letter-spacing: -1.5px; font-size: 1.85rem;">swadha<span style="color: var(--color-text-main); font-weight: 300; transition: color var(--transition-smooth);" id="navBrandFood">food</span></span>
        </a>

        <!-- Search Bar (desktop) -->
        <div class="navbar-search d-none d-lg-flex flex-grow-1 mx-4">
            <div class="navbar-search-box-unified w-100">
                <div class="navbar-search-location" id="navLocationSelect">
                    <i class="bi bi-geo-alt-fill text-danger fs-6 me-1"></i>
                    <span class="text-truncate" id="navLocationText">Bengaluru, Karnataka</span>
                    <i class="bi bi-caret-down-fill text-muted ms-auto" style="font-size: 0.70rem;"></i>
                    
                    <div class="location-dropdown" id="navLocationDropdown" style="display: none;">
                        <div class="location-option" data-value="Indiranagar, Bengaluru"><i class="bi bi-geo-alt-fill"></i>Indiranagar, Bengaluru</div>
                        <div class="location-option" data-value="Koramangala, Bengaluru"><i class="bi bi-geo-alt-fill"></i>Koramangala, Bengaluru</div>
                        <div class="location-option" data-value="Whitefield, Bengaluru"><i class="bi bi-geo-alt-fill"></i>Whitefield, Bengaluru</div>
                        <div class="location-option" data-value="HSR Layout, Bengaluru"><i class="bi bi-geo-alt-fill"></i>HSR Layout, Bengaluru</div>
                        <div class="location-option" data-value="Delhi NCR"><i class="bi bi-geo-alt-fill"></i>Delhi NCR</div>
                        <div class="location-option" data-value="Mumbai, Maharashtra"><i class="bi bi-geo-alt-fill"></i>Mumbai, Maharashtra</div>
                    </div>
                </div>
                <div class="search-box-divider"></div>
                <div class="navbar-search-input-wrap">
                    <input type="text" class="form-control nav-search-input" id="navSearch"
                           placeholder="Search for restaurants, cuisines or dishes..."
                           autocomplete="off">
                    <button class="btn nav-search-btn" onclick="performNavSearch()">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
                <div class="search-suggestions" id="navSuggestions"></div>
            </div>
        </div>

        <!-- Hamburger -->
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarContent">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Right Nav Items -->
        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav ms-auto align-items-center gap-2">

                <!-- Dark Mode Toggle -->
                <li class="nav-item">
                    <button class="btn dark-mode-btn" id="darkModeToggle" onclick="toggleDarkMode()" title="Toggle Dark Mode">
                        <i class="bi bi-moon-stars-fill" id="darkModeIcon"></i>
                    </button>
                </li>

                <% if (navUserId != null) { %>
                <!-- Cart -->
                <li class="nav-item">
                    <a class="nav-link cart-link" href="CartServlet">
                        <i class="bi bi-bag-fill text-danger"></i>
                        <span class="cart-badge" id="navCartBadge" style="<%= cartCount > 0 ? "" : "display: none;" %>"><%= cartCount %></span>
                        <span class="d-none d-lg-inline ms-1">Cart</span>
                    </a>
                </li>

                <!-- Favorites -->
                <li class="nav-item">
                    <a class="nav-link" href="FavoriteServlet">
                        <i class="bi bi-heart-fill text-danger"></i>
                        <span class="d-none d-lg-inline ms-1">Favorites</span>
                    </a>
                </li>

                <!-- Orders -->
                <li class="nav-item">
                    <a class="nav-link" href="OrderServlet">
                        <i class="bi bi-receipt"></i>
                        <span class="d-none d-lg-inline ms-1">Orders</span>
                    </a>
                </li>

                <!-- User Dropdown -->
                <li class="nav-item dropdown">
                    <a class="nav-link user-avatar-btn dropdown-toggle" href="#" role="button"
                       data-bs-toggle="dropdown" aria-expanded="false">
                        <div class="user-avatar">
                            <%= ((String)session.getAttribute("userName")).charAt(0) %>
                        </div>
                        <span class="d-none d-lg-inline ms-1"><%= session.getAttribute("userName") %></span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end sf-dropdown">
                        <li class="dropdown-header">
                            <div class="fw-bold"><%= session.getAttribute("userName") %></div>
                            <small class="text-muted"><%= session.getAttribute("userEmail") %></small>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="dashboard.jsp"><i class="bi bi-house me-2"></i>Dashboard</a></li>
                        <li><a class="dropdown-item" href="OrderServlet"><i class="bi bi-receipt me-2"></i>My Orders</a></li>
                        <li><a class="dropdown-item" href="FavoriteServlet"><i class="bi bi-heart me-2"></i>Favorites</a></li>
                        <% if ("admin".equals(session.getAttribute("userRole"))) { %>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="admin.jsp"><i class="bi bi-shield-lock me-2"></i>Admin Panel</a></li>
                        <% } %>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                    </ul>
                </li>
                <% } else { %>
                <li class="nav-item">
                    <a class="nav-link" href="login.jsp">Sign In</a>
                </li>
                <li class="nav-item">
                    <a class="btn btn-signup" href="register.jsp">Sign Up</a>
                </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>
