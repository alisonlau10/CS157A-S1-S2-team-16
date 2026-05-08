# SkillSwap Campus — Team Setup Guide

CS 157A Sec 1, Team 16  
Alison Lau · Dhruhi Sheth · Pranavi Immanni

---

## Prerequisites

Install these once on your machine before running the project.

| Tool | Version | Download |
|------|---------|----------|
| JDK | 11 or higher | https://www.oracle.com/java/technologies/downloads/ |
| MySQL Community Server | 8 or 9 | https://dev.mysql.com/downloads/mysql/ |
| Apache Tomcat | 9.0.115 | https://tomcat.apache.org/download-90.cgi |

> **macOS tip:** After installing MySQL, it will appear in System Preferences. Make sure it is started before running the app.

---

## First-Time Setup (run once)

### Step 1 — Clone the repository

```bash
git clone https://github.com/dhruhisheth/CS157A-S1-S2-team-16.git
cd CS157A-S1-S2-team-16
```

### Step 2 — Navigate to the project folder

```bash
cd "OneDrive/CS 157a/SkillsSwap Project Page"
```

### Step 3 — Run the setup script

The script will ask for your Tomcat path and MySQL password, then handle everything automatically.

```bash
bash setup.sh
```

It will:
- Create `WEB-INF/db.properties` with your local MySQL password (gitignored — never pushed)
- Import the `skillswap_campus` database (10 tables + seed data)
- Compile all Java servlets to `WEB-INF/classes/`
- Register the app with Tomcat via a context file
- Start Tomcat

### Step 4 — Open in your browser

| Page | URL |
|------|-----|
| Home | http://localhost:8080/skillswap/src/SkillSwap.jsp |
| Register | http://localhost:8080/skillswap/src/register.jsp |
| Login | http://localhost:8080/skillswap/src/login.jsp |
| Dashboard | http://localhost:8080/skillswap/src/dashboard.jsp |
| Browse Skills | http://localhost:8080/skillswap/src/listOfSkills.jsp |
| My Exchanges | http://localhost:8080/skillswap/trackExchangeStatus |

---

## Daily Workflow (after first-time setup)

### Start the app

```bash
# 1. Make sure MySQL is running (System Preferences > MySQL, or:)
sudo /usr/local/mysql/support-files/mysql.server start

# 2. Start Tomcat
~/Desktop/apache-tomcat-9.0.115/bin/startup.sh
```

### Stop the app

```bash
~/Desktop/apache-tomcat-9.0.115/bin/shutdown.sh
```

### After pulling new code

If a teammate changed a `.java` file, recompile before testing:

```bash
javac \
  -cp "~/Desktop/apache-tomcat-9.0.115/lib/servlet-api.jar:~/Desktop/apache-tomcat-9.0.115/lib/mysql-connector-j-9.6.0.jar" \
  -d "WEB-INF/classes" \
  "src/com/skillswap/"*.java
```

Then copy `db.properties` back to the classpath:

```bash
cp WEB-INF/db.properties WEB-INF/classes/db.properties
```

> JSP changes (`.jsp` files) take effect immediately on refresh — no recompile needed.

---

## Project Structure

```
SkillsSwap Project Page/
├── src/
│   ├── com/skillswap/              ← Java servlet source files
│   │   ├── DatabaseUtil.java       ← DB connection utility
│   │   ├── RegisterServlet.java    ← FR 1 — Register Account
│   │   ├── LoginServlet.java       ← FR 2 — Account Login
│   │   ├── LogoutServlet.java      ← FR 3 — Account Logout
│   │   ├── DeleteAccountServlet.java  ← FR 4 — Delete Account
│   │   ├── UpdateProfileServlet.java  ← FR 5 — Manage Profile
│   │   ├── ViewStudentProfileServlet.java ← FR 6 — Perform Search
│   │   ├── TrackExchangeStatusServlet.java ← FR 7/8 — Exchange Requests
│   │   ├── CompleteExchangeServlet.java    ← FR 9 — Complete Exchange
│   │   ├── AddSkillServlet.java
│   │   ├── UpdateSkillServlet.java
│   │   └── DeleteSkillServlet.java
│   ├── SkillSwap.jsp           ← Home page
│   ├── register.jsp            ← Registration form
│   ├── login.jsp               ← Login form
│   ├── dashboard.jsp           ← Student dashboard (post-login)
│   ├── editProfile.jsp         ← Edit profile form
│   ├── deleteAccount.jsp       ← Delete account confirmation
│   ├── listOfSkills.jsp        ← Browse all skills
│   ├── trackExchangeStatus.jsp ← My Exchanges page
│   ├── viewStudentProfile.jsp  ← View another student's profile
│   ├── addSkill.jsp
│   ├── editSkill.jsp
│   ├── mySkills.jsp
│   └── messages.jsp
├── WEB-INF/
│   ├── web.xml                 ← Servlet mappings
│   ├── db.properties.example   ← Template — copy to db.properties
│   └── db.properties           ← YOUR local credentials (gitignored)
├── skillswap_campus.sql        ← Full database schema + seed data (10 tables)
└── setup.sh                    ← First-time setup script
```

---

## Database

| Setting | Value |
|---------|-------|
| Host | localhost:3306 |
| Database | skillswap_campus |
| User | root |
| Password | *(your local MySQL password — set in db.properties)* |

**Tables:** Activity_Log, Admins, Exchange_Requests, Messages, Notifications, Reviews, Skill_Categories, Skills, Students, Users

To browse the database directly:

```bash
/usr/local/mysql/bin/mysql -u root -p skillswap_campus
```

Useful queries:
```sql
SHOW TABLES;
SELECT * FROM users;
SELECT * FROM students;
SELECT * FROM skills WHERE status = 'Active';
SELECT * FROM exchange_requests ORDER BY created_at DESC;
SELECT * FROM reviews;
SELECT * FROM activity_log ORDER BY timestamp DESC;
```

---

## Troubleshooting

**"Cannot find db.properties"**  
Copy the template, fill in your password, and copy to the classpath:
```bash
cp WEB-INF/db.properties.example WEB-INF/db.properties
cp WEB-INF/db.properties WEB-INF/classes/db.properties
```

**"Access denied for user root"**  
Your MySQL password in `db.properties` is wrong. Verify it with:
```bash
/usr/local/mysql/bin/mysql -u root -p
```

**Port 8080 already in use**  
Another Tomcat is already running. Stop it first:
```bash
~/Desktop/apache-tomcat-9.0.115/bin/shutdown.sh
```

**Servlet changes not showing**  
Recompile (see "After pulling new code" above), then restart Tomcat.

**404 on /register, /login, or /trackExchangeStatus**  
Check that `skillswap.xml` in Tomcat's `conf/Catalina/localhost/` points to the correct absolute path of the project folder.
