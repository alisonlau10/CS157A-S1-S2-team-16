package com.skillswap;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.sql.*;

public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/src/editProfile.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int    userId           = (Integer) session.getAttribute("userId");
        String fullName         = request.getParameter("fullName");
        String major            = request.getParameter("major");
        String bio              = request.getParameter("bio");
        String availability     = request.getParameter("availability");
        String profilePicture   = request.getParameter("profilePicture");
        String skillsOffered    = request.getParameter("skillsOffered");
        String skillsWanted     = request.getParameter("skillsWanted");

        if (isBlank(fullName)) {
            redirect(response, request, "Full name is required.");
            return;
        }

        // Encode skills wanted into bio using a clear delimiter
        String cleanBio = bio != null ? bio.trim() : "";
        String swPart   = isBlank(skillsWanted) ? "" : "\n---Skills Wanted: " + skillsWanted.trim();
        String storedBio = cleanBio + swPart;

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();

            // Update users table
            stmt = conn.prepareStatement(
                "UPDATE users SET full_name = ?, major = ? WHERE user_id = ?");
            stmt.setString(1, fullName.trim());
            stmt.setString(2, major != null ? major.trim() : "");
            stmt.setInt(3, userId);
            stmt.executeUpdate();
            DatabaseUtil.close(null, stmt);
            stmt = null;

            // Update students table
            stmt = conn.prepareStatement(
                "UPDATE students SET bio = ?, profile_picture = ?, availability_schedule = ? "
                + "WHERE user_id = ?");
            stmt.setString(1, storedBio);
            stmt.setString(2, profilePicture != null ? profilePicture.trim() : "");
            stmt.setString(3, availability != null ? availability.trim() : "");
            stmt.setInt(4, userId);
            stmt.executeUpdate();
            DatabaseUtil.close(null, stmt);
            stmt = null;

            // Update skills offered: mark old ones inactive, insert new ones
            stmt = conn.prepareStatement(
                "UPDATE skills SET status = 'Inactive' WHERE user_id = ?");
            stmt.setInt(1, userId);
            stmt.executeUpdate();
            DatabaseUtil.close(null, stmt);
            stmt = null;

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

            // Update session with new name
            session.setAttribute("userName", fullName.trim());

            // Log profile update
            stmt = conn.prepareStatement(
                "INSERT INTO activity_log (action_type, timestamp, user_id) VALUES ('PROFILE_UPDATE', NOW(), ?)");
            stmt.setInt(1, userId);
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            redirect(response, request, "Update failed: " + e.getMessage());
            return;
        } finally {
            DatabaseUtil.close(conn, stmt);
        }

        response.sendRedirect(request.getContextPath() + "/src/editProfile.jsp?updated=true");
    }

    private void redirect(HttpServletResponse resp, HttpServletRequest req, String error)
            throws IOException {
        resp.sendRedirect(req.getContextPath()
            + "/src/editProfile.jsp?error=" + URLEncoder.encode(error, "UTF-8"));
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
