#!/bin/bash
# SkillSwap Campus — first-time setup for teammates
# Usage: bash setup.sh
# Tested on macOS with MySQL 8/9 and Apache Tomcat 9.0.115

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Locate Tomcat ──────────────────────────────────────────────────────────
echo ""
echo "=== SkillSwap Campus Setup ==="
echo ""

read -rp "Enter full path to your Tomcat directory (e.g. /Users/you/Desktop/apache-tomcat-9.0.115): " TOMCAT_DIR
TOMCAT_DIR="${TOMCAT_DIR%/}"   # strip trailing slash

if [ ! -f "$TOMCAT_DIR/lib/servlet-api.jar" ]; then
  echo "ERROR: servlet-api.jar not found in $TOMCAT_DIR/lib/"
  echo "Make sure you entered the correct Tomcat path."
  exit 1
fi

# ── 2. MySQL credentials ──────────────────────────────────────────────────────
read -rp "Enter your MySQL root password: " -s MYSQL_PASS
echo ""

MYSQL_BIN=$(which mysql 2>/dev/null || find /usr/local/mysql*/bin -name mysql 2>/dev/null | head -1)
if [ -z "$MYSQL_BIN" ]; then
  echo "ERROR: mysql binary not found. Install MySQL first."
  exit 1
fi

echo "==> Testing MySQL connection..."
if ! "$MYSQL_BIN" -u root -p"$MYSQL_PASS" -e "SELECT 1;" > /dev/null 2>&1; then
  echo "ERROR: Cannot connect to MySQL with that password."
  exit 1
fi
echo "    Connected OK."

# ── 3. Create db.properties ───────────────────────────────────────────────────
echo "==> Writing WEB-INF/db.properties..."
cat > "$PROJECT_DIR/WEB-INF/db.properties" <<EOF
db.url=jdbc:mysql://localhost:3306/skillswap_campus?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.user=root
db.password=${MYSQL_PASS}
EOF
echo "    Done."

# ── 4. Import database ────────────────────────────────────────────────────────
echo "==> Importing skillswap_campus database..."
"$MYSQL_BIN" -u root -p"$MYSQL_PASS" < "$PROJECT_DIR/skillswap_campus.sql"
echo "    Imported."

# ── 5. Compile servlets ───────────────────────────────────────────────────────
echo "==> Compiling servlets..."
mkdir -p "$PROJECT_DIR/WEB-INF/classes"
javac \
  -cp "$TOMCAT_DIR/lib/servlet-api.jar:$TOMCAT_DIR/lib/mysql-connector-j-9.6.0.jar" \
  -d "$PROJECT_DIR/WEB-INF/classes" \
  "$PROJECT_DIR/src/com/skillswap/"*.java
echo "    Compiled OK."

# ── 6. Create Tomcat context file ─────────────────────────────────────────────
echo "==> Registering app with Tomcat..."
CONTEXT_DIR="$TOMCAT_DIR/conf/Catalina/localhost"
mkdir -p "$CONTEXT_DIR"
cat > "$CONTEXT_DIR/skillswap.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="${PROJECT_DIR}" path="/skillswap" reloadable="true" />
EOF
echo "    Context file created."

# ── 7. Start Tomcat ───────────────────────────────────────────────────────────
echo "==> Starting Tomcat..."
"$TOMCAT_DIR/bin/startup.sh"
sleep 3

echo ""
echo "============================================"
echo " Setup complete!"
echo ""
echo " Open in browser:"
echo " http://localhost:8080/skillswap/src/register.jsp"
echo " http://localhost:8080/skillswap/src/login.jsp"
echo "============================================"
echo ""
