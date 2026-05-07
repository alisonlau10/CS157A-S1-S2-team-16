package com.skillswap;

import java.io.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class SendExchangeRequestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String skillIdParam = request.getParameter("skillId");

        if (skillIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/search");
            return;
        }

        int requestedSkillId = Integer.parseInt(skillIdParam);

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            stmt = conn.prepareStatement(
                "SELECT sk.Skill_ID, sk.Title, sk.Description, sk.Experience_Level, " +
                "u.Full_Name, u.User_ID AS Owner_ID " +
                "FROM Skills sk " +
                "JOIN Users u ON sk.User_ID = u.User_ID " +
                "WHERE sk.Skill_ID = ? AND sk.Status = 'Active'"
            );
            stmt.setInt(1, requestedSkillId);
            rs = stmt.executeQuery();

            if (!rs.next()) {
                response.sendRedirect(request.getContextPath() + "/search");
                return;
            }

            int ownerId = rs.getInt("Owner_ID");
            if (ownerId == userId) {
                response.sendRedirect(request.getContextPath() + "/search");
                return;
            }

            request.setAttribute("requestedSkillId",    rs.getString("Skill_ID"));
            request.setAttribute("requestedSkillTitle", rs.getString("Title"));
            request.setAttribute("requestedSkillDesc",  rs.getString("Description"));
            request.setAttribute("requestedSkillLevel", rs.getString("Experience_Level"));
            request.setAttribute("skillOwnerName",      rs.getString("Full_Name"));
            request.setAttribute("receiverId",          String.valueOf(ownerId));
            rs.close();
            stmt.close();

            stmt = conn.prepareStatement(
                "SELECT Skill_ID, Title FROM Skills WHERE User_ID = ? AND Status = 'Active'"
            );
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            List<String[]> mySkills = new ArrayList<>();
            while (rs.next()) {
                mySkills.add(new String[]{rs.getString("Skill_ID"), rs.getString("Title")});
            }
            request.setAttribute("mySkills", mySkills);

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }

        request.getRequestDispatcher("/src/sendExchangeRequest.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int senderId         = (Integer) session.getAttribute("userId");
        int receiverId       = Integer.parseInt(request.getParameter("receiverId"));
        int requestedSkillId = Integer.parseInt(request.getParameter("requestedSkillId"));
        int offeredSkillId   = Integer.parseInt(request.getParameter("offeredSkillId"));
        String preferredDate = request.getParameter("preferredDate");
        String preferredTime = request.getParameter("preferredTime");

        // Server-side: reject past dates
        if (preferredDate != null && !preferredDate.isEmpty()) {
            try {
                LocalDate chosen = LocalDate.parse(preferredDate);
                if (chosen.isBefore(LocalDate.now())) {
                    response.sendRedirect(request.getContextPath()
                        + "/sendExchangeRequest?skillId=" + requestedSkillId + "&error=past");
                    return;
                }
            } catch (Exception ignored) {}
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();

            stmt = conn.prepareStatement(
                "INSERT INTO Exchange_Requests " +
                "(Status, Preferred_Date, Preferred_Time, Sender_ID, Receiver_ID, " +
                " Requested_Skill_ID, Offered_Skill_ID) " +
                "VALUES ('Pending', ?, ?, ?, ?, ?, ?)"
            );
            stmt.setString(1, (preferredDate != null && !preferredDate.isEmpty()) ? preferredDate : null);
            stmt.setString(2, (preferredTime != null && !preferredTime.isEmpty()) ? preferredTime : null);
            stmt.setInt(3, senderId);
            stmt.setInt(4, receiverId);
            stmt.setInt(5, requestedSkillId);
            stmt.setInt(6, offeredSkillId);
            stmt.executeUpdate();

        } catch (Exception e) {
            throw new ServletException("Error sending exchange request", e);
        } finally {
            DatabaseUtil.close(conn, stmt);
        }

        response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");
    }
}
