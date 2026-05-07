<%@ page import="java.util.*, java.time.LocalDate" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String requestedSkillId    = (String) request.getAttribute("requestedSkillId");
    String requestedSkillTitle = (String) request.getAttribute("requestedSkillTitle");
    String requestedSkillDesc  = (String) request.getAttribute("requestedSkillDesc");
    String requestedSkillLevel = (String) request.getAttribute("requestedSkillLevel");
    String skillOwnerName      = (String) request.getAttribute("skillOwnerName");
    String receiverId          = (String) request.getAttribute("receiverId");
    List<String[]> mySkills    = (List<String[]>) request.getAttribute("mySkills");
    String error               = (String) request.getAttribute("error");
    if (error == null && "past".equals(request.getParameter("error"))) {
        error = "Please choose today or a future date.";
    }
    if (mySkills == null) mySkills = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send Exchange Request - SkillSwap Campus</title>
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

        .container { max-width: 700px; margin: 0 auto; }

        .card {
            background: white; border: 2px solid #F3CFC6;
            border-radius: 18px; padding: 30px 35px;
            box-shadow: 0 2px 10px rgba(170,51,106,0.08);
            margin-bottom: 22px;
        }
        h1 { font-family: cursive; color: #7a2d3b; margin-bottom: 6px; }
        .subtitle { color: #888; margin-bottom: 24px; font-size: 0.95rem; }

        .skill-info {
            background: #fff7fa; border: 1px solid #F3CFC6;
            border-radius: 12px; padding: 18px 20px; margin-bottom: 24px;
        }
        .skill-info .skill-title { font-weight: bold; font-size: 1.1rem; color: #7a2d3b; }
        .skill-info .skill-meta  { color: #888; font-size: 0.88rem; margin-top: 4px; }
        .skill-info .skill-desc  { color: #555; font-size: 0.93rem; margin-top: 8px; }

        label { display: block; font-weight: bold; color: #555; margin-bottom: 6px; font-size: 0.93rem; }
        select, input[type="date"], input[type="time"] {
            width: 100%; padding: 11px 14px;
            border: 2px solid #F3CFC6; border-radius: 12px;
            font-size: 1rem; background: white; outline: none;
            margin-bottom: 18px;
        }
        select:focus, input:focus { border-color: #AA336A; }

        .row-2 { display: flex; gap: 16px; }
        .row-2 > div { flex: 1; }

        .btn-submit {
            width: 100%; padding: 13px; background: #AA336A; color: white;
            border: none; border-radius: 12px; font-size: 1rem;
            font-weight: bold; cursor: pointer; margin-top: 4px;
        }
        .btn-submit:hover { background: #8e2a58; }

        .btn-back {
            display: inline-block; margin-top: 14px;
            color: #AA336A; font-weight: bold; text-decoration: none;
        }
        .btn-back:hover { text-decoration: underline; }

        .alert-error {
            background: #fde8e8; border: 1px solid #f5c6cb;
            color: #c0392b; border-radius: 10px; padding: 12px 16px;
            margin-bottom: 18px; font-size: 0.93rem;
        }
        .no-skills {
            background: #fff7fa; border: 1px solid #F3CFC6;
            border-radius: 10px; padding: 14px 16px; color: #888;
            font-size: 0.93rem; margin-bottom: 18px;
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
    <div class="card">
        <h1>&#128257; Send Exchange Request</h1>
        <p class="subtitle">Propose a skill swap with <%= skillOwnerName != null ? skillOwnerName : "this student" %>.</p>

        <% if (error != null) { %>
            <div class="alert-error"><%= error %></div>
        <% } %>

        <!-- Skill being requested -->
        <p style="font-weight:bold; color:#555; margin-bottom:8px;">You are requesting:</p>
        <div class="skill-info">
            <div class="skill-title"><%= requestedSkillTitle %></div>
            <div class="skill-meta">Level: <%= requestedSkillLevel %> &nbsp;|&nbsp; Offered by: <%= skillOwnerName %></div>
            <% if (requestedSkillDesc != null && !requestedSkillDesc.isEmpty()) { %>
                <div class="skill-desc"><%= requestedSkillDesc %></div>
            <% } %>
        </div>

        <% if (mySkills.isEmpty()) { %>
            <div class="no-skills">
                You have no active skills to offer in return.
                <a href="addSkill.jsp" style="color:#AA336A; font-weight:bold;">Add a skill first</a> before sending a request.
            </div>
        <% } else { %>
        <form action="<%= request.getContextPath() %>/sendExchangeRequest" method="post">
            <input type="hidden" name="requestedSkillId" value="<%= requestedSkillId %>">
            <input type="hidden" name="receiverId"       value="<%= receiverId %>">

            <label for="offeredSkillId">Skill you offer in return *</label>
            <select id="offeredSkillId" name="offeredSkillId" required>
                <option value="">-- Select one of your skills --</option>
                <% for (String[] sk : mySkills) { %>
                    <option value="<%= sk[0] %>"><%= sk[1] %></option>
                <% } %>
            </select>

            <div class="row-2">
                <div>
                    <label for="preferredDate">Preferred Date</label>
                    <input type="date" id="preferredDate" name="preferredDate"
                           min="<%= LocalDate.now().toString() %>">
                </div>
                <div>
                    <label for="preferredTime">Preferred Time</label>
                    <input type="time" id="preferredTime" name="preferredTime">
                </div>
            </div>

            <button class="btn-submit" type="submit">Send Request</button>
        </form>
        <% } %>

        <a class="btn-back" href="javascript:history.back()">&#8592; Go Back</a>
    </div>
</div>

</body>
</html>
