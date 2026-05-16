<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String fullName = (String) request.getAttribute("fullName");
    String major = (String) request.getAttribute("major");
    String bio = (String) request.getAttribute("bio");
    String availability = (String) request.getAttribute("availability");
    String skillTitle = (String) request.getAttribute("skillTitle");
    String skillDescription = (String) request.getAttribute("skillDescription");
    String experienceLevel = (String) request.getAttribute("experienceLevel");
    String viewedUserId = String.valueOf(request.getAttribute("viewedUserId"));
    String skillId = String.valueOf(request.getAttribute("skillId"));
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Skill Profile</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            padding: 20px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
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

        .navbar .btn-logout {
            background: #AA336A;
            color: white;
            padding: 7px 16px;
            border-radius: 10px;
            margin-left: auto;
        }

        .brand {
            font-family: cursive;
            font-size: 1.4rem;
            color: #7a2d3b;
            font-weight: bold;
        }

        .profile-card {
            background: white;
            border: 2px solid #F3CFC6;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(170,51,106,0.06);
        }

        h2 {
            color: #7a2d3b;
            font-family: cursive;
            margin-bottom: 20px;
        }

        .row {
            margin-bottom: 14px;
        }

        .label {
            font-weight: bold;
            color: #555;
        }

        .btn {
            padding: 10px 18px;
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
        }

        .btn:hover {
            background: #8e2a58;
        }

        .btn-secondary {
            margin-top: 20px;
            display: inline-block;
        }
    </style>
</head>

<body>

<div class="container">

    <div class="navbar">
        <span class="brand">SkillSwap Campus</span>
        <a href="SkillSwap.jsp">Home</a>
        <a href="dashboard.jsp">Dashboard</a>
        <a href="<%= request.getContextPath() %>/search">Browse Skills</a>
        <a href="mySkills.jsp">My Skills</a>
        <a href="addSkill.jsp">Add Skill</a>
        <a href="<%= request.getContextPath() %>/src/messages.jsp">Messages</a>
        <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
    </div>

    <div class="profile-card">
        <h2>Student Skill Profile</h2>

        <!-- MESSAGE BUTTON -->
        <div style="margin-bottom: 20px;">
            <a href="<%= request.getContextPath() %>/src/messages.jsp?partnerId=<%= viewedUserId %>" class="btn">
                💬 Message
            </a>

            <a href="<%= request.getContextPath() %>/sendExchangeRequest?skillId=<%= skillId %>" class="btn" style="margin-left:10px;">
                🔁 Request Exchange
            </a>
        </div>

        <div class="row"><span class="label">Name:</span> <%= fullName %></div>
        <div class="row"><span class="label">Major:</span> <%= major %></div>
        <div class="row"><span class="label">Bio:</span> <%= bio %></div>
        <div class="row"><span class="label">Availability:</span> <%= availability %></div>
        <div class="row"><span class="label">Skill Title:</span> <%= skillTitle %></div>
        <div class="row"><span class="label">Skill Description:</span> <%= skillDescription %></div>
        <div class="row"><span class="label">Experience Level:</span> <%= experienceLevel %></div>

        <!-- BACK BUTTON -->
        <a href="<%= request.getContextPath() %>/search" class="btn btn-secondary">
            Back to Skills
        </a>
    </div>

</div>

</body>
</html>