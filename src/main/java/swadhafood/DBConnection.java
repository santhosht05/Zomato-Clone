package swadhafood;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection - Singleton JDBC utility for SwadhaFood
 * Update DB_URL, DB_USER, DB_PASS to match your MySQL setup
 */
public class DBConnection {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/swadhafood?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "Santhosht@8"; // Change to your MySQL password

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    /**
     * Returns a new JDBC Connection. Caller is responsible for closing it.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
}
