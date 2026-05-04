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

        .complete-btn {
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 10px;
            padding: 8px 13px;
            font-weight: bold;
            cursor: pointer;
        }

        .complete-btn:hover {
            background: #8e2a58;
        }

        .completed-badge {
            color: #2e7d32;
            font-weight: bold;
        }

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
                    "SELECT er.Request_ID, " +
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
                    int requestId = rs.getInt("Request_ID");
                    String requestedSkill = rs.getString("Requested_Skill");
                    String offeredSkill = rs.getString("Offered_Skill");
                    String otherStudent = rs.getString("Other_Student");
                    String status = rs.getString("Status");
        %>

        <tr>
            <td><%= requestId %></td>
            <td><%= requestedSkill %></td>
            <td><%= offeredSkill %></td>
            <td><%= otherStudent %></td>
            <td><span class="status-badge"><%= status %></span></td>
            <td>
                <% if (!"Completed".equalsIgnoreCase(status)) { %>
                    <form action="<%= request.getContextPath() %>/completeExchange" method="post">
                        <input type="hidden" name="requestId" value="<%= requestId %>">
                        <button class="complete-btn" type="submit">Mark Completed</button>
                    </form>
                <% } else { %>
                    <span class="completed-badge">Completed</span>
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