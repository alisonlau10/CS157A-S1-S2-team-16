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
    if (results    == null) results    = new ArrayList<>();
    if (categories == null) categories = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Skills - SkillSwap Campus</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #FFF5EE; min-height: 100vh; padding: 20px; }

        .navbar {
            display: flex; align-items: center; gap: 16px;
            padding: 15px 25px; background: #F8C8DC;
            border-radius: 20px; margin-bottom: 30px;
        }
        .navbar .brand { font-family: cursive; font-size: 1.4rem; color: #7a2d3b; font-weight: 700; margin-right: auto; }
        .navbar a { text-decoration: none; color: #2c7be5; font-weight: bold; padding: 6px 12px; border-radius: 8px; }
        .navbar a:hover { background: rgba(255,255,255,0.6); }
        .navbar .btn-logout { background: #AA336A; color: white; padding: 7px 16px; border-radius: 10px; font-weight: bold; text-decoration: none; }
        .navbar .btn-logout:hover { background: #8e2a58; }

        .container { max-width: 1100px; margin: 0 auto; }

        .search-box {
            background: white; border: 2px solid #F3CFC6;
            border-radius: 18px; padding: 28px 30px;
            box-shadow: 0 2px 10px rgba(170,51,106,0.08);
            margin-bottom: 28px;
        }
        .search-box h1 { font-family: cursive; color: #7a2d3b; margin-bottom: 6px; }
        .search-box p  { color: #888; margin-bottom: 20px; font-size: 0.95rem; }

        .search-row { display: flex; gap: 12px; flex-wrap: wrap; }
        .search-row input[type="text"] {
            flex: 2; min-width: 200px; padding: 11px 16px;
            border: 2px solid #F3CFC6; border-radius: 12px;
            font-size: 1rem; outline: none;
        }
        .search-row input[type="text"]:focus { border-color: #AA336A; }
        .search-row select {
            flex: 1; min-width: 150px; padding: 11px 14px;
            border: 2px solid #F3CFC6; border-radius: 12px;
            font-size: 1rem; background: white; outline: none;
        }
        .search-row select:focus { border-color: #AA336A; }
        .search-row button {
            padding: 11px 28px; background: #AA336A; color: white;
            border: none; border-radius: 12px; font-size: 1rem;
            font-weight: bold; cursor: pointer;
        }
        .search-row button:hover { background: #8e2a58; }

        .results-box {
            background: white; border: 2px solid #F3CFC6;
            border-radius: 18px; padding: 28px 30px;
            box-shadow: 0 2px 10px rgba(170,51,106,0.08);
        }
        .results-title { font-family: cursive; color: #7a2d3b; font-size: 1.3rem; margin-bottom: 18px; }

        table { width: 100%; border-collapse: collapse; }
        th { background: #F8C8DC; color: #7a2d3b; padding: 13px 14px; text-align: left; }
        th:first-child { border-radius: 12px 0 0 0; }
        th:last-child  { border-radius: 0 12px 0 0; }
        td { padding: 13px 14px; border-bottom: 1px solid #f3d6df; font-size: 0.93rem; vertical-align: middle; }
        tr:hover td { background: #fff7fa; }

        .badge {
            display: inline-block; padding: 4px 10px;
            border-radius: 20px; font-size: 0.8rem; font-weight: bold;
            background: #f7e4ec; color: #7a2d3b;
        }
        .cat-badge {
            display: inline-block; padding: 4px 10px;
            border-radius: 20px; font-size: 0.8rem;
            background: #e8f0fe; color: #1a56db;
        }

        .btn-request {
            display: inline-block; padding: 7px 14px;
            background: #AA336A; color: white; border-radius: 10px;
            font-weight: bold; font-size: 0.85rem; text-decoration: none;
        }
        .btn-request:hover { background: #8e2a58; }

        .empty {
            background: #fff7fa; border: 1px solid #f3d6df;
            border-radius: 12px; padding: 24px; color: #888;
            text-align: center; margin-top: 10px;
        }
    </style>
</head>
<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="<%= request.getContextPath() %>/search">Browse Skills</a>
    <a href="mySkills.jsp">My Skills</a>
    <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
    <a href="messages.jsp">Messages</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<div class="container">
    <!-- Search Form -->
    <div class="search-box">
        <h1>&#128269; Browse Skills</h1>
        <p>Search by keyword or filter by category to find skills offered by other students.</p>
        <form action="<%= request.getContextPath() %>/search" method="get">
            <div class="search-row">
                <input type="text" name="keyword" placeholder="Search by skill name or description..."
                       value="<%= keyword != null ? keyword : "" %>">
                <select name="categoryId">
                    <option value="0" <%= "0".equals(categoryId) ? "selected" : "" %>>All Categories</option>
                    <% for (String[] cat : categories) { %>
                        <option value="<%= cat[0] %>" <%= cat[0].equals(categoryId) ? "selected" : "" %>><%= cat[1] %></option>
                    <% } %>
                </select>
                <button type="submit">Search</button>
            </div>
        </form>
    </div>

    <!-- Results -->
    <div class="results-box">
        <div class="results-title">
            <% if (!results.isEmpty()) { %>
                <%= results.size() %> skill<%= results.size() != 1 ? "s" : "" %> found
            <% } else { %>
                Results
            <% } %>
        </div>

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
                // row: Skill_ID, Title, Description, Experience_Level, Category_Name, Full_Name, User_ID
                int    skillId   = Integer.parseInt(row[0]);
                String title     = row[1];
                String desc      = row[2] != null ? row[2] : "";
                String level     = row[3];
                String catName   = row[4];
                String ownerName = row[5];
                int    ownerId   = Integer.parseInt(row[6]);
                int    myId      = (Integer) session.getAttribute("userId");
            %>
            <tr>
                <td>
                    <strong><%= title %></strong>
                    <% if (!desc.isEmpty()) { %>
                        <br><span style="color:#888; font-size:0.85rem;"><%= desc.length() > 80 ? desc.substring(0, 80) + "…" : desc %></span>
                    <% } %>
                </td>
                <td><span class="cat-badge"><%= catName %></span></td>
                <td><span class="badge"><%= level %></span></td>
                <td><%= ownerName %></td>
                <td>
                    <% if (ownerId != myId) { %>
                        <a class="btn-request"
                           href="<%= request.getContextPath() %>/sendExchangeRequest?skillId=<%= skillId %>">
                            Request Exchange
                        </a>
                    <% } else { %>
                        <span style="color:#aaa; font-size:0.85rem;">Your skill</span>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </table>
        <% } else { %>
            <div class="empty">
                No skills found. Try a different keyword or category.
            </div>
        <% } %>
    </div>
</div>

</body>
</html>
