package swadhafood;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            resp.sendRedirect("dashboard.jsp");
            return;
        }
        req.getRequestDispatcher("register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name     = req.getParameter("name");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirmPassword");
        String phone    = req.getParameter("phone");

        // Validation
        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Check duplicate email
            String checkSql = "SELECT id FROM users WHERE email = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, email.trim());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    req.setAttribute("error", "An account with this email already exists.");
                    req.getRequestDispatcher("register.jsp").forward(req, resp);
                    return;
                }
            }

            // Insert new user
            String insertSql = "INSERT INTO users (name, email, password, phone) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, name.trim());
                ps.setString(2, email.trim());
                ps.setString(3, password); // In production, hash the password
                ps.setString(4, phone != null ? phone.trim() : "");
                ps.executeUpdate();
            }

            // Redirect to login with success
            resp.sendRedirect("login.jsp?registered=true");

        } catch (SQLException e) {
            req.setAttribute("error", "Registration failed: " + e.getMessage());
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }
}
