package com.skillswap;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.sql.*;
import java.security.MessageDigest;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName      = request.getParameter("fullName");
        String email         = request.getParameter("email");
        String password      = request.getParameter("password");
        String major         = request.getParameter("major");
        String skillsOffered = request.getParameter("skillsOffered");
        String skillsWanted  = request.getParameter("skillsWanted");

        // Validate required fields
        if (isBlank(fullName) || isBlank(email) || isBlank(password)) {
            forwardWithError(request, response, "Full name, email, and password are required.");
            return;
        }

        // Validate university email domain
        if (!email.trim().toLowerCase().endsWith(".edu")) {
            forwardWithError(request, response,
                "Please use a valid university email address (must end in .edu).");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            // Check for duplicate email
            stmt = conn.prepareStatement(
                "SELECT user_id FROM users WHERE university_email = ?");
            stmt.setString(1, email.trim().toLowerCase());
            rs = stmt.executeQuery();
            if (rs.next()) {
                forwardWithError(request, response,
                    "An account with this email already exists. Please log in instead.");
                return;
            }
            DatabaseUtil.close(null, stmt, rs);
            stmt = null; rs = null;

            String passwordHash = hashPassword(password);

            // Insert into users
            stmt = conn.prepareStatement(
                "INSERT INTO users (full_name, university_email, password_hash, major, role, date_created) "
                + "VALUES (?, ?, ?, ?, 'Student', NOW())",
                Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, fullName.trim());
            stmt.setString(2, email.trim().toLowerCase());
            stmt.setString(3, passwordHash);
            stmt.setString(4, major != null ? major.trim() : "");
            stmt.executeUpdate();

            int userId = -1;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) userId = keys.getInt(1);
            }
            DatabaseUtil.close(null, stmt);
            stmt = null;

            if (userId == -1) {
                forwardWithError(request, response, "Registration failed. Please try again.");
                return;
            }

            // Insert into students (bio stores skills wanted until a dedicated table is added)
            String bio = isBlank(skillsWanted) ? "" : "Skills Wanted: " + skillsWanted.trim();
            stmt = conn.prepareStatement(
                "INSERT INTO students (user_id, bio, credit_balance) VALUES (?, ?, 0)");
            stmt.setInt(1, userId);
            stmt.setString(2, bio);
            stmt.executeUpdate();
            DatabaseUtil.close(null, stmt);
            stmt = null;

            // Insert each offered skill (comma-separated) into Skills table
            if (!isBlank(skillsOffered)) {
                stmt = conn.prepareStatement(
                    "INSERT INTO skills (title, description, experience_level, status, user_id, category_id) "
                    + "VALUES (?, '', 'Beginner', 'Active', ?, 1)");
                for (String skill : skillsOffered.split(",")) {
                    String s = skill.trim();
                    if (!s.isEmpty()) {
                        stmt.setString(1, s);
                        stmt.setInt(2, userId);
                        stmt.addBatch();
                    }
                }
                stmt.executeBatch();
                DatabaseUtil.close(null, stmt);
                stmt = null;
            }

            // Log registration activity
            stmt = conn.prepareStatement(
                "INSERT INTO activity_log (action_type, timestamp, user_id) VALUES ('REGISTER', NOW(), ?)");
            stmt.setInt(1, userId);
            stmt.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/src/login.jsp?registered=true");

        } catch (Exception e) {
            forwardWithError(request, response, "Registration error: " + e.getMessage());
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/src/register.jsp");
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp, String error)
            throws ServletException, IOException {
        // Redirect instead of forward so the browser URL stays on register.jsp
        // (prevents relative links from resolving against the servlet URL)
        resp.sendRedirect(req.getContextPath()
            + "/src/register.jsp?error=" + URLEncoder.encode(error, "UTF-8"));
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) sb.append(String.format("%02x", b));
        return sb.toString();
    }
}
