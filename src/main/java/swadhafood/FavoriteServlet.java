package swadhafood;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/FavoriteServlet")
public class FavoriteServlet extends HttpServlet {

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("userId") != null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }
        req.getRequestDispatcher("favorites.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");
        int userId = (int) req.getSession(false).getAttribute("userId");
        int restaurantId;
        try {
            restaurantId = Integer.parseInt(req.getParameter("restaurantId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect("favorites.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if ("add".equals(action)) {
                String sql = "INSERT IGNORE INTO favorites (user_id, restaurant_id) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, restaurantId);
                    ps.executeUpdate();
                }
            } else if ("remove".equals(action)) {
                String sql = "DELETE FROM favorites WHERE user_id = ? AND restaurant_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, restaurantId);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Favorites error: " + e.getMessage());
        }

        String redirectBack = req.getParameter("redirect");
        if (redirectBack != null && !redirectBack.isEmpty()) {
            resp.sendRedirect(redirectBack);
        } else {
            resp.sendRedirect("favorites.jsp");
        }
    }
}
