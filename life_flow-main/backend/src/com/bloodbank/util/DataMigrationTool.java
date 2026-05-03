package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class DataMigrationTool {

    public static void main(String[] args) {
        System.out.println("Starting SQL to Firestore Migration...");

        try (Connection conn = DBConnectionUtil.getConnection()) {
            Firestore db = FirebaseConfig.getFirestore();

            migrateUsers(conn, db);
            migrateBloodBanks(conn, db);
            migrateBloodStock(conn, db);
            migrateAppointments(conn, db);
            migrateEmergencyAlerts(conn, db);
            migratePasswordResets(conn, db);

            System.out.println("Migration Completed Successfully!");
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Migration Failed.");
            System.exit(1);
        }
    }

    private static void migrateUsers(Connection conn, Firestore db) throws SQLException, Exception {
        System.out.println("Migrating Users...");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM users");
        ResultSet rs = ps.executeQuery();
        int count = 0;
        while (rs.next()) {
            String docId = String.valueOf(rs.getLong("id"));
            Map<String, Object> data = new HashMap<>();
            data.put("full_name", rs.getString("full_name"));
            data.put("email", rs.getString("email"));
            data.put("phone", rs.getString("phone"));
            data.put("password_hash", rs.getString("password_hash"));
            data.put("blood_group", rs.getString("blood_group"));
            data.put("city", rs.getString("city"));
            data.put("role", rs.getString("role"));
            data.put("status", rs.getString("status"));
            data.put("strikes", rs.getInt("strikes"));
            
            if (rs.getTimestamp("created_at") != null) {
                data.put("created_at", rs.getTimestamp("created_at").toString());
            }

            db.collection("users").document(docId).set(data).get();
            count++;
        }
        System.out.println("Migrated " + count + " users.");
    }

    private static void migrateBloodBanks(Connection conn, Firestore db) throws SQLException, Exception {
        System.out.println("Migrating Blood Banks...");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM blood_banks");
        ResultSet rs = ps.executeQuery();
        int count = 0;
        while (rs.next()) {
            String docId = String.valueOf(rs.getLong("id"));
            Map<String, Object> data = new HashMap<>();
            data.put("bank_name", rs.getString("bank_name"));
            data.put("email", rs.getString("email"));
            data.put("phone", rs.getString("phone"));
            data.put("city", rs.getString("city"));
            data.put("latitude", rs.getDouble("latitude"));
            data.put("longitude", rs.getDouble("longitude"));
            data.put("status", rs.getString("status"));
            
            if (rs.getTimestamp("created_at") != null) {
                data.put("created_at", rs.getTimestamp("created_at").toString());
            }

            db.collection("blood_banks").document(docId).set(data).get();
            count++;
        }
        System.out.println("Migrated " + count + " blood banks.");
    }

    private static void migrateBloodStock(Connection conn, Firestore db) throws SQLException, Exception {
        System.out.println("Migrating Blood Stock...");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM blood_stock");
        ResultSet rs = ps.executeQuery();
        int count = 0;
        while (rs.next()) {
            String docId = String.valueOf(rs.getLong("id"));
            Map<String, Object> data = new HashMap<>();
            data.put("blood_bank_id", String.valueOf(rs.getLong("blood_bank_id")));
            data.put("blood_group", rs.getString("blood_group"));
            data.put("units", rs.getLong("units"));
            
            if (rs.getTimestamp("last_updated") != null) {
                data.put("last_updated", rs.getTimestamp("last_updated").toString());
            }

            db.collection("blood_stock").document(docId).set(data).get();
            count++;
        }
        System.out.println("Migrated " + count + " blood stock records.");
    }

    private static void migrateAppointments(Connection conn, Firestore db) throws SQLException, Exception {
        System.out.println("Migrating Appointments...");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM appointments");
        ResultSet rs = ps.executeQuery();
        int count = 0;
        while (rs.next()) {
            String docId = String.valueOf(rs.getLong("id"));
            Map<String, Object> data = new HashMap<>();
            data.put("donor_id", String.valueOf(rs.getLong("donor_id")));
            data.put("bank_id", String.valueOf(rs.getLong("bank_id")));
            data.put("status", rs.getString("status"));
            
            if (rs.getTimestamp("appointment_time") != null) {
                // Must be "yyyy-MM-dd HH:mm:ss" approximately for java.time.LocalDateTime in our code
                data.put("appointment_time", rs.getTimestamp("appointment_time")
                        .toLocalDateTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            }

            if (rs.getTimestamp("created_at") != null) {
                data.put("created_at", rs.getTimestamp("created_at").toString());
            }

            db.collection("appointments").document(docId).set(data).get();
            count++;
        }
        System.out.println("Migrated " + count + " appointments.");
    }



    private static void migrateEmergencyAlerts(Connection conn, Firestore db) throws SQLException, Exception {
        System.out.println("Migrating Emergency Alerts...");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM emergency_alerts");
        ResultSet rs = ps.executeQuery();
        int count = 0;
        while (rs.next()) {
            String docId = String.valueOf(rs.getLong("id"));
            Map<String, Object> data = new HashMap<>();
            data.put("bank_id", String.valueOf(rs.getLong("bank_id")));
            data.put("blood_group", rs.getString("blood_group"));
            data.put("radius_km", rs.getDouble("radius_km"));
            data.put("message", rs.getString("message"));

            if (rs.getTimestamp("created_at") != null) {
                data.put("created_at", rs.getTimestamp("created_at").toString());
            }

            db.collection("emergency_alerts").document(docId).set(data).get();
            count++;
        }
        System.out.println("Migrated " + count + " emergency alerts.");
    }

    private static void migratePasswordResets(Connection conn, Firestore db) throws SQLException, Exception {
        System.out.println("Migrating Password Resets...");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM password_resets");
        ResultSet rs = ps.executeQuery();
        int count = 0;
        while (rs.next()) {
            String docId = String.valueOf(rs.getLong("id"));
            Map<String, Object> data = new HashMap<>();
            data.put("user_id", String.valueOf(rs.getLong("user_id")));
            data.put("token", rs.getString("token"));
            
            if (rs.getTimestamp("created_at") != null) {
                data.put("created_at", rs.getTimestamp("created_at").toString());
            }

            db.collection("password_resets").document(docId).set(data).get();
            count++;
        }
        System.out.println("Migrated " + count + " password resets.");
    }
}
