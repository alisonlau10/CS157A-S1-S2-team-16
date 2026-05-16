package com.skillswap;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class CompleteExchangeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int currentUserId = (Integer) session.getAttribute("userId");
        int requestId = Integer.parseInt(request.getParameter("requestId"));

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            int senderId = -1;
            int receiverId = -1;

            // Get sender and receiver for this exchange
            stmt = conn.prepareStatement(
                "SELECT Sender_ID, Receiver_ID FROM Exchange_Requests " +
                "WHERE Request_ID = ? AND (Sender_ID = ? OR Receiver_ID = ?)"
            );
            stmt.setInt(1, requestId);
            stmt.setInt(2, currentUserId);
            stmt.setInt(3, currentUserId);
            rs = stmt.executeQuery();

            if (!rs.next()) {
                response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");
                return;
            }

            senderId = rs.getInt("Sender_ID");
            receiverId = rs.getInt("Receiver_ID");

            DatabaseUtil.close(null, stmt, rs);
            stmt = null;
            rs = null;

            // Mark exchange completed only if not already completed
            stmt = conn.prepareStatement(
                "UPDATE Exchange_Requests " +
                "SET Status = 'Completed' " +
                "WHERE Request_ID = ? " +
                "AND (Sender_ID = ? OR Receiver_ID = ?) " +
                "AND Status <> 'Completed'"
            );
            stmt.setInt(1, requestId);
            stmt.setInt(2, currentUserId);
            stmt.setInt(3, currentUserId);

            int updatedRows = stmt.executeUpdate();

            DatabaseUtil.close(null, stmt, null);
            stmt = null;

            // Only add credits if the exchange was actually changed to Completed
            if (updatedRows > 0) {
                stmt = conn.prepareStatement(
                    "UPDATE Students SET Credit_Balance = Credit_Balance + 1 WHERE User_ID = ?"
                );

                stmt.setInt(1, senderId);
                stmt.executeUpdate();

                stmt.setInt(1, receiverId);
                stmt.executeUpdate();

                DatabaseUtil.close(null, stmt, null);
                stmt = null;

                // Notify the other user
                int otherUserId = currentUserId == senderId ? receiverId : senderId;

                stmt = conn.prepareStatement(
                    "INSERT INTO Notifications (Message, Status, Created_At, User_ID) " +
                    "VALUES (?, 'Unread', NOW(), ?)"
                );
                stmt.setString(1, "Your exchange has been marked completed.");
                stmt.setInt(2, otherUserId);
                stmt.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");

        } catch (Exception e) {
            throw new ServletException("Error completing exchange", e);
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }
    }
}