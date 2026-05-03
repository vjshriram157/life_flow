package com.bloodbank.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        System.out.println("=== Database Connection Test ===");
        String url = "jdbc:mysql://localhost:3306/blood_bank_db?useSSL=false&serverTimezone=UTC";
        String user = "root";
        String pass = "Mukesh@18";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Driver loaded.");
            
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                System.out.println("Connection successful!");
                
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT count(*) FROM blood_banks");
                if (rs.next()) {
                    System.out.println("Blood banks count: " + rs.getInt(1));
                }
                
                // List all tables
                rs = stmt.executeQuery("SHOW TABLES");
                System.out.println("Tables in database:");
                while(rs.next()) {
                    System.out.println("- " + rs.getString(1));
                }
                
            }
        } catch (Exception e) {
            System.err.println("CONNECTION FAILED.");
            e.printStackTrace();
        }
        System.out.println("================================");
    }
}
