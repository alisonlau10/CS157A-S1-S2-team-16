<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Load categories for dropdown
    java.util.List<String[]> cats = new java.util.ArrayList<>();
    Connection _conn = null; PreparedStatement _stmt = null; ResultSet _rs = null;
    try {
        _conn  = com.skillswap.DatabaseUtil.getConnection();
        _stmt  = _conn.prepareStatement(
            "SELECT Category_ID, Category_Name FROM Skill_Categories ORDER BY Category_Name");
        _rs    = _stmt.executeQuery();
        while (_rs.next())
            cats.add(new String[]{ _rs.getString("Category_ID"), _rs.getString("Category_Name") });
    } catch (Exception _e) {
    } finally {
        com.skillswap.DatabaseUtil.close(_conn, _stmt, _rs);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Skill</title>

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
        <h1>Add New Skill</h1>
        <p>List a skill you can teach or share with other students.</p>

        <form action="<%= request.getContextPath() %>/addSkill" method="post">
            <label>Skill Title</label>
            <input type="text" name="title" placeholder="e.g. Excel Skills" required>

            <label>Description</label>
            <textarea name="description" placeholder="Describe what you can teach" required></textarea>

            <label>Experience Level</label>
            <select name="experienceLevel" required>
                <option value="">Select Level</option>
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
            </select>

            <label>Category</label>
            <select name="categoryId" required>
                <option value="">-- Select a category --</option>
                <% for (String[] cat : cats) { %>
                    <option value="<%= cat[0] %>"><%= cat[1] %></option>
                <% } %>
            </select>

            <button type="submit">Add Skill</button>
        </form>

        <a class="back-link" href="<%= request.getContextPath() %>/src/dashboard.jsp">Back to Dashboard</a>
    </div>
</body>
</html>