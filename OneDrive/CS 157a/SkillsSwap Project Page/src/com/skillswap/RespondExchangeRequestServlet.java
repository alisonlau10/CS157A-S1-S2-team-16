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

        int userId = (Integer) session.getAttribute("userId");
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        String action = request.getParameter("action");

        String newStatus = "accept".equalsIgnoreCase(action) ? "Accepted" : "Rejected";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            int senderId = -1;

            stmt = conn.prepareStatement(
                "SELECT Sender_ID FROM Exchange_Requests WHERE Request_ID = ? AND Receiver_ID = ?"
            );
            stmt.setInt(1, requestId);
            stmt.setInt(2, userId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                senderId = rs.getInt("Sender_ID");
            }

            DatabaseUtil.close(null, stmt, rs);
            stmt = null;
            rs = null;

            stmt = conn.prepareStatement(
                "UPDATE Exchange_Requests SET Status = ? " +
                "WHERE Request_ID = ? AND Receiver_ID = ? AND Status = 'Pending'"
            );
            stmt.setString(1, newStatus);
            stmt.setInt(2, requestId);
            stmt.setInt(3, userId);

            int updatedRows = stmt.executeUpdate();

            if (updatedRows > 0 && senderId != -1) {
                PreparedStatement notifStmt = conn.prepareStatement(
                    "INSERT INTO Notifications (Message, Status, Created_At, User_ID) VALUES (?, 'Unread', NOW(), ?)"
                );
                notifStmt.setString(1, "Your exchange request was " + newStatus.toLowerCase() + ".");
                notifStmt.setInt(2, senderId);
                notifStmt.executeUpdate();
                notifStmt.close();
            }

        } catch (Exception e) {
            throw new ServletException("Error responding to exchange request", e);
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }

        response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");
    }
}