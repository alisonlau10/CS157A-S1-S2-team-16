package com.skillswap;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class DeleteUserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("Admin")) {
            response.sendRedirect(request.getContextPath() + "/src/dashboard.jsp");
            return;
        }

        int userId = Integer.parseInt(request.getParameter("userId"));

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                "DELETE FROM Users WHERE User_ID = ? AND Role <> 'Admin'"
             )) {

            stmt.setInt(1, userId);
            stmt.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/src/adminDashboard.jsp");

        } catch (Exception e) {
            throw new ServletException("Error deleting user", e);
        }
    }
}