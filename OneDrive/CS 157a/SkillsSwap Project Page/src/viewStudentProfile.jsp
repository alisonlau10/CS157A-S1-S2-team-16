<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String fullName = (String) request.getAttribute("fullName");
    String major = (String) request.getAttribute("major");
    String bio = (String) request.getAttribute("bio");
    String availability = (String) request.getAttribute("availability");
    String skillTitle = (String) request.getAttribute("skillTitle");
    String skillDescription = (String) request.getAttribute("skillDescription");
    String experienceLevel = (String) request.getAttribute("experienceLevel");
%>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            background: #F8C8DC;
            border-radius: 20px;
            padding: 15px 25px;
            margin-bottom: 30px;
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
            margin-bottom: 15px;
        }

        .row {
            margin-bottom: 14px;
        }

        .label {
            font-weight: bold;
            color: #555;
        }

        .back-link {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            color: white;
            background: #AA336A;
            padding: 10px 16px;
            border-radius: 10px;
        }

        .back-link:hover {
            background: #8e2a58;
        }
    </style>
</head>
<body>
    <h1>VIEW PROFILE PAGE IS WORKING</h1>
    <p>Name value: <%= fullName %></p>
    <p>Skill value: <%= skillTitle %></p>
    
    <div class="container">
        <div class="navbar">
            <span class="brand">SkillSwap Campus</span>
        </div>

        <div class="profile-card">
            <h2>Student Skill Profile</h2>

            <div class="row"><span class="label">Name:</span> <%= fullName %></div>
            <div class="row"><span class="label">Major:</span> <%= major %></div>
            <div class="row"><span class="label">Bio:</span> <%= bio %></div>
            <div class="row"><span class="label">Availability:</span> <%= availability %></div>
            <div class="row"><span class="label">Skill Title:</span> <%= skillTitle %></div>
            <div class="row"><span class="label">Skill Description:</span> <%= skillDescription %></div>
            <div class="row"><span class="label">Experience Level:</span> <%= experienceLevel %></div>

            <a class="back-link" href="listOfSkills.jsp">Back to Skills</a>
        </div>
    </div>
</body>
</html>