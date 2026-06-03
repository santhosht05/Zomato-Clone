package swadhafood;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            resp.sendRedirect("dashboard.jsp");
            return;
        }
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String redirect = req.getParameter("redirect");

        // Basic input validation
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id, name, email, role FROM users WHERE email = ? AND password = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email.trim());
                ps.setString(2, password);  // In production use hashed passwords
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    HttpSession session = req.getSession(true);
                    session.setAttribute("userId",    rs.getInt("id"));
                    session.setAttribute("userName",  rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("userRole",  rs.getString("role"));
                    session.setMaxInactiveInterval(30 * 60); // 30 min

                    if ("admin".equals(rs.getString("role"))) {
                        resp.sendRedirect("admin.jsp");
                    } else {
                        if ("cart".equals(redirect)) {
                            resp.sendRedirect("cart.jsp");
                        } else if (redirect != null && !redirect.isEmpty()) {
                            resp.sendRedirect(redirect);
                        } else {
                            resp.sendRedirect("dashboard.jsp");
                        }
                    }
                } else {
                    req.setAttribute("error", "Invalid email or password. Please try again.");
                    req.getRequestDispatcher("login.jsp").forward(req, resp);
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }
}
