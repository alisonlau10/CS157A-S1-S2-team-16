<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int skillId = Integer.parseInt(request.getParameter("skillId"));

    String title = "";
    String description = "";
    String experienceLevel = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = com.skillswap.DatabaseUtil.getConnection();
        stmt = conn.prepareStatement(
            "SELECT Title, Description, Experience_Level FROM Skills WHERE Skill_ID = ?"
        );
        stmt.setInt(1, skillId);
        rs = stmt.executeQuery();

        if (rs.next()) {
            title = rs.getString("Title");
            description = rs.getString("Description");
            experienceLevel = rs.getString("Experience_Level");
        }
    } finally {
        com.skillswap.DatabaseUtil.close(conn, stmt, rs);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Skill</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            padding: 20px;
        }

        .container {
            max-width: 650px;
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

        p {
            color: #777;
            margin-bottom: 25px;
        }

        label {
            font-weight: bold;
            color: #555;
            display: block;
            margin-bottom: 6px;
        }

        input, textarea, select {
            width: 100%;
            padding: 12px;
            margin-bottom: 18px;
            border: 1px solid #ddd;
            border-radius: 10px;
            font-size: 0.95rem;
            background: #fffafa;
            box-sizing: border-box;
        }

        textarea {
            min-height: 90px;
            resize: vertical;
        }

        button {
            width: 100%;
            padding: 13px;
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: bold;
            cursor: pointer;
            font-size: 1rem;
        }

        button:hover {
            background: #8e2a58;
        }

        .back-link {
            display: inline-block;
            margin-top: 18px;
            color: #AA336A;
            font-weight: bold;
            text-decoration: none;
        }

        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>
    <div class="container">
        <h1>Edit Skill</h1>
        <p>Update the details for a skill you currently offer.</p>

        <form action="<%= request.getContextPath() %>/updateSkill" method="post">
            <input type="hidden" name="skillId" value="<%= skillId %>">

            <label>Skill Title</label>
            <input type="text" name="title" value="<%= title %>" required>

            <label>Description</label>
            <textarea name="description" required><%= description %></textarea>

            <label>Experience Level</label>
            <select name="experienceLevel" required>
                <option value="Beginner" <%= "Beginner".equals(experienceLevel) ? "selected" : "" %>>Beginner</option>
                <option value="Intermediate" <%= "Intermediate".equals(experienceLevel) ? "selected" : "" %>>Intermediate</option>
                <option value="Advanced" <%= "Advanced".equals(experienceLevel) ? "selected" : "" %>>Advanced</option>
            </select>

            <button type="submit">Save Changes</button>
        </form>

        <a class="back-link" href="mySkills.jsp">Back to My Skills</a>
    </div>
</body>
</html>