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
        <a href="addSkills.jsp">Add Skills</a>
        <a href="mySkills.jsp">My Skills</a>
    <% } %>
</div>

<h3>Add a skill you would like offer on this page!</h3>

<form action="addSkill.jsp" method="post">
  <input type="text" name="title" placeholder="Skill Title" required />
  <input type="text" name="category" placeholder="Category" required />
  <textarea name="description" placeholder="Description"></textarea>
  <button type="submit">Add Skill</button>
</form>

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
h3{
    color: #333;
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

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}

th, td {
    border: 1px solid #ddd;
    padding: 10px;
    text-align: left;
    text-decoration: none;
}

th {
    background-color: #f2f2f2;
}

tr:hover {
    background-color: #f9f9f9;
}
</style>
    <%

     String db = "Lau";
        String user; // assumes database name is the same as username
          user = "root";
        //String password = ;     //password removed until I set up ENV variable later
        try {

        // code for SQL connection will be added here later


        } catch(Exception e) {
            out.println("SQLException caught: " + e.getMessage());
        }
    %>
</body>
</html>