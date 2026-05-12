<%@ page import="java.util.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String[]> results    = (List<String[]>) request.getAttribute("results");
    List<String[]> categories = (List<String[]>) request.getAttribute("categories");

    String keyword    = request.getAttribute("keyword")    != null ? (String) request.getAttribute("keyword")    : "";
    String categoryId = request.getAttribute("categoryId") != null ? (String) request.getAttribute("categoryId") : "0";

    if (results == null) results = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Browse Skills - SkillSwap Campus</title>

    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

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
            max-width: 1100px;
            margin: 0 auto;
        }

        .search-box {
            background: white;
            border: 2px solid #F3CFC6;
            border-radius: 18px;
            padding: 25px;
            margin-bottom: 25px;
        }

        .search-box h1 {
            font-family: cursive;
            color: #7a2d3b;
            margin-bottom: 10px;
        }

        .search-row {
            display: flex;
            gap: 10px;
        }

        input, select {
            padding: 10px;
            border-radius: 10px;
            border: 2px solid #F3CFC6;
        }

        button {
            padding: 10px 20px;
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover { background: #8e2a58; }

        .results-box {
            background: white;
            border: 2px solid #F3CFC6;
            border-radius: 18px;
            padding: 25px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            background: #F8C8DC;
            padding: 10px;
            text-align: left;
        }

        td {
            padding: 10px;
            border-bottom: 1px solid #eee;
        }

        .badge {
            background: #f7e4ec;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }

        .btn-request {
            background: #AA336A;
            color: white;
            padding: 6px 12px;
            border-radius: 8px;
            text-decoration: none;
        }

        .btn-request:hover {
            background: #8e2a58;
        }

        .profile-link {
            color: #AA336A;
            font-weight: bold;
            text-decoration: none;
        }

        .profile-link:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="<%= request.getContextPath() %>/src/dashboard.jsp">Dashboard</a>
    <a href="<%= request.getContextPath() %>/search">Browse Skills</a>
    <a href="<%= request.getContextPath() %>/src/mySkills.jsp">My Skills</a>
    <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
    <a href="<%= request.getContextPath() %>/src/messages.jsp">Messages</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<div class="container">

    <!-- SEARCH -->
    <div class="search-box">
        <h1>🔍 Browse Skills</h1>

        <form action="<%= request.getContextPath() %>/search" method="get">
            <div class="search-row">
                <input type="text" name="keyword" value="<%= keyword %>" placeholder="Search skills...">

                <select name="categoryId">
                    <option value="0">All Categories</option>
                    <% for (String[] cat : categories) { %>
                        <option value="<%= cat[0] %>" <%= cat[0].equals(categoryId) ? "selected" : "" %>>
                            <%= cat[1] %>
                        </option>
                    <% } %>
                </select>

                <button type="submit">Search</button>
            </div>
        </form>
    </div>

    <!-- RESULTS -->
    <div class="results-box">

        <% if (!results.isEmpty()) { %>

        <table>
            <tr>
                <th>Skill</th>
                <th>Category</th>
                <th>Level</th>
                <th>Offered By</th>
                <th>Action</th>
            </tr>

            <% for (String[] row : results) {
                int skillId   = Integer.parseInt(row[0]);
                String title  = row[1];
                String desc   = row[2];
                String level  = row[3];
                String cat    = row[4];
                String owner  = row[5];
                int ownerId   = Integer.parseInt(row[6]);
                int myId      = (Integer) session.getAttribute("userId");
            %>

            <tr>
                <td>
                    <strong><%= title %></strong><br>
                    <span style="color:#888; font-size:0.85rem;">
                        <%= desc %>
                    </span>
                </td>

                <td><span class="badge"><%= cat %></span></td>
                <td><span class="badge"><%= level %></span></td>

                <!-- 🔥 CLICKABLE PROFILE LINK -->
                <td>
                    <a class="profile-link"
                       href="<%= request.getContextPath() %>/viewStudentProfile?userId=<%= ownerId %>">
                        <%= owner %>
                    </a>
                </td>

                <td>
                    <% if (ownerId != myId) { %>
                        <a class="btn-request"
                           href="<%= request.getContextPath() %>/sendExchangeRequest?skillId=<%= skillId %>">
                            Request Exchange
                        </a>
                    <% } else { %>
                        <span style="color:#aaa;">Your skill</span>
                    <% } %>
                </td>
            </tr>

            <% } %>

        </table>

        <% } else { %>

        <p>No skills found.</p>

        <% } %>

    </div>

</div>

</body>
</html>