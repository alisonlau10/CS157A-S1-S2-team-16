<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Redirect to dashboard if already logged in
    if (session.getAttribute("userId") != null) {
        response.sendRedirect(request.getContextPath() + "/src/dashboard.jsp");
        return;
    }
    String error      = request.getParameter("error");
    String registered = request.getParameter("registered");
    String loggedOut  = request.getParameter("logout");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SkillSwap Campus</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, sans-serif;
            background: #FFF5EE;
            min-height: 100vh;
            padding: 20px;
        }

        /* ── Navbar ── */
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
        .navbar a.active { background: rgba(255,255,255,0.8); color: #AA336A; }

        /* ── Page layout ── */
        .page-wrapper {
            display: flex;
            justify-content: center;
            padding: 10px 20px 40px;
        }
        .form-card {
            background: #fff;
            border: 2px solid #F3CFC6;
            border-radius: 20px;
            padding: 40px 45px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 4px 20px rgba(170,51,106,0.08);
        }
        .form-title {
            font-family: cursive;
            font-size: 2rem;
            color: #7a2d3b;
            text-align: center;
            margin-bottom: 6px;
        }
        .form-subtitle {
            text-align: center;
            color: #888;
            font-size: 0.95rem;
            margin-bottom: 28px;
        }

        /* ── Alerts ── */
        .alert {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 0.95rem;
        }
        .alert-error {
            background: #fde8e8;
            color: #c0392b;
            border: 1px solid #f5c6cb;
        }
        .alert-success {
            background: #eafaf1;
            color: #1e8449;
            border: 1px solid #a9dfbf;
        }
        .alert-info {
            background: #eaf4fb;
            color: #1a5276;
            border: 1px solid #aed6f1;
        }

        /* ── Form fields ── */
        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            font-weight: bold;
            color: #555;
            margin-bottom: 6px;
            font-size: 0.9rem;
        }
        .form-group input {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid #ddd;
            border-radius: 10px;
            font-size: 0.95rem;
            transition: border-color 0.2s;
            background: #FFFAFA;
        }
        .form-group input:focus {
            outline: none;
            border-color: #F8C8DC;
            background: #fff;
        }

        /* ── Submit button ── */
        .btn-submit {
            width: 100%;
            padding: 13px;
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            margin-top: 6px;
            transition: background 0.2s, transform 0.1s;
        }
        .btn-submit:hover  { background: #8e2a58; }
        .btn-submit:active { transform: scale(0.98); }

        /* ── Footer links ── */
        .form-footer {
            text-align: center;
            margin-top: 20px;
            color: #777;
            font-size: 0.9rem;
        }
        .form-footer a { color: #2c7be5; text-decoration: none; font-weight: bold; }
        .form-footer a:hover { text-decoration: underline; }
    </style>
</head>
<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="SkillSwap.jsp">Home</a>
    <a href="login.jsp" class="active">Login</a>
    <a href="register.jsp">Register</a>
    <a href="listOfSkills.jsp">Browse Skills</a>
</nav>

<div class="page-wrapper">
    <div class="form-card">

        <h2 class="form-title">Welcome Back</h2>
        <p class="form-subtitle">Log in to your SkillSwap account</p>

        <%-- Status messages --%>
        <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } else if ("true".equals(registered)) { %>
            <div class="alert alert-success">
                Account created successfully! Please log in below.
            </div>
        <% } else if ("true".equals(loggedOut)) { %>
            <div class="alert alert-info">
                You have been logged out successfully.
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="post" novalidate>

            <div class="form-group">
                <label for="email">University Email</label>
                <input type="email" id="email" name="email"
                       placeholder="yourname@sjsu.edu" required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Enter your password" required>
            </div>

            <button type="submit" class="btn-submit">Log In</button>
        </form>

        <p class="form-footer">
            Don't have an account? <a href="<%= request.getContextPath() %>/src/register.jsp">Sign up here</a>
        </p>
    </div>
</div>

</body>
</html>
