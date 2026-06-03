package swadhafood;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {

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
        req.getRequestDispatcher("orders.jsp").forward(req, resp);
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

        try (Connection conn = DBConnection.getConnection()) {
            if ("place".equals(action)) {
                placeOrder(conn, userId, req, resp);
            } else {
                resp.sendRedirect("orders.jsp");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Order error: " + e.getMessage());
            req.getRequestDispatcher("orders.jsp").forward(req, resp);
        }
    }

    private void placeOrder(Connection conn, int userId, HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException, ServletException {
        String paymentMethod = req.getParameter("paymentMethod");
        String paymentStatus = req.getParameter("paymentStatus");
        String deliveryAddr  = req.getParameter("deliveryAddress");
        String coupon        = req.getParameter("couponCode");
        String discountStr   = req.getParameter("discount");
        double discount      = 0;
        try { discount = Double.parseDouble(discountStr); } catch (Exception ignored) {}

        // Fetch cart items for this user
        String cartSql = "SELECT c.food_id, c.quantity, f.price, f.name, r.name AS rname " +
                         "FROM cart c " +
                         "JOIN foods f ON c.food_id = f.id " +
                         "JOIN restaurants r ON f.restaurant_id = r.id " +
                         "WHERE c.user_id = ?";

        double totalAmount = 0;
        String restaurantName = "";
        java.util.List<int[]> cartItems = new java.util.ArrayList<>();
        java.util.List<Double> prices   = new java.util.ArrayList<>();
        java.util.List<String> names    = new java.util.ArrayList<>();

        try (PreparedStatement ps = conn.prepareStatement(cartSql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int foodId  = rs.getInt("food_id");
                int qty     = rs.getInt("quantity");
                double price = rs.getDouble("price");
                cartItems.add(new int[]{foodId, qty});
                prices.add(price);
                names.add(rs.getString("name"));
                totalAmount += price * qty;
                restaurantName = rs.getString("rname");
            }
        }

        if (cartItems.isEmpty()) {
            resp.sendRedirect("cart.jsp?empty=true");
            return;
        }

        totalAmount = totalAmount - discount + 40; // delivery charge ₹40

        // Insert order
        String orderSql = "INSERT INTO orders (user_id, restaurant_name, total_amount, payment_method, payment_status, delivery_address, coupon_code, discount) " +
                          "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        int orderId;
        try (PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setString(2, restaurantName);
            ps.setDouble(3, totalAmount);
            ps.setString(4, paymentMethod);
            ps.setString(5, paymentStatus != null ? paymentStatus : "paid");
            ps.setString(6, deliveryAddr);
            ps.setString(7, coupon);
            ps.setDouble(8, discount);
            ps.executeUpdate();
            ResultSet gk = ps.getGeneratedKeys();
            gk.next();
            orderId = gk.getInt(1);
        }

        // Insert order items
        String itemSql = "INSERT INTO order_items (order_id, food_id, food_name, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
            for (int i = 0; i < cartItems.size(); i++) {
                int foodId = cartItems.get(i)[0];
                int qty    = cartItems.get(i)[1];
                double price = prices.get(i);
                ps.setInt(1, orderId);
                ps.setInt(2, foodId);
                ps.setString(3, names.get(i));
                ps.setInt(4, qty);
                ps.setDouble(5, price);
                ps.setDouble(6, price * qty);
                ps.addBatch();
            }
            ps.executeBatch();
        }

        // Clear the user's cart
        String clearSql = "DELETE FROM cart WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(clearSql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }

        resp.sendRedirect("orders.jsp?orderId=" + orderId + "&success=true");
    }
}
