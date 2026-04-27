package com.skillswap;

import java.io.*;
import java.sql.*;
import java.util.Properties;

public class DatabaseUtil {

    private static final String DB_URL;
    private static final String DB_USER;
    private static final String DB_PASSWORD;

    static {
        // Load credentials from WEB-INF/db.properties so each developer
        // keeps their own local password out of version control.
        Properties props = new Properties();
        // db.properties lives in WEB-INF/classes/ (on the classpath)
        try (InputStream in = DatabaseUtil.class
                .getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) throw new IOException("db.properties not found on classpath");
            props.load(in);
        } catch (IOException e) {
            throw new RuntimeException(
                "Cannot load db.properties. Copy WEB-INF/db.properties.example "
                + "to WEB-INF/classes/db.properties and fill in your credentials.", e);
        }

        DB_URL      = props.getProperty("db.url");
        DB_USER     = props.getProperty("db.user");
        DB_PASSWORD = props.getProperty("db.password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    public static void close(Connection conn, PreparedStatement stmt, ResultSet rs) {
        try { if (rs   != null) rs.close();   } catch (SQLException ignored) {}
        try { if (stmt != null) stmt.close(); } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }

    public static void close(Connection conn, PreparedStatement stmt) {
        close(conn, stmt, null);
    }

    public static void close(Connection conn) {
        close(conn, null, null);
    }
}
