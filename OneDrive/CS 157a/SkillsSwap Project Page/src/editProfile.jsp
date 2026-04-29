<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int    userId   = (Integer) session.getAttribute("userId");
    String userName = (String)  session.getAttribute("userName");

    // Load current profile data
    String fullName      = userName != null ? userName : "";
    String major         = "";
    String rawBio        = "";
    String availability  = "";
    String profilePic    = "";
    String skillsOffered = "";
    String personalBio   = "";
    String skillsWanted  = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = com.skillswap.DatabaseUtil.getConnection();

        // Fetch user + student data
        stmt = conn.prepareStatement(
            "SELECT u.full_name, u.major, s.bio, s.profile_picture, s.availability_schedule "
            + "FROM users u JOIN students s ON u.user_id = s.user_id WHERE u.user_id = ?");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) {
            fullName     = rs.getString("full_name") != null ? rs.getString("full_name") : "";
            major        = rs.getString("major")     != null ? rs.getString("major")     : "";
            rawBio       = rs.getString("bio")       != null ? rs.getString("bio")       : "";
            profilePic   = rs.getString("profile_picture")     != null ? rs.getString("profile_picture")     : "";
            availability = rs.getString("availability_schedule") != null ? rs.getString("availability_schedule") : "";
        }
        com.skillswap.DatabaseUtil.close(null, stmt, rs);
        stmt = null; rs = null;

        // Parse bio and skills wanted
        String SW_DELIM = "\n---Skills Wanted: ";
        if (rawBio.contains(SW_DELIM)) {
            int idx = rawBio.lastIndexOf(SW_DELIM);
            personalBio  = rawBio.substring(0, idx).trim();
            skillsWanted = rawBio.substring(idx + SW_DELIM.length()).trim();
        } else if (rawBio.startsWith("Skills Wanted: ")) {
            // Old registration format
            personalBio  = "";
            skillsWanted = rawBio.substring("Skills Wanted: ".length()).trim();
        } else {
            personalBio = rawBio.trim();
        }

        // Fetch skills offered
        stmt = conn.prepareStatement(
            "SELECT title FROM skills WHERE user_id = ? AND status = 'Active' ORDER BY skill_id");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        StringBuilder sb = new StringBuilder();
        while (rs.next()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(rs.getString("title"));
        }
        skillsOffered = sb.toString();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        com.skillswap.DatabaseUtil.close(conn, stmt, rs);
    }

    String error   = request.getParameter("error");
    String updated = request.getParameter("updated");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile - SkillSwap Campus</title>
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

        .page-wrapper {
            display: flex;
            justify-content: center;
            padding: 0 20px 40px;
        }

        .form-card {
            background: #fff;
            border: 2px solid #F3CFC6;
            border-radius: 20px;
            padding: 40px 45px;
            width: 100%;
            max-width: 600px;
            box-shadow: 0 4px 20px rgba(170,51,106,0.08);
        }

        .form-title {
            font-family: cursive;
            font-size: 2rem;
            color: #7a2d3b;
            margin-bottom: 6px;
        }
        .form-subtitle {
            color: #888;
            font-size: 0.95rem;
            margin-bottom: 28px;
        }

        .alert {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 0.95rem;
        }
        .alert-error   { background: #fde8e8; color: #c0392b; border: 1px solid #f5c6cb; }
        .alert-success { background: #eafaf1; color: #1e8449; border: 1px solid #a9dfbf; }

        .section-label {
            font-size: 0.8rem;
            font-weight: bold;
            color: #AA336A;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin: 24px 0 14px;
            border-bottom: 1px solid #F3CFC6;
            padding-bottom: 6px;
        }

        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block;
            font-weight: bold;
            color: #555;
            margin-bottom: 6px;
            font-size: 0.9rem;
        }
        .required { color: #AA336A; }
        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid #ddd;
            border-radius: 10px;
            font-size: 0.95rem;
            font-family: Arial, sans-serif;
            transition: border-color 0.2s;
            background: #FFFAFA;
        }
        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #F8C8DC;
            background: #fff;
        }
        .form-group textarea { resize: vertical; min-height: 80px; }
        .form-hint { font-size: 0.8rem; color: #aaa; margin-top: 4px; }

        .btn-row {
            display: flex;
            gap: 14px;
            margin-top: 28px;
        }

        .btn-submit {
            flex: 1;
            padding: 13px;
            background: #AA336A;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
        }
        .btn-submit:hover  { background: #8e2a58; }
        .btn-submit:active { transform: scale(0.98); }

        .btn-cancel {
            padding: 13px 24px;
            background: #f0f0f0;
            color: #555;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            transition: background 0.2s;
        }
        .btn-cancel:hover { background: #ddd; }

        .danger-zone {
            margin-top: 36px;
            padding: 20px 24px;
            border: 2px solid #f5c6cb;
            border-radius: 16px;
            background: #fff5f5;
        }
        .danger-zone h4 {
            color: #c0392b;
            font-family: cursive;
            font-size: 1.1rem;
            margin-bottom: 8px;
        }
        .danger-zone p { color: #777; font-size: 0.88rem; margin-bottom: 14px; }
        .btn-danger {
            padding: 10px 22px;
            background: #c0392b;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 0.9rem;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-danger:hover { background: #a93226; }
    </style>
</head>
<body>

<nav class="navbar">
    <span class="brand">SkillSwap Campus</span>
    <a href="SkillSwap.jsp">Home</a>
    <a href="dashboard.jsp">Dashboard</a>
    <a href="listOfSkills.jsp">Browse Skills</a>
    <a href="mySkills.jsp">My Skills</a>
    <a href="addSkill.jsp">Add Skill</a>
    <a href="messages.jsp">Messages</a>
    <a href="<%= request.getContextPath() %>/trackExchangeStatus">My Exchanges</a>
    <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Log Out</a>
</nav>

<div class="page-wrapper">
    <div class="form-card">

        <h2 class="form-title">Edit Profile</h2>
        <p class="form-subtitle">Update your account information and skills</p>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } else if ("true".equals(updated)) { %>
            <div class="alert alert-success">Profile updated successfully!</div>
        <% } %>

        <form action="<%= request.getContextPath() %>/updateProfile" method="post">

            <div class="section-label">Account Info</div>

            <div class="form-group">
                <label for="fullName">Full Name <span class="required">*</span></label>
                <input type="text" id="fullName" name="fullName"
                       value="<%= fullName %>" required>
            </div>

            <div class="form-group">
                <label for="major">Major</label>
                <input type="text" id="major" name="major"
                       value="<%= major %>"
                       placeholder="e.g. Computer Science">
            </div>

            <div class="section-label">Profile Details</div>

            <div class="form-group">
                <label for="profilePicture">Profile Picture URL</label>
                <input type="text" id="profilePicture" name="profilePicture"
                       value="<%= profilePic %>"
                       placeholder="e.g. https://example.com/photo.jpg or filename.jpg">
                <p class="form-hint">Enter a URL or filename for your profile photo.</p>
            </div>

            <div class="form-group">
                <label for="bio">Bio / Personal Description</label>
                <textarea id="bio" name="bio"
                          placeholder="Tell others about yourself..."><%= personalBio %></textarea>
            </div>

            <div class="form-group">
                <label for="availability">Availability Schedule</label>
                <input type="text" id="availability" name="availability"
                       value="<%= availability %>"
                       placeholder="e.g. Mon/Wed 2PM-5PM">
            </div>

            <div class="section-label">Skills</div>

            <div class="form-group">
                <label for="skillsOffered">Skills I Can Offer</label>
                <input type="text" id="skillsOffered" name="skillsOffered"
                       value="<%= skillsOffered %>"
                       placeholder="e.g. Python, Calculus, Guitar">
                <p class="form-hint">Separate multiple skills with commas. Existing skills will be replaced.</p>
            </div>

            <div class="form-group">
                <label for="skillsWanted">Skills I Want to Learn</label>
                <input type="text" id="skillsWanted" name="skillsWanted"
                       value="<%= skillsWanted %>"
                       placeholder="e.g. Spanish, Graphic Design">
                <p class="form-hint">Separate multiple skills with commas.</p>
            </div>

            <div class="btn-row">
                <a href="dashboard.jsp" class="btn-cancel">Cancel</a>
                <button type="submit" class="btn-submit">Save Changes</button>
            </div>
        </form>

        <!-- Danger Zone -->
        <div class="danger-zone">
            <h4>Danger Zone</h4>
            <p>Permanently delete your account and all associated data. This action cannot be undone.</p>
            <a href="deleteAccount.jsp" class="btn-danger">Delete My Account</a>
        </div>

    </div>
</div>

</body>
</html>
