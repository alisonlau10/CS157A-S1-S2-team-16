<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int    userId   = (Integer) session.getAttribute("userId");
    String userName = (String)  session.getAttribute("userName");

    // Fetch conversations: distinct users this student has exchanged messages with
    java.util.List<int[]>    partnerIds   = new java.util.ArrayList<>();
    java.util.List<String>   partnerNames = new java.util.ArrayList<>();
    java.util.List<String>   lastMessages = new java.util.ArrayList<>();
    java.util.List<String>   lastTimes    = new java.util.ArrayList<>();
    java.util.List<Boolean>  unreadFlags  = new java.util.ArrayList<>();

    // Messages for the selected conversation
    int    selectedPartnerId   = -1;
    String selectedPartnerName = "";
    java.util.List<String[]> conversation = new java.util.ArrayList<>();

    String partnerIdParam = request.getParameter("partnerId");
    if (partnerIdParam != null && !partnerIdParam.isEmpty()) {
        try { selectedPartnerId = Integer.parseInt(partnerIdParam); } catch (NumberFormatException ignored) {}
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    try {
        conn = com.skillswap.DatabaseUtil.getConnection();

        // Load conversation list
        stmt = conn.prepareStatement(
            "SELECT u.user_id, u.username, "
            + "  (SELECT m2.body FROM messages m2 "
            + "   WHERE (m2.sender_id = u.user_id AND m2.receiver_id = ?) "
            + "      OR (m2.sender_id = ? AND m2.receiver_id = u.user_id) "
            + "   ORDER BY m2.sent_at DESC LIMIT 1) AS last_msg, "
            + "  (SELECT m3.sent_at FROM messages m3 "
            + "   WHERE (m3.sender_id = u.user_id AND m3.receiver_id = ?) "
            + "      OR (m3.sender_id = ? AND m3.receiver_id = u.user_id) "
            + "   ORDER BY m3.sent_at DESC LIMIT 1) AS last_time, "
            + "  (SELECT COUNT(*) FROM messages m4 "
            + "   WHERE m4.sender_id = u.user_id AND m4.receiver_id = ? AND m4.is_read = 0) AS unread_count "
            + "FROM users u "
            + "WHERE u.user_id IN ("
            + "  SELECT DISTINCT CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END "
            + "  FROM messages WHERE sender_id = ? OR receiver_id = ?) "
            + "ORDER BY last_time DESC");
        stmt.setInt(1, userId);
        stmt.setInt(2, userId);
        stmt.setInt(3, userId);
        stmt.setInt(4, userId);
        stmt.setInt(5, userId);
        stmt.setInt(6, userId);
        stmt.setInt(7, userId);
        stmt.setInt(8, userId);
        rs = stmt.executeQuery();
        while (rs.next()) {
            partnerIds.add(new int[]{ rs.getInt("user_id") });
            partnerNames.add(rs.getString("username"));
            String lm = rs.getString("last_msg");
            lastMessages.add(lm != null ? lm : "");
            Timestamp ts = rs.getTimestamp("last_time");
            lastTimes.add(ts != null ? ts.toString().substring(0, 16) : "");
            unreadFlags.add(rs.getInt("unread_count") > 0);
        }
        com.skillswap.DatabaseUtil.close(null, stmt, rs);
        stmt = null; rs = null;

        // If a partner is selected, load the conversation and mark messages read
        if (selectedPartnerId > 0) {
            // Resolve partner name if not in list
            for (int i = 0; i < partnerIds.size(); i++) {
                if (partnerIds.get(i)[0] == selectedPartnerId) {
                    selectedPartnerName = partnerNames.get(i);
                    break;
                }
            }
            if (selectedPartnerName.isEmpty()) {
                stmt = conn.prepareStatement("SELECT username FROM users WHERE user_id = ?");
                stmt.setInt(1, selectedPartnerId);
                rs = stmt.executeQuery();
                if (rs.next()) selectedPartnerName = rs.getString("username");
                com.skillswap.DatabaseUtil.close(null, stmt, rs);
                stmt = null; rs = null;
            }

            stmt = conn.prepareStatement(
                "SELECT sender_id, body, sent_at FROM messages "
                + "WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) "
                + "ORDER BY sent_at ASC");
            stmt.setInt(1, userId);
            stmt.setInt(2, selectedPartnerId);
            stmt.setInt(3, selectedPartnerId);
            stmt.setInt(4, userId);
            rs = stmt.executeQuery();
            while (rs.next()) {
                conversation.add(new String[]{
                    String.valueOf(rs.getInt("sender_id")),
                    rs.getString("body"),
                    rs.getTimestamp("sent_at").toString().substring(0, 16)
                });
            }
            com.skillswap.DatabaseUtil.close(null, stmt, rs);
            stmt = null; rs = null;

            // Mark messages from partner as read
            stmt = conn.prepareStatement(
                "UPDATE messages SET is_read = 1 WHERE sender_id = ? AND receiver_id = ?");
            stmt.setInt(1, selectedPartnerId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Messages - SkillSwap Campus</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            min-height: 100vh;
            padding: 20px;
        }

        /* ── Navbar ── */
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
            transition: background 0.2s;
        }
        .navbar a:hover { background: rgba(255,255,255,0.6); }
        .navbar .btn-logout {
            background: #AA336A;
            color: white;
            padding: 7px 16px;
            border-radius: 10px;
            font-weight: bold;
            text-decoration: none;
            transition: background 0.2s;
        }
        .navbar .btn-logout:hover { background: #8e2a58; }

        /* ── Page title ── */
        .page-title {
            font-family: cursive;
            font-size: 1.6rem;
            color: #7a2d3b;
            margin-bottom: 20px;
        }

        /* ── Messages layout ── */
        .messages-container {
            display: flex;
            gap: 20px;
            height: calc(100vh - 180px);
            min-height: 400px;
        }

        /* ── Conversation list ── */
        .conversation-list {
            width: 300px;
            flex-shrink: 0;
            background: #fff;
            border: 2px solid #F3CFC6;
            border-radius: 16px;
            overflow-y: auto;
            box-shadow: 0 2px 10px rgba(170,51,106,0.06);
        }
        .conv-list-header {
            padding: 16px 18px;
            font-family: cursive;
            font-size: 1.1rem;
            color: #7a2d3b;
            border-bottom: 2px solid #F3CFC6;
            position: sticky;
            top: 0;
            background: #fff;
        }
        .conv-item {
            display: block;
            padding: 14px 18px;
            border-bottom: 1px solid #f9e8f0;
            text-decoration: none;
            color: inherit;
            transition: background 0.15s;
            cursor: pointer;
        }
        .conv-item:hover { background: #fff5f9; }
        .conv-item.active { background: #fde8f0; border-left: 4px solid #AA336A; }
        .conv-name {
            font-weight: bold;
            color: #7a2d3b;
            font-size: 0.95rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .conv-preview {
            color: #999;
            font-size: 0.82rem;
            margin-top: 3px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .conv-time { color: #bbb; font-size: 0.75rem; }
        .unread-dot {
            width: 9px; height: 9px;
            background: #AA336A;
            border-radius: 50%;
            display: inline-block;
            flex-shrink: 0;
        }
        .no-convs {
            padding: 30px 18px;
            color: #aaa;
            font-size: 0.9rem;
            text-align: center;
        }

        /* ── Chat panel ── */
        .chat-panel {
            flex: 1;
            background: #fff;
            border: 2px solid #F3CFC6;
            border-radius: 16px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 2px 10px rgba(170,51,106,0.06);
            overflow: hidden;
        }
        .chat-header {
            padding: 16px 20px;
            border-bottom: 2px solid #F3CFC6;
            font-family: cursive;
            font-size: 1.1rem;
            color: #7a2d3b;
            background: #fff;
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
            text-align: right;
        }
        .bubble.theirs .bubble-time { text-align: left; }

        /* ── Send form ── */
        .send-form {
            padding: 14px 16px;
            border-top: 2px solid #F3CFC6;
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }
        .send-form textarea {
            flex: 1;
            padding: 10px 14px;
            border: 2px solid #F3CFC6;
            border-radius: 12px;
            font-size: 0.92rem;
            font-family: Arial, sans-serif;
            resize: none;
            outline: none;
            transition: border-color 0.2s;
            min-height: 44px;
            max-height: 120px;
        }
        .send-form textarea:focus { border-color: #AA336A; }
        .send-form textarea:disabled { background: #f5f5f5; cursor: not-allowed; }
        .send-btn {
            padding: 10px 20px;
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 0.92rem;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
            white-space: nowrap;
        }
        .send-btn:hover { background: #8e2a58; }
        .send-btn:disabled { background: #ccc; cursor: not-allowed; }

        .error-msg {
            background: #fde8e8;
            color: #c0392b;
            border: 1px solid #f5c6cb;
            border-radius: 10px;
            padding: 10px 16px;
            margin-bottom: 16px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="SkillSwap.jsp">Home</a>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="listOfSkills.jsp">Browse Skills</a>
    <a href="mySkills.jsp">My Skills</a>
    <a href="addSkill.jsp">Add Skill</a>
    <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<h2 class="page-title">&#128140; Messages</h2>

<%
    String sendError = (String) session.getAttribute("sendError");
    if (sendError != null) {
        session.removeAttribute("sendError");
%>
<div class="error-msg"><%= sendError %></div>
<% } %>

<div class="messages-container">

    <!-- Conversation list -->
    <div class="conversation-list">
        <div class="conv-list-header">Conversations</div>
        <%
            if (partnerIds.isEmpty()) {
        %>
            <div class="no-convs">No messages yet.<br>Start a conversation from a student's profile.</div>
        <%
            } else {
                for (int i = 0; i < partnerIds.size(); i++) {
                    int pid = partnerIds.get(i)[0];
                    boolean isActive = pid == selectedPartnerId;
        %>
            <a class="conv-item <%= isActive ? "active" : "" %>"
               href="messages.jsp?partnerId=<%= pid %>">
                <div class="conv-name">
                    <span><%= partnerNames.get(i) %></span>
                    <span style="display:flex;align-items:center;gap:6px;">
                        <span class="conv-time"><%= lastTimes.get(i) %></span>
                        <% if (unreadFlags.get(i) && !isActive) { %><span class="unread-dot"></span><% } %>
                    </span>
                </div>
                <div class="conv-preview"><%= lastMessages.get(i) %></div>
            </a>
        <%
                }
            }
        %>
    </div>

    <!-- Chat panel -->
    <div class="chat-panel">
        <% if (selectedPartnerId > 0 && !selectedPartnerName.isEmpty()) { %>

        <div class="chat-header">&#128100; <%= selectedPartnerName %></div>

        <div class="chat-messages" id="chatMessages">
            <% if (conversation.isEmpty()) { %>
                <div class="empty-chat">
                    <span class="icon">&#128172;</span>
                    <span>No messages yet. Say hello!</span>
                </div>
            <% } else {
                for (String[] msg : conversation) {
                    boolean mine = Integer.parseInt(msg[0]) == userId;
            %>
                <div style="display:flex;flex-direction:column;align-items:<%= mine ? "flex-end" : "flex-start" %>;">
                    <div class="bubble <%= mine ? "mine" : "theirs" %>">
                        <%= msg[1] %>
                        <div class="bubble-time"><%= msg[2] %></div>
                    </div>
                </div>
            <%  } } %>
        </div>

        <form class="send-form" method="post"
              action="<%= request.getContextPath() %>/sendMessage">
            <input type="hidden" name="receiverId" value="<%= selectedPartnerId %>">
            <textarea name="body" placeholder="Type a message…" required
                      oninput="this.style.height='auto';this.style.height=this.scrollHeight+'px'"></textarea>
            <button type="submit" class="send-btn">Send &#10148;</button>
        </form>

        <% } else { %>
        <div class="empty-chat">
            <span class="icon">&#128140;</span>
            <span>Select a conversation to start messaging.</span>
        </div>
        <% } %>
    </div>

</div>

<script>
    var chat = document.getElementById('chatMessages');
    if (chat) chat.scrollTop = chat.scrollHeight;
</script>

</body>
</html>
