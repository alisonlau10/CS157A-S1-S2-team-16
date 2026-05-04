package com.skillswap;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/addSkill")
public class AddSkillServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String experienceLevel = request.getParameter("experienceLevel");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();

            String sql = "INSERT INTO Skills (Title, Description, Experience_Level, Status, User_ID, Category_ID) "
                       + "VALUES (?, ?, ?, 'Active', ?, ?)";

            stmt = conn.prepareStatement(sql);
            stmt.setString(1, title);
            stmt.setString(2, description);
            stmt.setString(3, experienceLevel);
            stmt.setInt(4, userId);
            stmt.setInt(5, categoryId);

            stmt.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/src/mySkills.jsp");

        } catch (Exception e) {
            throw new ServletException("Error adding skill", e);
        } finally {
            DatabaseUtil.close(conn, stmt);
        }
    }
}