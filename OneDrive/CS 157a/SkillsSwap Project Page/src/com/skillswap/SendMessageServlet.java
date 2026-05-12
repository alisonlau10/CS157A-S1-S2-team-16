package com.skillswap;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class SendMessageServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("src/login.jsp");
            return;
        }

        int senderId = (int) session.getAttribute("userId");
        int receiverId = Integer.parseInt(request.getParameter("receiverId"));
        String content = request.getParameter("body");

        if (content == null || content.trim().isEmpty()) {
            response.sendRedirect("src/messages.jsp?error=empty");
            return;
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO Messages (Content, Timestamp, Sender_ID, Receiver_ID) VALUES (?, NOW(), ?, ?)"
             )) {

            stmt.setString(1, content.trim());
            stmt.setInt(2, senderId);
            stmt.setInt(3, receiverId);
            stmt.executeUpdate();

            PreparedStatement notifStmt = conn.prepareStatement(
                "INSERT INTO Notifications (Message, Status, Created_At, User_ID) VALUES (?, 'Unread', NOW(), ?)"
    
            );

             notifStmt.setString(1, "You received a new message.");
             notifStmt.setInt(2, receiverId);
             notifStmt.executeUpdate();
             notifStmt.close();

            response.sendRedirect("src/messages.jsp?receiverId=" + receiverId + "&success=sent");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error sending message", e);
        }
    }
}