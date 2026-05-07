package com.skillswap;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class SearchSkillsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword        = request.getParameter("keyword");
        String categoryIdParam = request.getParameter("categoryId");

        List<String[]> results    = new ArrayList<>();
        List<String[]> categories = loadCategories();

        boolean hasKeyword   = keyword != null && !keyword.trim().isEmpty();
        boolean hasCategory  = categoryIdParam != null && !categoryIdParam.trim().isEmpty()
                               && !categoryIdParam.equals("0");
        int categoryId = hasCategory ? Integer.parseInt(categoryIdParam) : 0;

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();

            StringBuilder sql = new StringBuilder(
                "SELECT sk.Skill_ID, sk.Title, sk.Description, sk.Experience_Level, " +
                "sc.Category_Name, u.Full_Name, u.User_ID " +
                "FROM Skills sk " +
                "JOIN Users u  ON sk.User_ID    = u.User_ID " +
                "JOIN Skill_Categories sc ON sk.Category_ID = sc.Category_ID " +
                "WHERE sk.Status = 'Active' "
            );

            if (hasKeyword)  sql.append("AND (sk.Title LIKE ? OR sk.Description LIKE ?) ");
            if (hasCategory) sql.append("AND sk.Category_ID = ? ");
            sql.append("ORDER BY sk.Title ASC");

            stmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (hasKeyword) {
                String kw = "%" + keyword.trim() + "%";
                stmt.setString(idx++, kw);
                stmt.setString(idx++, kw);
            }
            if (hasCategory) {
                stmt.setInt(idx++, categoryId);
            }

            rs = stmt.executeQuery();
            while (rs.next()) {
                results.add(new String[]{
                    rs.getString("Skill_ID"),
                    rs.getString("Title"),
                    rs.getString("Description"),
                    rs.getString("Experience_Level"),
                    rs.getString("Category_Name"),
                    rs.getString("Full_Name"),
                    rs.getString("User_ID")
                });
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error searching skills: " + e.getMessage());
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }

        request.setAttribute("results",    results);
        request.setAttribute("categories", categories);
        request.setAttribute("keyword",    keyword);
        request.setAttribute("categoryId", categoryIdParam);
        request.getRequestDispatcher("/src/searchSkills.jsp").forward(request, response);
    }

    private List<String[]> loadCategories() {
        List<String[]> cats = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseUtil.getConnection();
            stmt = conn.prepareStatement(
                "SELECT Category_ID, Category_Name FROM Skill_Categories ORDER BY Category_Name");
            rs = stmt.executeQuery();
            while (rs.next()) {
                cats.add(new String[]{rs.getString("Category_ID"), rs.getString("Category_Name")});
            }
        } catch (Exception ignored) {
        } finally {
            DatabaseUtil.close(conn, stmt, rs);
        }
        return cats;
    }
}
