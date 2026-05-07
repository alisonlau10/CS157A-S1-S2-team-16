<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer requestId      = (Integer) request.getAttribute("requestId");
    Integer revieweeId     = (Integer) request.getAttribute("revieweeId");
    String  otherName      = (String)  request.getAttribute("otherName");
    String  requestedSkill = (String)  request.getAttribute("requestedSkill");
    String  offeredSkill   = (String)  request.getAttribute("offeredSkill");
    Boolean alreadyReviewed    = (Boolean) request.getAttribute("alreadyReviewed");
    String  error              = (String)  request.getAttribute("error");
    Integer existingRating       = (Integer) request.getAttribute("existingRating");
    String  existingComment      = (String)  request.getAttribute("existingComment");
    Integer partnerRating        = (Integer) request.getAttribute("partnerRating");
    String  partnerComment       = (String)  request.getAttribute("partnerComment");
    String  partnerReviewerName  = (String)  request.getAttribute("partnerReviewerName");
    if (alreadyReviewed == null) alreadyReviewed = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave a Review - SkillSwap Campus</title>
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

        .container { max-width: 600px; margin: 0 auto; }

        .card {
            background: white; border: 2px solid #F3CFC6;
            border-radius: 18px; padding: 34px 38px;
            box-shadow: 0 2px 10px rgba(170,51,106,0.08);
        }
        h1 { font-family: cursive; color: #7a2d3b; margin-bottom: 6px; }
        .subtitle { color: #888; margin-bottom: 24px; font-size: 0.95rem; }

        .exchange-info {
            background: #fff7fa; border: 1px solid #F3CFC6;
            border-radius: 12px; padding: 16px 18px; margin-bottom: 26px;
            font-size: 0.93rem; color: #555;
        }
        .exchange-info span { font-weight: bold; color: #7a2d3b; }

        label { display: block; font-weight: bold; color: #555; margin-bottom: 8px; font-size: 0.93rem; }

        /* Star rating */
        .star-group { display: flex; gap: 8px; margin-bottom: 22px; flex-direction: row-reverse; justify-content: flex-end; }
        .star-group input[type="radio"] { display: none; }
        .star-group label {
            font-size: 2rem; cursor: pointer; color: #ddd;
            margin: 0; padding: 0; font-weight: normal;
            transition: color 0.15s;
        }
        .star-group input[type="radio"]:checked ~ label,
        .star-group label:hover,
        .star-group label:hover ~ label { color: #f5a623; }

        textarea {
            width: 100%; padding: 12px 14px;
            border: 2px solid #F3CFC6; border-radius: 12px;
            font-size: 0.95rem; font-family: Arial, sans-serif;
            resize: vertical; min-height: 110px; outline: none;
            margin-bottom: 22px;
        }
        textarea:focus { border-color: #AA336A; }

        .btn-submit {
            width: 100%; padding: 13px; background: #AA336A; color: white;
            border: none; border-radius: 12px; font-size: 1rem;
            font-weight: bold; cursor: pointer;
        }
        .btn-submit:hover { background: #8e2a58; }

        .btn-back { display: inline-block; margin-top: 14px; color: #AA336A; font-weight: bold; text-decoration: none; }
        .btn-back:hover { text-decoration: underline; }

        .alert-already {
            background: #e8f8e8; border: 1px solid #a8d8a8;
            color: #2e7d32; border-radius: 10px; padding: 14px 18px;
            margin-bottom: 18px; font-size: 0.93rem;
        }
        .review-display {
            background: #fff7fa; border: 2px solid #F3CFC6;
            border-radius: 14px; padding: 20px 22px; margin-bottom: 18px;
        }
        .review-display .stars { font-size: 1.5rem; color: #f5a623; margin-bottom: 8px; }
        .review-display .reviewer { font-size: 0.85rem; color: #888; margin-bottom: 10px; }
        .review-display .comment { color: #444; font-size: 0.95rem; font-style: italic; }
        .partner-review-box {
            background: #f0f4ff; border: 2px solid #c7d9f5;
            border-radius: 14px; padding: 20px 22px; margin-bottom: 22px;
        }
        .partner-review-box h4 { color: #1a56db; margin-bottom: 12px; font-size: 0.95rem; }
        .partner-review-box .stars { font-size: 1.4rem; color: #f5a623; margin-bottom: 6px; }
        .partner-review-box .comment { color: #444; font-size: 0.93rem; font-style: italic; }
        .partner-review-box .no-review { color: #aaa; font-size: 0.9rem; }
        .alert-error {
            background: #fde8e8; border: 1px solid #f5c6cb;
            color: #c0392b; border-radius: 10px; padding: 12px 16px;
            margin-bottom: 18px; font-size: 0.93rem;
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
        <h1>&#11088; Leave a Review</h1>
        <p class="subtitle">Share your experience after the exchange with <%= otherName != null ? otherName : "your partner" %>.</p>

        <% if (error != null) { %>
            <div class="alert-error"><%= error %></div>
        <% } %>

        <!-- Exchange summary -->
        <div class="exchange-info">
            <span>Exchange #<%= requestId %></span><br>
            Requested: <%= requestedSkill %> &nbsp;&#8644;&nbsp; Offered: <%= offeredSkill %>
        </div>

        <!-- Partner's review — always shown if they have already reviewed -->
        <% if (partnerRating != null) { %>
        <div class="partner-review-box">
            <h4>&#128100; <%= partnerReviewerName %>'s Review</h4>
            <div class="stars">
                <%
                    for (int i = 0; i < partnerRating; i++) out.print("&#9733;");
                    for (int i = partnerRating; i < 5; i++) out.print("<span style='color:#ddd'>&#9733;</span>");
                %>
                &nbsp;<strong><%= partnerRating %> / 5</strong>
            </div>
            <% if (partnerComment != null && !partnerComment.isEmpty()) { %>
                <div class="comment">"<%= partnerComment %>"</div>
            <% } else { %>
                <div class="comment" style="color:#aaa;">No written comment.</div>
            <% } %>
        </div>
        <% } else { %>
        <div class="partner-review-box">
            <h4>&#128100; <%= otherName %>'s Review</h4>
            <p class="no-review">They haven't left a review yet.</p>
        </div>
        <% } %>

        <% if (alreadyReviewed) { %>
            <div class="alert-already">
                &#10003; You have already submitted your review for this exchange.
            </div>
            <div class="review-display">
                <div class="stars">
                    <%
                        int stars = existingRating != null ? existingRating : 0;
                        for (int i = 0; i < stars; i++) { out.print("&#9733;"); }
                        for (int i = stars; i < 5; i++) { out.print("<span style='color:#ddd'>&#9733;</span>"); }
                    %>
                    &nbsp;<strong><%= stars %> / 5</strong>
                </div>
                <div class="reviewer">Your review</div>
                <% if (existingComment != null && !existingComment.isEmpty()) { %>
                    <div class="comment">"<%= existingComment %>"</div>
                <% } else { %>
                    <div class="comment" style="color:#aaa;">No written comment.</div>
                <% } %>
            </div>
            <a class="btn-back" href="<%= request.getContextPath() %>/trackExchangeStatus">&#8592; Back to My Exchanges</a>
        <% } else { %>
        <form action="<%= request.getContextPath() %>/leaveReview" method="post">
            <input type="hidden" name="requestId"  value="<%= requestId %>">
            <input type="hidden" name="revieweeId" value="<%= revieweeId %>">

            <label>Rating *</label>
            <div class="star-group">
                <input type="radio" id="s5" name="rating" value="5" required>
                <label for="s5" title="5 stars">&#9733;</label>
                <input type="radio" id="s4" name="rating" value="4">
                <label for="s4" title="4 stars">&#9733;</label>
                <input type="radio" id="s3" name="rating" value="3">
                <label for="s3" title="3 stars">&#9733;</label>
                <input type="radio" id="s2" name="rating" value="2">
                <label for="s2" title="2 stars">&#9733;</label>
                <input type="radio" id="s1" name="rating" value="1">
                <label for="s1" title="1 star">&#9733;</label>
            </div>

            <label for="comment">Comment (optional)</label>
            <textarea id="comment" name="comment"
                      placeholder="Describe your experience with this exchange..."></textarea>

            <button class="btn-submit" type="submit">Submit Review</button>
        </form>

        <a class="btn-back" href="<%= request.getContextPath() %>/trackExchangeStatus">&#8592; Back to My Exchanges</a>
        <% } %>
    </div>
</div>

</body>
</html>
