<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");

    List<int[]> partnerIds = new ArrayList<>();
    List<String> partnerNames = new ArrayList<>();
    List<String> lastMessages = new ArrayList<>();
    List<String> lastTimes = new ArrayList<>();

    List<Integer> allUserIds = new ArrayList<>();
    List<String> allUserNames = new ArrayList<>();

    int selectedPartnerId = -1;
    String selectedPartnerName = "";
    List<String[]> conversation = new ArrayList<>();

    String partnerIdParam = request.getParameter("partnerId");
    if (partnerIdParam != null && !partnerIdParam.isEmpty()) {
        try {
            selectedPartnerId = Integer.parseInt(partnerIdParam);
        } catch (NumberFormatException ignored) {}
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = com.skillswap.DatabaseUtil.getConnection();

        // All possible students to message
        stmt = conn.prepareStatement(
            "SELECT User_ID, Full_Name FROM Users WHERE User_ID != ? AND Role = 'Student' ORDER BY Full_Name"
        );
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();

        while (rs.next()) {
            allUserIds.add(rs.getInt("User_ID"));
            allUserNames.add(rs.getString("Full_Name"));
        }

        com.skillswap.DatabaseUtil.close(null, stmt, rs);
        stmt = null;
        rs = null;

        // Existing conversations
        stmt = conn.prepareStatement(
            "SELECT u.User_ID, u.Full_Name, " +
            "       (SELECT m2.Content FROM Messages m2 " +
            "        WHERE (m2.Sender_ID = u.User_ID AND m2.Receiver_ID = ?) " +
            "           OR (m2.Sender_ID = ? AND m2.Receiver_ID = u.User_ID) " +
            "        ORDER BY m2.Timestamp DESC LIMIT 1) AS last_msg, " +
            "       (SELECT m3.Timestamp FROM Messages m3 " +
            "        WHERE (m3.Sender_ID = u.User_ID AND m3.Receiver_ID = ?) " +
            "           OR (m3.Sender_ID = ? AND m3.Receiver_ID = u.User_ID) " +
            "        ORDER BY m3.Timestamp DESC LIMIT 1) AS last_time " +
            "FROM Users u " +
            "WHERE u.User_ID IN ( " +
            "   SELECT DISTINCT CASE " +
            "       WHEN Sender_ID = ? THEN Receiver_ID " +
            "       ELSE Sender_ID " +
            "   END " +
            "   FROM Messages " +
            "   WHERE Sender_ID = ? OR Receiver_ID = ? " +
            ") " +
            "ORDER BY last_time DESC"
        );

        stmt.setInt(1, userId);
        stmt.setInt(2, userId);
        stmt.setInt(3, userId);
        stmt.setInt(4, userId);
        stmt.setInt(5, userId);
        stmt.setInt(6, userId);
        stmt.setInt(7, userId);

        rs = stmt.executeQuery();

        while (rs.next()) {
            partnerIds.add(new int[]{rs.getInt("User_ID")});
            partnerNames.add(rs.getString("Full_Name"));

            String lastMsg = rs.getString("last_msg");
            lastMessages.add(lastMsg != null ? lastMsg : "");

            Timestamp ts = rs.getTimestamp("last_time");
            lastTimes.add(ts != null ? ts.toString().substring(0, 16) : "");
        }

        com.skillswap.DatabaseUtil.close(null, stmt, rs);
        stmt = null;
        rs = null;

        // Load selected partner name and conversation
        if (selectedPartnerId > 0) {
            stmt = conn.prepareStatement("SELECT Full_Name FROM Users WHERE User_ID = ?");
            stmt.setInt(1, selectedPartnerId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                selectedPartnerName = rs.getString("Full_Name");
            }

            com.skillswap.DatabaseUtil.close(null, stmt, rs);
            stmt = null;
            rs = null;

            stmt = conn.prepareStatement(
                "SELECT Sender_ID, Content, Timestamp FROM Messages " +
                "WHERE (Sender_ID = ? AND Receiver_ID = ?) " +
                "   OR (Sender_ID = ? AND Receiver_ID = ?) " +
                "ORDER BY Timestamp ASC"
            );

            stmt.setInt(1, userId);
            stmt.setInt(2, selectedPartnerId);
            stmt.setInt(3, selectedPartnerId);
            stmt.setInt(4, userId);

            rs = stmt.executeQuery();

            while (rs.next()) {
                Timestamp ts = rs.getTimestamp("Timestamp");

                conversation.add(new String[]{
                    String.valueOf(rs.getInt("Sender_ID")),
                    rs.getString("Content"),
                    ts != null ? ts.toString().substring(0, 16) : ""
                });
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        com.skillswap.DatabaseUtil.close(conn, stmt, rs);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Messages - SkillSwap Campus</title>

    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            min-height: 100vh;
            padding: 20px;
        }

        .navbar {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 15px 25px;
            background: #F8C8DC;
            border-radius: 20px;
            margin-bottom: 30px;
        }

        .navbar .brand {
            font-family: cursive;
            font-size: 1.4rem;
            color: #7a2d3b;
            font-weight: 700;
            margin-right: auto;
        }

        .navbar a {
            text-decoration: none;
            color: #2c7be5;
            font-weight: bold;
            padding: 6px 12px;
            border-radius: 8px;
        }

        .navbar a:hover { background: rgba(255,255,255,0.6); }

        .btn-logout {
            background: #AA336A;
            color: white !important;
            padding: 7px 16px;
            border-radius: 10px;
        }

        .page-title {
            font-family: cursive;
            font-size: 1.6rem;
            color: #7a2d3b;
            margin-bottom: 20px;
        }

        .messages-container {
            display: flex;
            gap: 20px;
            height: calc(100vh - 180px);
            min-height: 500px;
        }

        .conversation-list {
            width: 320px;
            background: white;
            border: 2px solid #F3CFC6;
            border-radius: 16px;
            overflow-y: auto;
        }

        .conv-list-header {
            padding: 16px 18px;
            font-family: cursive;
            font-size: 1.1rem;
            color: #7a2d3b;
            border-bottom: 2px solid #F3CFC6;
        }

        .start-chat-box {
            padding: 14px;
            border-bottom: 1px solid #f9e8f0;
        }

        .start-chat-box select {
            width: 100%;
            padding: 9px;
            border-radius: 10px;
            border: 1px solid #F3CFC6;
        }

        .conv-item {
            display: block;
            padding: 14px 18px;
            border-bottom: 1px solid #f9e8f0;
            text-decoration: none;
            color: inherit;
        }

        .conv-item:hover { background: #fff5f9; }

        .conv-item.active {
            background: #fde8f0;
            border-left: 4px solid #AA336A;
        }

        .conv-name {
            font-weight: bold;
            color: #7a2d3b;
            font-size: 0.95rem;
        }

        .conv-preview {
            color: #999;
            font-size: 0.82rem;
            margin-top: 4px;
        }

        .conv-time {
            color: #bbb;
            font-size: 0.75rem;
            margin-top: 3px;
        }

        .no-convs {
            padding: 30px 18px;
            color: #aaa;
            font-size: 0.9rem;
            text-align: center;
        }

        .chat-panel {
            flex: 1;
            background: white;
            border: 2px solid #F3CFC6;
            border-radius: 16px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .chat-header {
            padding: 16px 20px;
            border-bottom: 2px solid #F3CFC6;
            font-family: cursive;
            font-size: 1.1rem;
            color: #7a2d3b;
        }

        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .empty-chat {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ccc;
            font-size: 1rem;
            flex-direction: column;
            gap: 10px;
        }

        .empty-chat .icon { font-size: 2.5rem; }

        .bubble {
            max-width: 65%;
            padding: 10px 14px;
            border-radius: 14px;
            font-size: 0.92rem;
            line-height: 1.45;
            word-wrap: break-word;
        }

        .bubble.mine {
            align-self: flex-end;
            background: #AA336A;
            color: white;
            border-bottom-right-radius: 4px;
        }

        .bubble.theirs {
            align-self: flex-start;
            background: #f9e8f0;
            color: #333;
            border-bottom-left-radius: 4px;
        }

        .bubble-time {
            font-size: 0.72rem;
            margin-top: 4px;
            opacity: 0.65;
        }

        .send-form {
            padding: 14px 16px;
            border-top: 2px solid #F3CFC6;
            display: flex;
            gap: 10px;
        }

        .send-form textarea {
            flex: 1;
            padding: 10px 14px;
            border: 2px solid #F3CFC6;
            border-radius: 12px;
            font-size: 0.92rem;
            resize: none;
            min-height: 44px;
        }

        .send-btn {
            padding: 10px 20px;
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: bold;
            cursor: pointer;
        }

        .send-btn:hover { background: #8e2a58; }
    </style>
</head>

<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="SkillSwap.jsp">Home</a>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="<%= request.getContextPath() %>/searchSkills">Browse Skills</a>
    <a href="mySkills.jsp">My Skills</a>
    <a href="addSkill.jsp">Add Skill</a>
    <a href="messages.jsp">Messages</a>
    <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<h2 class="page-title">💌 Messages</h2>

<div class="messages-container">

    <div class="conversation-list">
        <div class="conv-list-header">Conversations</div>

        <div class="start-chat-box">
            <form method="get" action="messages.jsp">
                <select name="partnerId" onchange="this.form.submit()">
                    <option value="">Start a conversation...</option>
                    <% for (int i = 0; i < allUserIds.size(); i++) { %>
                        <option value="<%= allUserIds.get(i) %>"
                            <%= allUserIds.get(i) == selectedPartnerId ? "selected" : "" %>>
                            <%= allUserNames.get(i) %>
                        </option>
                    <% } %>
                </select>
            </form>
        </div>

        <% if (partnerIds.isEmpty()) { %>
            <div class="no-convs">No messages yet.<br>Select a student above to start chatting.</div>
        <% } else {
            for (int i = 0; i < partnerIds.size(); i++) {
                int pid = partnerIds.get(i)[0];
                boolean active = pid == selectedPartnerId;
        %>
            <a class="conv-item <%= active ? "active" : "" %>"
               href="messages.jsp?partnerId=<%= pid %>">
                <div class="conv-name"><%= partnerNames.get(i) %></div>
                <div class="conv-preview"><%= lastMessages.get(i) %></div>
                <div class="conv-time"><%= lastTimes.get(i) %></div>
            </a>
        <% }} %>
    </div>

    <div class="chat-panel">
        <% if (selectedPartnerId > 0 && !selectedPartnerName.isEmpty()) { %>

            <div class="chat-header">👤 <%= selectedPartnerName %></div>

            <div class="chat-messages" id="chatMessages">
                <% if (conversation.isEmpty()) { %>
                    <div class="empty-chat">
                        <span class="icon">💬</span>
                        <span>No messages yet. Say hello!</span>
                    </div>
                <% } else {
                    for (String[] msg : conversation) {
                        boolean mine = Integer.parseInt(msg[0]) == userId;
                %>
                    <div style="display:flex; flex-direction:column; align-items:<%= mine ? "flex-end" : "flex-start" %>;">
                        <div class="bubble <%= mine ? "mine" : "theirs" %>">
                            <%= msg[1] %>
                            <div class="bubble-time"><%= msg[2] %></div>
                        </div>
                    </div>
                <% }} %>
            </div>

            <form class="send-form" method="post" action="<%= request.getContextPath() %>/sendMessage">
                <input type="hidden" name="receiverId" value="<%= selectedPartnerId %>">
                <textarea name="body" placeholder="Type a message..." required></textarea>
                <button type="submit" class="send-btn">Send ➤</button>
            </form>

        <% } else { %>
            <div class="empty-chat">
                <span class="icon">💌</span>
                <span>Select a student to start messaging.</span>
            </div>
        <% } %>
    </div>

</div>

<script>
    var chat = document.getElementById("chatMessages");
    if (chat) chat.scrollTop = chat.scrollHeight;
</script>

<script>
setInterval(function() {
    if (document.activeElement.tagName !== "TEXTAREA") {
        location.reload();
    }
}, 5000);
</script>

</body>
</html>