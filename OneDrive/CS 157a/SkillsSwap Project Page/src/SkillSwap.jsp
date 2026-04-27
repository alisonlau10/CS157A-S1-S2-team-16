<%@ page import="java.sql.*"%>
<html>
<head>
  <title>SkillSwap Campus</title>
</head>
<body>
<h1>SkillSwap Campus</h1>
<h2>A website where students provide services in exchange for other services. Free for all.</h2>

<div class="navbar">
    <a href="SkillSwap.jsp">Home</a>
    <% if (session.getAttribute("userId") != null) { %>
        <a href="dashboard.jsp">Dashboard</a>
        <a href="listOfSkills.jsp">Browse Skills</a>
        <a href="addSkills.jsp">Add Skills</a>
        <a href="<%= request.getContextPath() %>/logout">Logout</a>
    <% } else { %>
        <a href="login.jsp">Login</a>
        <a href="register.jsp">Register</a>
        <a href="listOfSkills.jsp">List of Skills</a>
    <% } %>
</div>

<div class="siteDescription">
    <h3 id="desc">Here on SkillSwap Campus, users can trade abilities using a credit-based system.
    Users will be able to seek help by listing skills they can offer and send out help requests seeking skills they need.</h3>
</div>

<div class="requestDemo">
    <div class="card listSkills">List Skills</div>
    <p class= "arrow">--></p>
    <div class="card sendRequest">Send Request</div>
    <p class= "arrow">--></p>
    <div class="card reviewRequest">Review Request</div>
</div>


<style>
body{
    font-family: Arial, sans-serif;
    margin: 40px;
    background: #FFF5EE;
}

h1{
    color: #333;
}
h2{
    color: #333;
}

.desc{
    color: #AA336A;

}

.navbar {
    display: flex;
    gap: 20px;
    padding: 10px 0;
    border-bottom: 2px solid #eee;
    padding: 20px;
    background: #F8C8DC;
    border-radius: 20px;

}

.navbar a {
    text-decoration: none;
    color: #2c7be5;
    font-weight: bold;
    padding: 5px 10px;
}

.navbar a:hover {
    background-color: #f5f5f5;
    border-radius: 5px;
}

.requestDemo {
    display: flex;
    gap: 20px;
    margin-top: 20px;
}

.card {
     flex: 1;
        padding: 30px;
        text-align: center;
        font-family: cursive;
        font-size: 2.5rem;
        font-weight: 600;
        color: #7a2d3b;
        background-color: #e6b8c7;

        clip-path: polygon(
            0% 0%,
            100% 0%,
            100% 30%,
            95% 50%,
            100% 70%,
            100% 100%,
            0% 100%,
            0% 70%,
            5% 50%,
            0% 30%
        );
}

/* Different colors */
.listSkills {
    background-color: #D8BFD8;   /*thistle*/
}

.sendRequest {
    background-color: #F3CFC6;   /*millennial pink*/
}

.reviewRequest {
    background-color: #E37383;   /*watermelon pink*/
}

.arrow{
    font-size: 50px;
    font-family: cursive;
    color: #953553;
}

</style>
    <%
     String db = "Lau";
        String user; // assumes database name is the same as username
          user = "root";
        //String password = ;   //password removed until I set up ENV variable later
        try {

        } catch(Exception e) {
            out.println("Exception caught: " + e.getMessage());
        }
    %>
</body>
</html>