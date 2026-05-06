package com.skillswap;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class RespondExchangeRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int userId    = (Integer) session.getAttribute("userId");
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        String action = request.getParameter("action"); // "accept" or "reject"

        String newStatus = "accept".equalsIgnoreCase(action) ? "Accepted" : "Rejected";

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();

            // Only the receiver may accept or reject a Pending request
            stmt = conn.prepareStatement(
                "UPDATE Exchange_Requests SET Status = ? " +
                "WHERE Request_ID = ? AND Receiver_ID = ? AND Status = 'Pending'"
            );
            stmt.setString(1, newStatus);
            stmt.setInt(2, requestId);
            stmt.setInt(3, userId);
            stmt.executeUpdate();

        } catch (Exception e) {
            throw new ServletException("Error responding to exchange request", e);
        } finally {
            DatabaseUtil.close(conn, stmt);
        }

        response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");
    }
}
