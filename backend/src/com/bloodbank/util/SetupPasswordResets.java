package com.bloodbank.util;

import java.sql.Connection;
import java.sql.Statement;

public class SetupPasswordResets {
    public static void main(String[] args) {
        try (Connection conn = DBConnectionUtil.getConnection();
             Statement stmt = conn.createStatement()) {
             
            // 1. Ensure status column can hold UNVERIFIED state
            try {
                stmt.executeUpdate("ALTER TABLE users MODIFY COLUMN status VARCHAR(50) DEFAULT 'PENDING'");
                System.out.println("✅ Altered users status to VARCHAR.");
            } catch (Exception e) {
                System.out.println("⚠️ Could not alter users status column: " + e.getMessage());
            }

            // 2. Create password_resets
            String sql = "CREATE TABLE IF NOT EXISTS password_resets (" +
                         "id INT AUTO_INCREMENT PRIMARY KEY, " +
                         "user_id INT NOT NULL, " +
                         "token VARCHAR(255) NOT NULL, " +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                         "FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)";
                         
            stmt.executeUpdate(sql);
            System.out.println("✅ Successfully created password_resets table.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
