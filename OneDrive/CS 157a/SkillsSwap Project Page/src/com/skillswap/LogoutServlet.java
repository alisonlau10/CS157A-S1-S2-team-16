package com.skillswap;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            Integer userId = (Integer) session.getAttribute("userId");

            // Log logout activity before invalidating the session
            if (userId != null) {
                Connection conn = null;
                PreparedStatement stmt = null;
                try {
                    conn = DatabaseUtil.getConnection();
                    stmt = conn.prepareStatement(
                        "INSERT INTO activity_log (action_type, timestamp, user_id) "
                        + "VALUES ('LOGOUT', NOW(), ?)");
                    stmt.setInt(1, userId);
                    stmt.executeUpdate();
                } catch (SQLException e) {
                    // Don't block logout if logging fails
                    e.printStackTrace();
                } finally {
                    DatabaseUtil.close(conn, stmt);
                }
            }

            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/src/login.jsp?logout=true");
    }
}
