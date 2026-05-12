<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Notifications - SkillSwap Campus</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            padding: 20px;
        }

        .navbar {
            display: flex;
            align-items: center;
            gap: 16px;
            background: #F8C8DC;
            border-radius: 20px;
            padding: 15px 25px;
            margin-bottom: 30px;
        }

        .navbar .brand {
            font-family: cursive;
            font-size: 1.4rem;
            color: #7a2d3b;
            font-weight: bold;
            margin-right: auto;
        }

        .navbar a {
            text-decoration: none;
            color: #2c7be5;
            font-weight: bold;
            padding: 6px 12px;
            border-radius: 8px;
        }

        .navbar a:hover {
            background: rgba(255,255,255,0.6);
        }

        .btn-logout {
            background: #AA336A;
            color: white !important;
            padding: 7px 16px;
            border-radius: 10px;
        }

        .container {
            max-width: 850px;
            margin: 0 auto;
            background: white;
            border: 2px solid #F3CFC6;
            border-radius: 18px;
            padding: 30px;
        }

        h2 {
            font-family: cursive;
            color: #7a2d3b;
            margin-bottom: 20px;
        }

        .notification {
            padding: 15px;
            border-bottom: 1px solid #f3d6df;
            border-radius: 10px;
            margin-bottom: 10px;
        }

        .unread {
            background: #fff0f6;
            font-weight: bold;
            border-left: 5px solid #AA336A;
        }

        .read {
            background: #ffffff;
            color: #555;
        }

        .time {
            color: #888;
            font-size: 0.85rem;
            margin-top: 6px;
        }

        .empty {
            color: #999;
            text-align: center;
            padding: 30px;
        }
    </style>
</head>

<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="<%= request.getContextPath() %>/src/dashboard.jsp">Dashboard</a>
    <a href="<%= request.getContextPath() %>/search">Browse Skills</a>
    <a href="<%= request.getContextPath() %>/src/mySkills.jsp">My Skills</a>
    <a href="<%= request.getContextPath() %>/src/messages.jsp">Messages</a>
    <a href="<%= request.getContextPath() %>/src/notifications.jsp">Notifications</a>
    <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<div class="container">
    <h2>🔔 Notifications</h2>

    <%
        try {
            conn = com.skillswap.DatabaseUtil.getConnection();

            stmt = conn.prepareStatement(
                "SELECT Notification_ID, Message, Status, Created_At " +
                "FROM Notifications " +
                "WHERE User_ID = ? " +
                "ORDER BY Created_At DESC"
            );
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            boolean hasNotifications = false;

            while (rs.next()) {
                hasNotifications = true;
                String status = rs.getString("Status");
    %>

    <%
    String message = rs.getString("Message");
    String link = request.getContextPath() + "/src/dashboard.jsp";

    if (message.toLowerCase().contains("message")) {
        link = request.getContextPath() + "/src/messages.jsp";
    } else if (message.toLowerCase().contains("exchange")) {
        link = request.getContextPath() + "/trackExchangeStatus";
    }
%>

<a href="<%= link %>" style="text-decoration:none; color:inherit;">
    <div class="notification <%= "Unread".equals(status) ? "unread" : "read" %>">
        <%= message %>
        <div class="time"><%= rs.getTimestamp("Created_At") %></div>
    </div>
</a>

    <%
            }

            if (!hasNotifications) {
    %>
        <div class="empty">No notifications yet.</div>
    <%
            }

        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading notifications.</p>");
            e.printStackTrace();
        } finally {
            com.skillswap.DatabaseUtil.close(conn, stmt, rs);
        }
    %>
</div>

</body>
</html>