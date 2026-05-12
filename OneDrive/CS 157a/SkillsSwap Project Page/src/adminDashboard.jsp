<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String role = (String) session.getAttribute("role");
    if (role == null || !role.equalsIgnoreCase("Admin")) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    Connection conn = com.skillswap.DatabaseUtil.getConnection();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <style>
        body { font-family: Arial; background:#FFF5EE; padding:20px; }
        .box { background:white; border:2px solid #F3CFC6; border-radius:16px; padding:25px; margin-bottom:25px; }
        h1, h2 { color:#7a2d3b; font-family:cursive; }
        table { width:100%; border-collapse:collapse; margin-top:15px; }
        th { background:#F8C8DC; padding:10px; text-align:left; }
        td { padding:10px; border-bottom:1px solid #eee; }
        button { background:#AA336A; color:white; border:none; border-radius:8px; padding:7px 12px; cursor:pointer; }
        button:hover { background:#8e2a58; }
        a { color:#2c7be5; font-weight:bold; text-decoration:none; }
    </style>
</head>
<body>

<h1>Admin Dashboard</h1>
<p><a href="dashboard.jsp">Back to Dashboard</a></p>

<div class="box">
    <h2>All Users</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Major</th>
            <th>Role</th>
            <th>Created</th>
            <th>Action</th>
        </tr>

        <%
            PreparedStatement userStmt = conn.prepareStatement(
                "SELECT User_ID, Full_Name, University_Email, Major, Role, Date_Created FROM Users ORDER BY Date_Created DESC"
            );
            ResultSet users = userStmt.executeQuery();

            while (users.next()) {
        %>
        <tr>
            <td><%= users.getInt("User_ID") %></td>
            <td><%= users.getString("Full_Name") %></td>
            <td><%= users.getString("University_Email") %></td>
            <td><%= users.getString("Major") %></td>
            <td><%= users.getString("Role") %></td>
            <td><%= users.getTimestamp("Date_Created") %></td>
            <td>
                <% if (!"Admin".equalsIgnoreCase(users.getString("Role"))) { %>
                <form action="<%= request.getContextPath() %>/deleteUser" method="post"
                      onsubmit="return confirm('Delete this user permanently?');">
                    <input type="hidden" name="userId" value="<%= users.getInt("User_ID") %>">
                    <button type="submit">Delete</button>
                </form>
                <% } else { %>
                    —
                <% } %>
            </td>
        </tr>
        <%
            }
            users.close();
            userStmt.close();
        %>
    </table>
</div>

<div class="box">
    <h2>Exchange Activity</h2>
    <table>
        <tr>
            <th>Request ID</th>
            <th>Status</th>
            <th>Sender</th>
            <th>Receiver</th>
            <th>Requested Skill</th>
            <th>Offered Skill</th>
            <th>Created</th>
        </tr>

        <%
            PreparedStatement exStmt = conn.prepareStatement(
                "SELECT er.Request_ID, er.Status, er.Created_At, " +
                "su.Full_Name AS SenderName, ru.Full_Name AS ReceiverName, " +
                "rs.Title AS RequestedSkill, os.Title AS OfferedSkill " +
                "FROM Exchange_Requests er " +
                "JOIN Users su ON er.Sender_ID = su.User_ID " +
                "JOIN Users ru ON er.Receiver_ID = ru.User_ID " +
                "JOIN Skills rs ON er.Requested_Skill_ID = rs.Skill_ID " +
                "JOIN Skills os ON er.Offered_Skill_ID = os.Skill_ID " +
                "ORDER BY er.Created_At DESC"
            );
            ResultSet exchanges = exStmt.executeQuery();

            while (exchanges.next()) {
        %>
        <tr>
            <td><%= exchanges.getInt("Request_ID") %></td>
            <td><%= exchanges.getString("Status") %></td>
            <td><%= exchanges.getString("SenderName") %></td>
            <td><%= exchanges.getString("ReceiverName") %></td>
            <td><%= exchanges.getString("RequestedSkill") %></td>
            <td><%= exchanges.getString("OfferedSkill") %></td>
            <td><%= exchanges.getTimestamp("Created_At") %></td>
        </tr>
        <%
            }
            exchanges.close();
            exStmt.close();
        %>
    </table>
</div>

<div class="box">
    <h2>Moderate Reviews</h2>
    <table>
        <tr>
            <th>Review ID</th>
            <th>Rating</th>
            <th>Comment</th>
            <th>Reviewer</th>
            <th>Reviewee</th>
            <th>Date</th>
            <th>Action</th>
        </tr>

        <%
            PreparedStatement reviewStmt = conn.prepareStatement(
                "SELECT r.Review_ID, r.Rating, r.Comment, r.Date_Posted, " +
                "reviewer.Full_Name AS ReviewerName, reviewee.Full_Name AS RevieweeName " +
                "FROM Reviews r " +
                "JOIN Users reviewer ON r.Reviewer_ID = reviewer.User_ID " +
                "JOIN Users reviewee ON r.Reviewee_ID = reviewee.User_ID " +
                "ORDER BY r.Date_Posted DESC"
            );
            ResultSet reviews = reviewStmt.executeQuery();

            while (reviews.next()) {
        %>
        <tr>
            <td><%= reviews.getInt("Review_ID") %></td>
            <td><%= reviews.getInt("Rating") %></td>
            <td><%= reviews.getString("Comment") %></td>
            <td><%= reviews.getString("ReviewerName") %></td>
            <td><%= reviews.getString("RevieweeName") %></td>
            <td><%= reviews.getTimestamp("Date_Posted") %></td>
            <td>
                <form action="<%= request.getContextPath() %>/deleteReview" method="post"
                      onsubmit="return confirm('Delete this review?');">
                    <input type="hidden" name="reviewId" value="<%= reviews.getInt("Review_ID") %>">
                    <button type="submit">Remove</button>
                </form>
            </td>
        </tr>
        <%
            }
            reviews.close();
            reviewStmt.close();
        %>
    </table>
</div>

<div class="box">
    <h2>Activity Log</h2>
    <table>
        <tr>
            <th>Log ID</th>
            <th>User</th>
            <th>Action</th>
            <th>Time</th>
        </tr>

        <%
            PreparedStatement logStmt = conn.prepareStatement(
                "SELECT a.Log_ID, a.Action_Type, a.Timestamp, u.Full_Name " +
                "FROM Activity_Log a JOIN Users u ON a.User_ID = u.User_ID " +
                "ORDER BY a.Timestamp DESC LIMIT 50"
            );
            ResultSet logs = logStmt.executeQuery();

            while (logs.next()) {
        %>
        <tr>
            <td><%= logs.getInt("Log_ID") %></td>
            <td><%= logs.getString("Full_Name") %></td>
            <td><%= logs.getString("Action_Type") %></td>
            <td><%= logs.getTimestamp("Timestamp") %></td>
        </tr>
        <%
            }
            logs.close();
            logStmt.close();
            conn.close();
        %>
    </table>
</div>

</body>
</html>