package com.bloodbank.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.ResultSet;

public class DBSeeder {
    public static void main(String[] args) {
        System.out.println("Starting Database Seeder...");
        try {
            try (Connection conn = com.bloodbank.util.DBConnectionUtil.getConnection();
                 Statement stmt = conn.createStatement()) {

                // 1. Create emergency_alerts table
                stmt.execute("CREATE TABLE IF NOT EXISTS emergency_alerts (" +
                             "id INT AUTO_INCREMENT PRIMARY KEY, " +
                             "bank_id INT, " +
                             "blood_group VARCHAR(5), " +
                             "radius_km INT, " +
                             "message TEXT, " +
                             "status VARCHAR(20) DEFAULT 'ACTIVE', " +
                             "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
                System.out.println("-> Created/Verified emergency_alerts table.");

                // Obtain a valid bank ID to link the records to
                ResultSet bankRs = stmt.executeQuery("SELECT id FROM blood_banks LIMIT 1");
                int bankId = 1;
                if (bankRs.next()) {
                   bankId = bankRs.getInt("id");
                }
                bankRs.close();

                // 2. Add active emergency alert
                stmt.executeUpdate("INSERT INTO emergency_alerts (bank_id, blood_group, radius_km, message) " +
                                   "VALUES (" + bankId + ", 'O-', 10, 'Critical shortage of O- blood. Please donate immediately!')");
                System.out.println("-> Added dummy emergency active alert.");

                // 3. Obtain a valid user ID or insert a dummy user
                ResultSet userRs = stmt.executeQuery("SELECT id FROM users WHERE role='DONOR' LIMIT 1");
                int userId = 1;
                if (userRs.next()) {
                    userId = userRs.getInt("id");
                } else {
                    stmt.executeUpdate("INSERT INTO users (full_name, email, password_hash, role, status, blood_group) VALUES ('Dummy Donor', 'dummy88@donor.com', 'pwd', 'DONOR', 'APPROVED', 'O+')");
                    userRs = stmt.executeQuery("SELECT id FROM users WHERE email='dummy88@donor.com'");
                    if(userRs.next()) userId = userRs.getInt(1);
                }
                userRs.close();

                // 4. Generate 30 historical completed appointments across months to populate the Chart
                for (int i = 0; i < 30; i++) {
                    int month = (int)(Math.random() * 12) + 1;
                    int year = 2025 + (int)(Math.random() * 2); // 2025 or 2026
                    String date = year + "-" + String.format("%02d", month) + "-15 10:00:00";
                    stmt.executeUpdate("INSERT INTO appointments (donor_id, bank_id, appointment_time, status) " +
                                       "VALUES ("+userId+", "+bankId+", '"+date+"', 'COMPLETED')");
                }
                System.out.println("-> Inserted 30 historical donation records for Analytics Chart.");

                // 5. Create a blood stock deficit so the Leaflet Demand Heatmap lights up.
                stmt.executeUpdate("UPDATE blood_stock SET units = 1 WHERE blood_bank_id = " + bankId);
                
                System.out.println("Database Seeding Completed Successfully.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
