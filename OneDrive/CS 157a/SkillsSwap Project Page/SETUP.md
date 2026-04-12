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
- Import the `skillswap_campus` database
- Compile the Java servlets
- Register the app with Tomcat
- Start Tomcat

### Step 4 — Open in your browser

| Page | URL |
|------|-----|
| Home | http://localhost:8080/skillswap/src/SkillSwap.jsp |
| Register | http://localhost:8080/skillswap/src/register.jsp |
| Login | http://localhost:8080/skillswap/src/login.jsp |

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

> JSP changes (`.jsp` files) take effect immediately on refresh — no recompile needed.

---

## Project Structure

```
SkillsSwap Project Page/
├── src/
│   ├── com/skillswap/          ← Java servlet source files
│   │   ├── DatabaseUtil.java   ← DB connection (reads from db.properties)
│   │   ├── RegisterServlet.java
│   │   ├── LoginServlet.java
│   │   └── LogoutServlet.java
│   ├── SkillSwap.jsp           ← Home page
│   ├── register.jsp            ← Registration form
│   ├── login.jsp               ← Login form
│   ├── dashboard.jsp           ← Student dashboard (post-login)
│   └── listOfSkills.jsp        ← Browse all skills
├── WEB-INF/
│   ├── web.xml                 ← Servlet mappings
│   ├── db.properties.example   ← Template — copy to db.properties
│   └── db.properties           ← YOUR local credentials (gitignored)
├── skillswap_campus.sql        ← Full database schema + seed data
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

To browse the database directly:

```bash
/usr/local/mysql/bin/mysql -u root -p skillswap_campus
```

Useful queries:
```sql
SELECT * FROM users;
SELECT * FROM students;
SELECT * FROM skills;
SELECT * FROM exchange_requests;
```

---

## Troubleshooting

**"Cannot find db.properties"**  
Copy the template and fill in your password:
```bash
cp WEB-INF/db.properties.example WEB-INF/db.properties
# Then edit db.properties and set db.password=YOUR_PASSWORD
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
