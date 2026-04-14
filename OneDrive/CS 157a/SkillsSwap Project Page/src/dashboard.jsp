<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/src/login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("role");

    int creditBalance = 0;
    String bio = "";
    String major = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = com.skillswap.DatabaseUtil.getConnection();
        stmt = conn.prepareStatement(
            "SELECT u.major, s.bio, s.credit_balance " +
            "FROM users u JOIN students s ON u.user_id = s.user_id " +
            "WHERE u.user_id = ?"
        );
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();

        if (rs.next()) {
            major = rs.getString("major") != null ? rs.getString("major") : "";
            bio = rs.getString("bio") != null ? rs.getString("bio") : "";
            creditBalance = rs.getInt("credit_balance");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        com.skillswap.DatabaseUtil.close(conn, stmt, rs);
    }
%>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Dashboard - SkillSwap Campus</title>
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

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
                        gap: 16px;
                        padding: 15px 25px;
                        background: #F8C8DC;
                        border-radius: 20px;
                        margin-bottom: 30px;
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

                    .navbar a:hover {
                        background: rgba(255, 255, 255, 0.6);
                    }

                    .navbar .btn-logout {
                        background: #AA336A;
                        color: white;
                        padding: 7px 16px;
                        border-radius: 10px;
                        font-weight: bold;
                        text-decoration: none;
                        transition: background 0.2s;
                    }

                    .navbar .btn-logout:hover {
                        background: #8e2a58;
                    }

                    /* ── Welcome banner ── */
                    .welcome-banner {
                        background: linear-gradient(135deg, #D8BFD8 0%, #F8C8DC 100%);
                        border-radius: 20px;
                        padding: 30px 35px;
                        margin-bottom: 30px;
                        display: flex;
                        align-items: center;
                        gap: 24px;
                    }

                    .avatar {
                        width: 70px;
                        height: 70px;
                        border-radius: 50%;
                        background: #AA336A;
                        color: white;
                        font-family: cursive;
                        font-size: 1.8rem;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        flex-shrink: 0;
                        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.15);
                    }

                    .welcome-text h2 {
                        font-family: cursive;
                        font-size: 1.7rem;
                        color: #7a2d3b;
                        margin-bottom: 4px;
                    }

                    .welcome-text p {
                        color: #666;
                        font-size: 0.95rem;
                    }

                    .welcome-text .role-badge {
                        display: inline-block;
                        background: #AA336A;
                        color: white;
                        font-size: 0.75rem;
                        padding: 2px 10px;
                        border-radius: 20px;
                        margin-top: 6px;
                        font-weight: bold;
                        letter-spacing: 0.05em;
                    }

                    /* ── Stats row ── */
                    .stats-row {
                        display: flex;
                        gap: 20px;
                        margin-bottom: 30px;
                        flex-wrap: wrap;
                    }

                    .stat-card {
                        flex: 1;
                        min-width: 150px;
                        background: #fff;
                        border: 2px solid #F3CFC6;
                        border-radius: 16px;
                        padding: 22px 24px;
                        text-align: center;
                        box-shadow: 0 2px 10px rgba(170, 51, 106, 0.06);
                    }

                    .stat-value {
                        font-family: cursive;
                        font-size: 2.2rem;
                        color: #AA336A;
                        font-weight: 700;
                    }

                    .stat-label {
                        color: #888;
                        font-size: 0.85rem;
                        margin-top: 4px;
                    }

                    /* ── Quick actions grid ── */
                    .section-title {
                        font-family: cursive;
                        font-size: 1.4rem;
                        color: #7a2d3b;
                        margin-bottom: 18px;
                    }

                    .actions-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                        gap: 18px;
                        margin-bottom: 30px;
                    }

                    .action-card {
                        background: #fff;
                        border: 2px solid #F3CFC6;
                        border-radius: 16px;
                        padding: 24px 20px;
                        text-align: center;
                        text-decoration: none;
                        color: inherit;
                        transition: transform 0.15s, box-shadow 0.15s;
                        box-shadow: 0 2px 8px rgba(170, 51, 106, 0.06);
                    }

                    .action-card:hover {
                        transform: translateY(-3px);
                        box-shadow: 0 6px 20px rgba(170, 51, 106, 0.13);
                        border-color: #AA336A;
                    }

                    .action-icon {
                        font-size: 2rem;
                        margin-bottom: 10px;
                    }

                    .action-label {
                        font-weight: bold;
                        color: #7a2d3b;
                        font-size: 0.95rem;
                    }

                    .action-desc {
                        color: #999;
                        font-size: 0.82rem;
                        margin-top: 4px;
                    }

                    /* ── Profile info card ── */
                    .info-card {
                        background: #fff;
                        border: 2px solid #F3CFC6;
                        border-radius: 16px;
                        padding: 28px 30px;
                        box-shadow: 0 2px 10px rgba(170, 51, 106, 0.06);
                    }

                    .info-row {
                        display: flex;
                        gap: 12px;
                        padding: 10px 0;
                        border-bottom: 1px solid #f9e8f0;
                        font-size: 0.95rem;
                    }

                    .info-row:last-child {
                        border-bottom: none;
                    }

                    .info-key {
                        font-weight: bold;
                        color: #555;
                        min-width: 120px;
                    }

                    .info-val {
                        color: #333;
                    }
                </style>
            </head>

            <body>

                <nav class="navbar">
                    <span class="brand">SkillSwap Campus</span>
                    <a href="SkillSwap.jsp">Home</a>
                    <a href="listOfSkills.jsp">Browse Skills</a>
                    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
                </nav>

                <!-- Welcome Banner -->
                <div class="welcome-banner">
                    <div class="avatar">
                        <%= userName.substring(0, 1).toUpperCase() %>
                    </div>
                    <div class="welcome-text">
                        <h2>Welcome, <%= userName %>!</h2>
                        <p>
                            <%= major.isEmpty() ? "SkillSwap Campus Member" : major %>
                        </p>
                        <span class="role-badge">
                            <%= role %>
                        </span>
                    </div>
                </div>

                <!-- Stats Row -->
                <div class="stats-row">
                    <div class="stat-card">
                        <div class="stat-value">
                            <%= creditBalance %>
                        </div>
                        <div class="stat-label">Credit Balance</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value">0</div>
                        <div class="stat-label">Active Exchanges</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value">0</div>
                        <div class="stat-label">Skills Offered</div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <h3 class="section-title">Quick Actions</h3>
                <div class="actions-grid">
                    <a class="action-card" href="listOfSkills.jsp">
                        <div class="action-icon">&#128269;</div>
                        <div class="action-label">Browse Skills</div>
                        <div class="action-desc">Discover skills offered by other students</div>
                    </a>
                    <a class="action-card" href="#">
                        <div class="action-icon">&#10133;</div>
                        <div class="action-label">Add a Skill</div>
                        <div class="action-desc">List a new skill you can teach or share</div>
                    </a>
                    <a class="action-card" href="<%= request.getContextPath() %>/trackExchangeStatus">
                        <div class="action-icon">&#128257;</div>
                        <div class="action-label">My Exchanges</div>
                        <div class="action-desc">Track pending, active, and completed exchanges</div>
                    </a>
                    <a class="action-card" href="#">
                        <div class="action-icon">&#128140;</div>
                        <div class="action-label">Messages</div>
                        <div class="action-desc">View and send messages to other students</div>
                    </a>
                    <a class="action-card" href="#">
                        <div class="action-icon">&#128100;</div>
                        <div class="action-label">Edit Profile</div>
                        <div class="action-desc">Update your bio, skills, and availability</div>
                    </a>
                </div>

                <!-- Account Info -->
                <h3 class="section-title">Account Info</h3>
                <div class="info-card">
                    <div class="info-row">
                        <span class="info-key">Name</span>
                        <span class="info-val">
                            <%= userName %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Major</span>
                        <span class="info-val">
                            <%= major.isEmpty() ? "—" : major %>
                        </span>
                    </div>
                    <% if (!bio.isEmpty()) { %>
                        <div class="info-row">
                            <span class="info-key">Bio</span>
                            <span class="info-val">
                                <%= bio %>
                            </span>
                        </div>
                        <% } %>
                            <div class="info-row">
                                <span class="info-key">Role</span>
                                <span class="info-val">
                                    <%= role %>
                                </span>
                            </div>
                </div>

            </body>

            </html>