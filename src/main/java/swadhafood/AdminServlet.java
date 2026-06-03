package swadhafood;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && "admin".equals(s.getAttribute("userRole"));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect("login.jsp?error=unauthorized");
            return;
        }
        req.getRequestDispatcher("admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        String action = req.getParameter("action");
        try (Connection conn = DBConnection.getConnection()) {
            switch (action == null ? "" : action) {
                case "addRestaurant":    addRestaurant(conn, req, resp);    break;
                case "deleteRestaurant": deleteRestaurant(conn, req, resp); break;
                case "addFood":          addFood(conn, req, resp);          break;
                case "deleteFood":       deleteFood(conn, req, resp);       break;
                case "updateOrderStatus":updateOrderStatus(conn, req, resp);break;
                case "deleteUser":       deleteUser(conn, req, resp);       break;
                default: resp.sendRedirect("admin.jsp");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Admin error: " + e.getMessage());
            req.getRequestDispatcher("admin.jsp").forward(req, resp);
        }
    }

    private void addRestaurant(Connection conn, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        String sql = "INSERT INTO restaurants (name, cuisine, image_url, rating, delivery_time, min_price, description, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, req.getParameter("name"));
            ps.setString(2, req.getParameter("cuisine"));
            ps.setString(3, req.getParameter("imageUrl"));
            ps.setDouble(4, Double.parseDouble(req.getParameter("rating")));
            ps.setString(5, req.getParameter("deliveryTime"));
            ps.setInt(6, Integer.parseInt(req.getParameter("minPrice")));
            ps.setString(7, req.getParameter("description"));
            ps.setString(8, req.getParameter("address"));
            ps.executeUpdate();
        }
        resp.sendRedirect("admin.jsp?tab=restaurants&success=Restaurant+added");
    }

    private void deleteRestaurant(Connection conn, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String sql = "DELETE FROM restaurants WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
        resp.sendRedirect("admin.jsp?tab=restaurants&success=Restaurant+deleted");
    }

    private void addFood(Connection conn, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        String sql = "INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(req.getParameter("restaurantId")));
            ps.setString(2, req.getParameter("name"));
            ps.setDouble(3, Double.parseDouble(req.getParameter("price")));
            ps.setString(4, req.getParameter("imageUrl"));
            ps.setString(5, req.getParameter("description"));
            ps.setString(6, req.getParameter("category"));
            ps.setInt(7, "on".equals(req.getParameter("isVeg")) ? 1 : 0);
            ps.executeUpdate();
        }
        resp.sendRedirect("admin.jsp?tab=foods&success=Food+added");
    }

    private void deleteFood(Connection conn, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String sql = "DELETE FROM foods WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
        resp.sendRedirect("admin.jsp?tab=foods&success=Food+deleted");
    }

    private void updateOrderStatus(Connection conn, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int orderId = Integer.parseInt(req.getParameter("orderId"));
        String status = req.getParameter("deliveryStatus");
        String sql = "UPDATE orders SET delivery_status = ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
        resp.sendRedirect("admin.jsp?tab=orders&success=Order+updated");
    }

    private void deleteUser(Connection conn, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String sql = "DELETE FROM users WHERE id = ? AND role != 'admin'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
        resp.sendRedirect("admin.jsp?tab=users&success=User+deleted");
    }
}
