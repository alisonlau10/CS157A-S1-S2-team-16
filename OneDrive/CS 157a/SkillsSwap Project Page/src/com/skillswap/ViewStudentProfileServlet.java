package com.skillswap;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class ViewStudentProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdParam = request.getParameter("userId");

        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/src/listOfSkills.jsp");
            return;
        }

        int userId = Integer.parseInt(userIdParam);

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            String sql =
                "SELECT u.Full_Name, u.Major, s.Bio, s.Availability_Schedule, " +
                "sk.Title, sk.Description, sk.Experience_Level " +
                "FROM Users u " +
                "JOIN Students s ON u.User_ID = s.User_ID " +
                "LEFT JOIN Skills sk ON u.User_ID = sk.User_ID " +
                "WHERE u.User_ID = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                request.setAttribute("fullName", rs.getString("Full_Name"));
                request.setAttribute("major", rs.getString("Major"));
                request.setAttribute("bio", rs.getString("Bio"));
                request.setAttribute("availability", rs.getString("Availability_Schedule"));
                request.setAttribute("skillTitle", rs.getString("Title"));
                request.setAttribute("skillDescription", rs.getString("Description"));
                request.setAttribute("experienceLevel", rs.getString("Experience_Level"));

                request.getRequestDispatcher("/src/viewStudentProfile.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/src/listOfSkills.jsp");
            }

        } catch (Exception e) {
            throw new ServletException("Error loading student profile", e);
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }
    }
}