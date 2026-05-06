package com.skillswap;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class LeaveReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String requestIdParam = request.getParameter("requestId");

        if (requestIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");
            return;
        }

        int requestId = Integer.parseInt(requestIdParam);

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            // Fetch exchange info; only valid if Completed and current user is a participant
            stmt = conn.prepareStatement(
                "SELECT er.Request_ID, er.Sender_ID, er.Receiver_ID, " +
                "rs.Title AS Requested_Skill, os.Title AS Offered_Skill, " +
                "CASE WHEN er.Sender_ID = ? THEN u2.Full_Name ELSE u1.Full_Name END AS Other_Name, " +
                "CASE WHEN er.Sender_ID = ? THEN er.Receiver_ID  ELSE er.Sender_ID  END AS Reviewee_ID " +
                "FROM Exchange_Requests er " +
                "JOIN Skills rs ON er.Requested_Skill_ID = rs.Skill_ID " +
                "JOIN Skills os ON er.Offered_Skill_ID   = os.Skill_ID " +
                "JOIN Users u1  ON er.Sender_ID          = u1.User_ID " +
                "JOIN Users u2  ON er.Receiver_ID        = u2.User_ID " +
                "WHERE er.Request_ID = ? AND er.Status = 'Completed' " +
                "AND (er.Sender_ID = ? OR er.Receiver_ID = ?)"
            );
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, requestId);
            stmt.setInt(4, userId);
            stmt.setInt(5, userId);
            rs = stmt.executeQuery();

            if (!rs.next()) {
                response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");
                return;
            }

            int    revieweeId      = rs.getInt("Reviewee_ID");
            String otherName       = rs.getString("Other_Name");
            String requestedSkill  = rs.getString("Requested_Skill");
            String offeredSkill    = rs.getString("Offered_Skill");
            rs.close();
            stmt.close();

            // Check if this user already left a review for this exchange
            stmt = conn.prepareStatement(
                "SELECT Review_ID FROM Reviews WHERE Request_ID = ? AND Reviewer_ID = ?"
            );
            stmt.setInt(1, requestId);
            stmt.setInt(2, userId);
            rs = stmt.executeQuery();
            boolean alreadyReviewed = rs.next();

            request.setAttribute("requestId",       requestId);
            request.setAttribute("revieweeId",      revieweeId);
            request.setAttribute("otherName",       otherName);
            request.setAttribute("requestedSkill",  requestedSkill);
            request.setAttribute("offeredSkill",    offeredSkill);
            request.setAttribute("alreadyReviewed", alreadyReviewed);

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }

        request.getRequestDispatcher("/src/leaveReview.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/src/login.jsp");
            return;
        }

        int reviewerId  = (Integer) session.getAttribute("userId");
        int requestId   = Integer.parseInt(request.getParameter("requestId"));
        int revieweeId  = Integer.parseInt(request.getParameter("revieweeId"));
        int rating      = Integer.parseInt(request.getParameter("rating"));
        String comment  = request.getParameter("comment");

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseUtil.getConnection();

            stmt = conn.prepareStatement(
                "INSERT INTO Reviews (Rating, Comment, Request_ID, Reviewer_ID, Reviewee_ID) " +
                "VALUES (?, ?, ?, ?, ?)"
            );
            stmt.setInt(1, rating);
            stmt.setString(2, comment != null ? comment.trim() : "");
            stmt.setInt(3, requestId);
            stmt.setInt(4, reviewerId);
            stmt.setInt(5, revieweeId);
            stmt.executeUpdate();

        } catch (Exception e) {
            throw new ServletException("Error submitting review", e);
        } finally {
            DatabaseUtil.close(conn, stmt);
        }

        response.sendRedirect(request.getContextPath() + "/trackExchangeStatus");
    }
}
