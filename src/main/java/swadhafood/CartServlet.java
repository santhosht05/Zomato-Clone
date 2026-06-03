package swadhafood;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("userId") != null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) {
            resp.sendRedirect("login.jsp?redirect=cart");
            return;
        }
        req.getRequestDispatcher("cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) {
            resp.sendRedirect("login.jsp?redirect=cart");
            return;
        }

        String action = req.getParameter("action");
        int userId = (int) req.getSession(false).getAttribute("userId");

        try (Connection conn = DBConnection.getConnection()) {
            switch (action == null ? "" : action) {
                case "add":
                    addToCart(conn, userId, req, resp);
                    break;
                case "remove":
                    removeFromCart(conn, userId, req, resp);
                    break;
                case "update":
                    updateCart(conn, userId, req, resp);
                    break;
                case "clear":
                    clearCart(conn, userId, req, resp);
                    break;
                default:
                    resp.sendRedirect("cart.jsp");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Cart error: " + e.getMessage());
            req.getRequestDispatcher("cart.jsp").forward(req, resp);
        }
    }

    private void addToCart(Connection conn, int userId, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int foodId = Integer.parseInt(req.getParameter("foodId"));
        int qty    = 1;
        try { qty = Integer.parseInt(req.getParameter("quantity")); } catch (Exception ignored) {}

        // Upsert: if exists, increment quantity; else insert
        String checkSql = "SELECT id, quantity FROM cart WHERE user_id = ? AND food_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, foodId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int newQty = rs.getInt("quantity") + qty;
                String updSql = "UPDATE cart SET quantity = ? WHERE user_id = ? AND food_id = ?";
                try (PreparedStatement upd = conn.prepareStatement(updSql)) {
                    upd.setInt(1, newQty);
                    upd.setInt(2, userId);
                    upd.setInt(3, foodId);
                    upd.executeUpdate();
                }
            } else {
                String insSql = "INSERT INTO cart (user_id, food_id, quantity) VALUES (?, ?, ?)";
                try (PreparedStatement ins = conn.prepareStatement(insSql)) {
                    ins.setInt(1, userId);
                    ins.setInt(2, foodId);
                    ins.setInt(3, qty);
                    ins.executeUpdate();
                }
            }
        }

        String redirectBack = req.getParameter("redirect");
        if (redirectBack != null && !redirectBack.isEmpty()) {
            sendResponse(req, resp, redirectBack);
        } else {
            sendResponse(req, resp, "cart.jsp");
        }
    }

    private void removeFromCart(Connection conn, int userId, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int foodId = Integer.parseInt(req.getParameter("foodId"));
        String sql = "DELETE FROM cart WHERE user_id = ? AND food_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, foodId);
            ps.executeUpdate();
        }
        sendResponse(req, resp, "cart.jsp");
    }

    private void updateCart(Connection conn, int userId, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int foodId   = Integer.parseInt(req.getParameter("foodId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));

        if (quantity <= 0) {
            String sql = "DELETE FROM cart WHERE user_id = ? AND food_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, foodId);
                ps.executeUpdate();
            }
        } else {
            String sql = "UPDATE cart SET quantity = ? WHERE user_id = ? AND food_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, quantity);
                ps.setInt(2, userId);
                ps.setInt(3, foodId);
                ps.executeUpdate();
            }
        }
        sendResponse(req, resp, "cart.jsp");
    }

    private void clearCart(Connection conn, int userId, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        String sql = "DELETE FROM cart WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
        sendResponse(req, resp, "cart.jsp");
    }

    private void sendResponse(HttpServletRequest req, HttpServletResponse resp, String redirectUrl) throws IOException {
        String format = req.getParameter("format");
        String requestedWith = req.getHeader("X-Requested-With");
        if ("fetch".equals(format) || "XMLHttpRequest".equalsIgnoreCase(requestedWith)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("{\"success\":true}");
        } else {
            resp.sendRedirect(redirectUrl);
        }
    }
}
