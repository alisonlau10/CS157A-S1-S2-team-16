package com.skillswap;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.sql.*;
import java.security.MessageDigest;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (isBlank(email) || isBlank(password)) {
            forwardWithError(request, response, "Email and password are required.");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            String passwordHash = hashPassword(password);

            stmt = conn.prepareStatement(
                    "SELECT user_id, full_name, role FROM users "
                            + "WHERE university_email = ? AND password_hash = ?");
            stmt.setString(1, email.trim().toLowerCase());
            stmt.setString(2, passwordHash);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("user_id");
                String fullName = rs.getString("full_name");
                String role = rs.getString("role");

                // Create session
                HttpSession session = request.getSession(true);
                session.setAttribute("userId", userId);
                session.setAttribute("userName", fullName);
                session.setAttribute("role", role);
                session.setAttribute("email", email.trim().toLowerCase());

                // Log login activity
                DatabaseUtil.close(null, stmt, rs);
                stmt = conn.prepareStatement(
                        "INSERT INTO activity_log (action_type, timestamp, user_id) VALUES ('LOGIN', NOW(), ?)");
                stmt.setInt(1, userId);
                stmt.executeUpdate();

                // Route by role
                if ("Admin".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/src/dashboard.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/src/dashboard.jsp");
                }

            } else {
                forwardWithError(request, response,
                        "Invalid email or password. Please try again.");
            }

        } catch (Exception e) {
            forwardWithError(request, response, "Login error: " + e.getMessage());
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/src/login.jsp");
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp, String error)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath()
            + "/src/login.jsp?error=" + URLEncoder.encode(error, "UTF-8"));
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash)
            sb.append(String.format("%02x", b));
        return sb.toString();
    }
}
