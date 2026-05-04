package com.skillswap;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/deleteSkill")
public class DeleteSkillServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int skillId = Integer.parseInt(request.getParameter("skillId"));

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();

            stmt = conn.prepareStatement("DELETE FROM Skills WHERE Skill_ID = ?");
            stmt.setInt(1, skillId);
            stmt.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/src/mySkills.jsp");

        } catch (Exception e) {
            throw new ServletException("Error deleting skill", e);
        } finally {
            DatabaseUtil.close(conn, stmt);
        }
    }
}