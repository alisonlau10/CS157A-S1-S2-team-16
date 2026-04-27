<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Account - SkillSwap Campus</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            min-height: 100vh;
            padding: 20px;
        }

        .navbar {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 15px 25px;
            background: #F8C8DC;
            border-radius: 20px;
            margin-bottom: 40px;
        }
        .navbar .brand {
            font-family: cursive;
            font-size: 1.4rem;
            color: #7a2d3b;
            font-weight: 700;
            margin-right: auto;
        }
        .navbar a {
            text-decoration: none;
            color: #2c7be5;
            font-weight: bold;
            padding: 6px 12px;
            border-radius: 8px;
            transition: background 0.2s;
        }
        .navbar a:hover { background: rgba(255,255,255,0.6); }
        .navbar .btn-logout {
            background: #AA336A;
            color: white;
            padding: 7px 16px;
            border-radius: 10px;
            font-weight: bold;
            text-decoration: none;
            transition: background 0.2s;
        }
        .navbar .btn-logout:hover { background: #8e2a58; }

        .page-wrapper {
            display: flex;
            justify-content: center;
            padding: 20px;
        }

        .confirm-card {
            background: #fff;
            border: 2px solid #f5c6cb;
            border-radius: 20px;
            padding: 40px 45px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 4px 20px rgba(170,51,106,0.10);
            text-align: center;
        }

        .danger-icon { font-size: 3.5rem; margin-bottom: 16px; }

        .confirm-title {
            font-family: cursive;
            font-size: 2rem;
            color: #c0392b;
            margin-bottom: 12px;
        }

        .confirm-text {
            color: #555;
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 24px;
        }

        .warning-box {
            background: #fde8e8;
            border: 1px solid #f5c6cb;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 28px;
            text-align: left;
        }
        .warning-box ul {
            list-style: disc;
            padding-left: 20px;
            color: #c0392b;
            font-size: 0.9rem;
            line-height: 1.8;
        }

        .btn-row {
            display: flex;
            gap: 14px;
            justify-content: center;
        }

        .btn-cancel {
            padding: 12px 28px;
            background: #f0f0f0;
            color: #555;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-cancel:hover { background: #ddd; }

        .btn-delete {
            padding: 12px 28px;
            background: #c0392b;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
        }
        .btn-delete:hover  { background: #a93226; }
        .btn-delete:active { transform: scale(0.98); }
    </style>
</head>
<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="listOfSkills.jsp">Browse Skills</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<div class="page-wrapper">
    <div class="confirm-card">
        <div class="danger-icon">&#9888;&#65039;</div>
        <h2 class="confirm-title">Delete Account</h2>
        <p class="confirm-text">
            Hi <strong><%= userName %></strong>, you are about to permanently delete your SkillSwap account.
            This action <strong>cannot be undone</strong>.
        </p>

        <div class="warning-box">
            <ul>
                <li>All profile information will be removed</li>
                <li>All skills you listed will be deleted</li>
                <li>All pending exchange requests will be cancelled</li>
                <li>Your active session will be invalidated</li>
            </ul>
        </div>

        <div class="btn-row">
            <a href="dashboard.jsp" class="btn-cancel">Cancel</a>
            <form action="<%= request.getContextPath() %>/deleteAccount" method="post" style="display:inline;">
                <button type="submit" class="btn-delete">Yes, Delete My Account</button>
            </form>
        </div>
    </div>
</div>

</body>
</html>
