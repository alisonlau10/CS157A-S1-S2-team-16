<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Exchanges</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            padding: 20px;
        }

        .container {
            max-width: 1100px;
            margin: 40px auto;
            background: white;
            border: 2px solid #F3CFC6;
            border-radius: 18px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(170,51,106,0.08);
        }

        h1 {
            font-family: cursive;
            color: #7a2d3b;
            margin-bottom: 8px;
        }

        .subtitle {
            color: #777;
            margin-bottom: 24px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            overflow: hidden;
            border-radius: 12px;
            table-layout: fixed;
        }

        th {
            background: #F8C8DC;
            color: #7a2d3b;
            padding: 14px;
            text-align: left;
        }

        td {
            padding: 13px 14px;
            border-bottom: 1px solid #f3d6df;
        }

        tr:hover {
            background: #fff7fa;
        }

        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            background: #f7e4ec;
            color: #7a2d3b;
            font-weight: bold;
            font-size: 0.85rem;
        }

        .action-btn {
            display: inline-block;
            border: none;
            border-radius: 10px;
            padding: 7px 12px;
            font-weight: bold;
            font-size: 0.82rem;
            cursor: pointer;
            text-decoration: none;
            margin: 2px 2px 2px 0;
        }
        .btn-complete  { background: #AA336A; color: white; }
        .btn-complete:hover { background: #8e2a58; }
        .btn-accept    { background: #2e7d32; color: white; }
        .btn-accept:hover { background: #1b5e20; }
        .btn-reject    { background: #fff; color: #c0392b; border: 2px solid #f5c6cb; }
        .btn-reject:hover { background: #fde8e8; }
        .btn-review    { background: #f5a623; color: white; }
        .btn-review:hover { background: #d4891a; }

        .completed-badge { color: #2e7d32; font-weight: bold; font-size: 0.88rem; }

        .back-link {
            display: inline-block;
            margin-top: 22px;
            color: #AA336A;
            font-weight: bold;
            text-decoration: none;
        }

        .empty {
            background: #fff7fa;
            border: 1px solid #f3d6df;
            border-radius: 12px;
            padding: 18px;
            color: #777;
            margin-top: 20px;
        }
    </style>
</head>

<body>
<div class="container">
    <h1>My Exchanges</h1>
    <p class="subtitle">Track pending, accepted, in progress, cancelled, and completed exchanges.</p>

    <table>
        <tr>
            <th>Request ID</th>
            <th>Requested Skill</th>
            <th>Offered Skill</th>
            <th>Other Student</th>
            <th>Status</th>
            <th>Action</th>
        </tr>

        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            boolean hasRows = false;

            try {
                conn = com.skillswap.DatabaseUtil.getConnection();

                String sql =
                    "SELECT er.Request_ID, er.Sender_ID, er.Receiver_ID, " +
                    "rs.Title AS Requested_Skill, " +
                    "os.Title AS Offered_Skill, " +
                    "CASE WHEN er.Sender_ID = ? THEN u2.Full_Name ELSE u1.Full_Name END AS Other_Student, " +
                    "er.Status " +
                    "FROM Exchange_Requests er " +
                    "JOIN Skills rs ON er.Requested_Skill_ID = rs.Skill_ID " +
                    "JOIN Skills os ON er.Offered_Skill_ID = os.Skill_ID " +
                    "JOIN Users u1 ON er.Sender_ID = u1.User_ID " +
                    "JOIN Users u2 ON er.Receiver_ID = u2.User_ID " +
                    "WHERE er.Sender_ID = ? OR er.Receiver_ID = ? " +
                    "ORDER BY er.Request_ID DESC";

                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, userId);
                stmt.setInt(2, userId);
                stmt.setInt(3, userId);

                rs = stmt.executeQuery();

                while (rs.next()) {
                    hasRows = true;
                    int requestId    = rs.getInt("Request_ID");
                    int senderId     = rs.getInt("Sender_ID");
                    int receiverId   = rs.getInt("Receiver_ID");
                    String requestedSkill = rs.getString("Requested_Skill");
                    String offeredSkill   = rs.getString("Offered_Skill");
                    String otherStudent   = rs.getString("Other_Student");
                    String status         = rs.getString("Status");
                    boolean isReceiver    = (receiverId == userId);
                    boolean isParticipant = (senderId == userId || receiverId == userId);
        %>

        <tr>
            <td><%= requestId %></td>
            <td><%= requestedSkill %></td>
            <td><%= offeredSkill %></td>
            <td><%= otherStudent %></td>
            <td><span class="status-badge"><%= status %></span></td>
            <td>
                <%-- Accept / Reject: only receiver sees this for Pending requests --%>
                <% if ("Pending".equalsIgnoreCase(status) && isReceiver) { %>
                    <form action="<%= request.getContextPath() %>/respondExchange" method="post" style="display:inline">
                        <input type="hidden" name="requestId" value="<%= requestId %>">
                        <input type="hidden" name="action"    value="accept">
                        <button class="action-btn btn-accept" type="submit">Accept</button>
                    </form>
                    <form action="<%= request.getContextPath() %>/respondExchange" method="post" style="display:inline">
                        <input type="hidden" name="requestId" value="<%= requestId %>">
                        <input type="hidden" name="action"    value="reject">
                        <button class="action-btn btn-reject" type="submit">Reject</button>
                    </form>

                <%-- Mark Completed: either participant on Accepted / In Progress --%>
                <% } else if (("Accepted".equalsIgnoreCase(status) || "In Progress".equalsIgnoreCase(status)) && isParticipant) { %>
                    <form action="<%= request.getContextPath() %>/completeExchange" method="post" style="display:inline">
                        <input type="hidden" name="requestId" value="<%= requestId %>">
                        <button class="action-btn btn-complete" type="submit">Mark Completed</button>
                    </form>

                <%-- Leave Review: either participant on Completed --%>
                <% } else if ("Completed".equalsIgnoreCase(status) && isParticipant) { %>
                    <a class="action-btn btn-review"
                       href="<%= request.getContextPath() %>/leaveReview?requestId=<%= requestId %>">
                        Leave Review
                    </a>
                    <span class="completed-badge">&#10003; Done</span>

                <% } else { %>
                    <span style="color:#bbb; font-size:0.82rem;">—</span>
                <% } %>
            </td>
        </tr>

        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='6'>Error loading exchanges: " + e.getMessage() + "</td></tr>");
            } finally {
                com.skillswap.DatabaseUtil.close(conn, stmt, rs);
            }
        %>
    </table>

    <% if (!hasRows) { %>
        <div class="empty">You do not have any exchange requests yet.</div>
    <% } %>

    <a class="back-link" href="<%= request.getContextPath() %>/src/dashboard.jsp">Back to Dashboard</a>
</div>
</body>
</html>