package com.skillswap;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class DeleteAccountServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/src/deleteAccount.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();

            // Cancel pending exchange requests before deletion
            stmt = conn.prepareStatement(
                "UPDATE exchange_requests SET status = 'Cancelled' "
                + "WHERE (sender_id = ? OR receiver_id = ?) "
                + "AND status IN ('Pending', 'Accepted', 'In Progress')");
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
            DatabaseUtil.close(null, stmt);
            stmt = null;

            // Delete user — CASCADE handles Students, Skills, Exchange_Requests, etc.
            stmt = conn.prepareStatement("DELETE FROM users WHERE user_id = ?");
            stmt.setInt(1, userId);
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DatabaseUtil.close(conn, stmt);
        }

        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/src/login.jsp?deleted=true");
    }
}
