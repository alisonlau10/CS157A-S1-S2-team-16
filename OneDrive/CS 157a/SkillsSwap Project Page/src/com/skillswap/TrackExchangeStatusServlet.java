package com.skillswap;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class TrackExchangeStatusServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("src/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        ArrayList<String[]> exchangeList = new ArrayList<>();

        String sql = "SELECT er.Request_ID, " +
                "rs.Title AS Requested_Skill, " +
                "os.Title AS Offered_Skill, " +
                "CASE WHEN er.Sender_ID = ? THEN u2.Full_Name ELSE u1.Full_Name END AS Other_Student, " +
                "er.Preferred_Date, er.Preferred_Time, er.Status " +
                "FROM Exchange_Requests er " +
                "JOIN Skills rs ON er.Requested_Skill_ID = rs.Skill_ID " +
                "JOIN Skills os ON er.Offered_Skill_ID = os.Skill_ID " +
                "JOIN Users u1 ON er.Sender_ID = u1.User_ID " +
                "JOIN Users u2 ON er.Receiver_ID = u2.User_ID " +
                "WHERE er.Sender_ID = ? OR er.Receiver_ID = ? " +
                "ORDER BY er.Created_At DESC";

        try {
            Connection conn = DatabaseUtil.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql);

            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                String[] row = new String[7];
                row[0] = rs.getString("Request_ID");
                row[1] = rs.getString("Requested_Skill");
                row[2] = rs.getString("Offered_Skill");
                row[3] = rs.getString("Other_Student");
                row[4] = rs.getString("Preferred_Date");
                row[5] = rs.getString("Preferred_Time");
                row[6] = rs.getString("Status");
                exchangeList.add(row);
            }

            rs.close();
            stmt.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading exchange data.");
        }

        request.setAttribute("exchangeList", exchangeList);
        request.getRequestDispatcher("src/trackExchangeStatus.jsp").forward(request, response);
    }
}