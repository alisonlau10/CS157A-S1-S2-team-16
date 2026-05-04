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
    <title>My Skills</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            padding: 20px;
        }

        .container {
            max-width: 1000px;
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

        .top-links {
            display: flex;
            gap: 12px;
            margin-bottom: 24px;
        }

        .btn {
            padding: 10px 16px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: bold;
            font-size: 0.9rem;
        }

        .btn-primary {
            background: #AA336A;
            color: white;
        }

        .btn-secondary {
            background: #f7e4ec;
            color: #7a2d3b;
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

        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
            background: #f7e4ec;
            color: #7a2d3b;
        }

        .actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .edit-link {
            padding: 7px 12px;
            border-radius: 8px;
            background: #AA336A;
            color: white;
            text-decoration: none;
            font-size: 0.85rem;
            font-weight: bold;
        }

        .delete-btn {
            padding: 7px 12px;
            border-radius: 8px;
            border: 1px solid #f5c6cb;
            background: #fff;
            color: #c0392b;
            font-size: 0.85rem;
            font-weight: bold;
            cursor: pointer;
        }

        .delete-btn:hover {
            background: #fde8e8;
        }

        .back-link {
            display: inline-block;
            margin-top: 22px;
            color: #AA336A;
            font-weight: bold;
            text-decoration: none;
        }
    </style>
</head>

<body>
<div class="container">
    <h1>My Skills</h1>
    <p class="subtitle">View, edit, or delete the skills you currently offer.</p>

    <div class="top-links">
        <a class="btn btn-secondary" href="dashboard.jsp">Dashboard</a>
        <a class="btn btn-primary" href="addSkill.jsp">Add New Skill</a>
    </div>

    <table>
        <tr>
            <th>Skill ID</th>
            <th>Title</th>
            <th>Description</th>
            <th>Experience Level</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>

        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                conn = com.skillswap.DatabaseUtil.getConnection();
                stmt = conn.prepareStatement(
                    "SELECT Skill_ID, Title, Description, Experience_Level, Status " +
                    "FROM Skills WHERE User_ID = ?"
                );
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();

                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("Skill_ID") %></td>
            <td><%= rs.getString("Title") %></td>
            <td><%= rs.getString("Description") %></td>
            <td><%= rs.getString("Experience_Level") %></td>
            <td><span class="status"><%= rs.getString("Status") %></span></td>
            <td>
                <div class="actions">
                    <a class="edit-link" href="editSkill.jsp?skillId=<%= rs.getInt("Skill_ID") %>">Edit</a>

                    <form action="<%= request.getContextPath() %>/deleteSkill" method="post" style="display:inline;">
                        <input type="hidden" name="skillId" value="<%= rs.getInt("Skill_ID") %>">
                        <button class="delete-btn" type="submit">Delete</button>
                    </form>
                </div>
            </td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.println("Error loading skills: " + e.getMessage());
            } finally {
                com.skillswap.DatabaseUtil.close(conn, stmt, rs);
            }
        %>
    </table>

    <a class="back-link" href="dashboard.jsp">Back to Dashboard</a>
</div>
</body>
</html>