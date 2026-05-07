<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int    userId   = (Integer) session.getAttribute("userId");
    String userName = (String)  session.getAttribute("userName");
    String role     = (String)  session.getAttribute("role");

    int    creditBalance   = 0;
    String bio             = "";
    String skillsWanted    = "";
    String major           = "";
    String profilePicture  = "";
    String availability    = "";
    double avgRating       = 0;
    int    reviewCount     = 0;
    List<String> skillsOffered = new ArrayList<>();

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    try {
        conn = com.skillswap.DatabaseUtil.getConnection();

        // Profile
        stmt = conn.prepareStatement(
            "SELECT u.Major, s.Bio, s.Credit_Balance, s.Profile_Picture, s.Availability_Schedule " +
            "FROM Users u JOIN Students s ON u.User_ID = s.User_ID WHERE u.User_ID = ?");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) {
            major          = rs.getString("Major")                != null ? rs.getString("Major")                 : "";
            profilePicture = rs.getString("Profile_Picture")      != null ? rs.getString("Profile_Picture")       : "";
            availability   = rs.getString("Availability_Schedule") != null ? rs.getString("Availability_Schedule") : "";
            creditBalance  = rs.getInt("Credit_Balance");
            String rawBio  = rs.getString("Bio") != null ? rs.getString("Bio") : "";
            // Split skills wanted out of bio
            String DELIM = "\n---Skills Wanted: ";
            if (rawBio.contains(DELIM)) {
                int idx    = rawBio.indexOf(DELIM);
                skillsWanted = rawBio.substring(idx + DELIM.length()).trim();
                bio          = rawBio.substring(0, idx).trim();
            } else {
                bio = rawBio.trim();
            }
        }
        com.skillswap.DatabaseUtil.close(null, stmt, rs);

        // Active skills offered
        stmt = conn.prepareStatement(
            "SELECT Title FROM Skills WHERE User_ID = ? AND Status = 'Active' ORDER BY Title");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        while (rs.next()) skillsOffered.add(rs.getString("Title"));
        com.skillswap.DatabaseUtil.close(null, stmt, rs);

        // Average rating received
        stmt = conn.prepareStatement(
            "SELECT COALESCE(AVG(Rating),0) AS avg_r, COUNT(*) AS cnt FROM Reviews WHERE Reviewee_ID = ?");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) {
            avgRating   = rs.getDouble("avg_r");
            reviewCount = rs.getInt("cnt");
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
            width: 70px; height: 70px;
            border-radius: 50%;
            background: #AA336A;
            color: white;
            font-family: cursive;
            font-size: 1.8rem;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
            box-shadow: 0 3px 10px rgba(0,0,0,0.15);
        }
        .welcome-text h2 {
            font-family: cursive;
            font-size: 1.7rem;
            color: #7a2d3b;
            margin-bottom: 4px;
        }
        .welcome-text p { color: #666; font-size: 0.95rem; }
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
            box-shadow: 0 2px 10px rgba(170,51,106,0.06);
        }
        .stat-value {
            font-family: cursive;
            font-size: 2.2rem;
            color: #AA336A;
            font-weight: 700;
        }
        .stat-label { color: #888; font-size: 0.85rem; margin-top: 4px; }

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
            box-shadow: 0 2px 8px rgba(170,51,106,0.06);
        }
        .action-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(170,51,106,0.13);
            border-color: #AA336A;
        }
        .action-icon { font-size: 2rem; margin-bottom: 10px; }
        .action-label {
            font-weight: bold;
            color: #7a2d3b;
            font-size: 0.95rem;
        }
        .action-desc { color: #999; font-size: 0.82rem; margin-top: 4px; }

        /* ── Profile info card ── */
        .info-card {
            background: #fff;
            border: 2px solid #F3CFC6;
            border-radius: 16px;
            padding: 28px 30px;
            box-shadow: 0 2px 10px rgba(170,51,106,0.06);
        }
        .info-row {
            display: flex;
            gap: 12px;
            padding: 10px 0;
            border-bottom: 1px solid #f9e8f0;
            font-size: 0.95rem;
        }
        .info-row:last-child { border-bottom: none; }
        .info-key { font-weight: bold; color: #555; min-width: 120px; }
        .info-val { color: #333; }
    </style>
</head>
<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="SkillSwap.jsp">Home</a>
    <a href="listOfSkills.jsp">Browse Skills</a>
    <a href="mySkills.jsp">My Skills</a>
    <a href="addSkill.jsp">Add Skill</a>
    <a href="messages.jsp">Messages</a>
    <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<!-- Welcome Banner -->
<div class="welcome-banner">
    <div class="avatar"><%= userName.substring(0, 1).toUpperCase() %></div>
    <div class="welcome-text">
        <h2>Welcome, <%= userName %>!</h2>
        <p><%= major.isEmpty() ? "SkillSwap Campus Member" : major %></p>
        <span class="role-badge"><%= role %></span>
    </div>
</div>

<!-- Stats Row -->
<div class="stats-row">
    <div class="stat-card">
        <div class="stat-value"><%= creditBalance %></div>
        <div class="stat-label">Credit Balance</div>
    </div>
    <a class="stat-card" href="<%= request.getContextPath() %>/src/mySkills.jsp" style="text-decoration:none; color:inherit;">
        <div class="stat-value"><%= skillsOffered.size() %></div>
        <div class="stat-label">Skills Offered</div>
    </a>
    <div class="stat-card">
        <%
            String ratingDisplay = reviewCount == 0 ? "—"
                : String.format("%.1f", avgRating);
        %>
        <div class="stat-value" style="font-size:1.6rem;">
            <%= ratingDisplay %>
            <% if (reviewCount > 0) { %><span style="font-size:1rem;color:#f5a623;">&#9733;</span><% } %>
        </div>
        <div class="stat-label">Avg Rating (<%= reviewCount %> review<%= reviewCount != 1 ? "s" : "" %>)</div>
    </div>
</div>

<!-- Quick Actions -->
<h3 class="section-title">Quick Actions</h3>
<div class="actions-grid">
    <a class="action-card" href="<%= request.getContextPath() %>/search">
        <div class="action-icon">&#128269;</div>
        <div class="action-label">Browse Skills</div>
        <div class="action-desc">Discover skills offered by other students</div>
    </a>
    <a class="action-card" href="addSkill.jsp">
        <div class="action-icon">&#10133;</div>
        <div class="action-label">Add a Skill</div>
        <div class="action-desc">List a new skill you can teach or share</div>
    </a>
    <a class="action-card" href="mySkills.jsp">
         <div class="action-icon">&#128218;</div>
         <div class="action-label">My Skills</div>
         <div class="action-desc">Edit or delete your offered skills</div>
    </a>
    <a class="action-card" href="<%= request.getContextPath() %>/trackExchangeStatus">
        <div class="action-icon">&#128257;</div>
        <div class="action-label">My Exchanges</div>
        <div class="action-desc">Track pending, active, and completed exchanges</div>
    </a>
    <a class="action-card" href="messages.jsp">
        <div class="action-icon">&#128140;</div>
        <div class="action-label">Messages</div>
        <div class="action-desc">View and send messages to other students</div>
    </a>
    <a class="action-card" href="editProfile.jsp">
        <div class="action-icon">&#128100;</div>
        <div class="action-label">Edit Profile</div>
        <div class="action-desc">Update your bio, skills, and availability</div>
    </a>
</div>

<!-- Account Info -->
<h3 class="section-title">Account Info</h3>
<div class="info-card">
    <% if (!profilePicture.isEmpty()) { %>
    <div class="info-row">
        <span class="info-key">Profile Picture</span>
        <span class="info-val">
            <img src="<%= profilePicture %>" alt="Profile"
                 style="width:60px;height:60px;border-radius:50%;object-fit:cover;border:2px solid #F3CFC6;"
                 onerror="this.style.display='none'">
        </span>
    </div>
    <% } %>
    <div class="info-row">
        <span class="info-key">Full Name</span>
        <span class="info-val"><%= userName %></span>
    </div>
    <div class="info-row">
        <span class="info-key">Major</span>
        <span class="info-val"><%= major.isEmpty() ? "—" : major %></span>
    </div>
    <div class="info-row">
        <span class="info-key">Bio</span>
        <span class="info-val"><%= bio.isEmpty() ? "—" : bio %></span>
    </div>
    <div class="info-row">
        <span class="info-key">Availability</span>
        <span class="info-val"><%= availability.isEmpty() ? "—" : availability %></span>
    </div>
    <div class="info-row">
        <span class="info-key">Skills I Offer</span>
        <span class="info-val">
            <% if (skillsOffered.isEmpty()) { %>—<% } else {
                for (int i = 0; i < skillsOffered.size(); i++) {
                    if (i > 0) out.print(", ");
                    out.print(skillsOffered.get(i));
                }
            } %>
        </span>
    </div>
    <div class="info-row">
        <span class="info-key">Skills I Want</span>
        <span class="info-val"><%= skillsWanted.isEmpty() ? "—" : skillsWanted %></span>
    </div>
    <div class="info-row">
        <span class="info-key">Role</span>
        <span class="info-val"><%= role %></span>
    </div>
</div>

<!-- Account Actions -->
<div style="margin-top: 24px; display: flex; gap: 14px; flex-wrap: wrap;">
    <a href="editProfile.jsp"
       style="padding: 10px 22px; background: #AA336A; color: white; border-radius: 12px;
              font-weight: bold; text-decoration: none; font-size: 0.95rem; transition: background 0.2s;"
       onmouseover="this.style.background='#8e2a58'" onmouseout="this.style.background='#AA336A'">
        &#9998; Edit Profile
    </a>
    <a href="deleteAccount.jsp"
       style="padding: 10px 22px; background: #fff; color: #c0392b; border: 2px solid #f5c6cb;
              border-radius: 12px; font-weight: bold; text-decoration: none; font-size: 0.95rem;
              transition: background 0.2s;"
       onmouseover="this.style.background='#fde8e8'" onmouseout="this.style.background='#fff'">
        &#128465; Delete Account
    </a>
</div>

</body>
</html>
