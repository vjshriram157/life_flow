package com.bloodbank.util;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class DeleteUsers {
    public static void main(String[] args) {
        try (Connection conn = DBConnectionUtil.getConnection()) {
            System.out.println("Attempting to delete specific test users and their appointments...");
            String findSql = "SELECT id, full_name FROM users WHERE full_name LIKE ? OR full_name LIKE ? OR full_name LIKE ? OR full_name LIKE ?";
            PreparedStatement psFind = conn.prepareStatement(findSql);
            psFind.setString(1, "%vijay sh%");
            psFind.setString(2, "%vijay%");
            psFind.setString(3, "%kumar%");
            psFind.setString(4, "%shankar%");
            
            java.sql.ResultSet rs = psFind.executeQuery();
            int deletedCount = 0;
            
            PreparedStatement psDelAppt = conn.prepareStatement("DELETE FROM appointments WHERE donor_id = ?");
            PreparedStatement psDelUser = conn.prepareStatement("DELETE FROM users WHERE id = ?");
            
            while (rs.next()) {
                long userId = rs.getLong("id");
                String name = rs.getString("full_name");
                
                // Delete appointments
                psDelAppt.setLong(1, userId);
                psDelAppt.executeUpdate();
                
                // Delete user
                psDelUser.setLong(1, userId);
                int count = psDelUser.executeUpdate();
                deletedCount += count;
                System.out.println("Deleted user: " + name);
            }
            
            System.out.println("✅ Successfully deleted " + deletedCount + " test users matching the requested names.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
