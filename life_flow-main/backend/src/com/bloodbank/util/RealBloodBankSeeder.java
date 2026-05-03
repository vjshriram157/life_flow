package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.WriteBatch;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

public class RealBloodBankSeeder {
    public static void main(String[] args) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            if (db == null) {
                System.err.println("Firestore not initialized.");
                return;
            }

            System.out.println("🧹 Cleaning up existing bank data...");
            // Cleanup existing banks and bank users to ensure fresh start
            cleanup(db, "blood_banks");
            cleanupUsers(db);
            cleanup(db, "blood_stock");
            cleanup(db, "appointments");


            String passwordHash = PasswordUtil.hashPassword("test123");
            String now = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

            // exactly 15 Indian Banks
            String[][] userBanks = {
                {"Indian Red Cross Society NHQ", "admin@indianredcrosssocietynhq.com", "+91 8000000005", "Delhi", "28.6139", "77.2090"},
                {"Jeevan Blood Bank", "admin@jeevanbloodbank.com", "+91 8000000011", "Chennai", "13.0827", "80.2707"},
                {"Lions Blood Bank", "admin@lionsbloodbank.com", "+91 8000000006", "Bangalore", "12.9716", "77.5946"},
                {"Andhra Pride Blood Bank", "admin@apbloodbank.com", "0866-222333", "Amaravati", "16.5131", "80.5182"},
                {"Assam Unity Blood Bank", "admin@assambloodbank.com", "0361-223344", "Guwahati", "26.1445", "91.7362"},
                {"Bihar Sahyog Bank", "admin@biharbloodbank.com", "0612-221133", "Patna", "25.5941", "85.1376"},
                {"Gujarat Shanti Bank", "admin@gujaratbloodbank.com", "079-221166", "Ahmedabad", "23.0225", "72.5714"},
                {"Haryana Veer Bank", "admin@haryanabloodbank.com", "0172-221177", "Chandigarh", "30.7333", "76.7794"},
                {"Kerala Karunya Bank", "admin@keralabloodbank.com", "0471-221111", "Trivandrum", "8.5241", "76.9366"},
                {"MP Narmada Blood Bank", "admin@mpbloodbank.com", "0755-221122", "Bhopal", "23.2599", "77.4126"},
                {"Maharashtra Sahyadri Bank", "admin@maharashtrabloodbank.com", "020-221133", "Pune", "18.5204", "73.8567"},
                {"Odisha Kalinga Bank", "admin@odishabloodbank.com", "0674-221188", "Bhubaneswar", "20.2961", "85.8245"},
                {"Punjab Five Rivers Bank", "admin@punjabbloodbank.com", "0183-221199", "Amritsar", "31.6340", "74.8723"},
                {"Rajasthan Desert Rose", "admin@rajasthanbloodbank.com", "0141-221100", "Jaipur", "26.9124", "75.7873"},
                {"UP Ganga Bank", "admin@upbloodbank.com", "0522-221155", "Lucknow", "26.8467", "80.9462"}
            };

            seed(db, userBanks, passwordHash, now, "APPROVED");

            System.out.println("🚀 Minimal Seeding Complete!");
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void seed(Firestore db, String[][] data, String pwd, String date, String type) throws Exception {
        for (String[] bank : data) {
            String name = bank[0];
            String email = bank[1];
            String phone = bank[2];
            String city = bank[3];
            double lat = Double.parseDouble(bank[4]);
            double lng = Double.parseDouble(bank[5]);

            // 1. Create Blood Bank Entry
            Map<String, Object> bbData = new HashMap<>();
            bbData.put("bank_name", name);
            bbData.put("email", email);
            bbData.put("phone", phone);
            bbData.put("city", city);
            bbData.put("latitude", lat);
            bbData.put("longitude", lng);
            bbData.put("status", "APPROVED");
            bbData.put("type", type);

            db.collection("blood_banks").document(email).set(bbData).get();

            // 2. Create User Login Entry
            Map<String, Object> userData = new HashMap<>();
            userData.put("full_name", name);
            userData.put("email", email);
            userData.put("phone", phone);
            userData.put("password_hash", pwd);
            userData.put("role", "BANK");
            userData.put("status", "APPROVED");
            userData.put("city", city);
            userData.put("created_at", date);
            userData.put("donation_count", 0);

            db.collection("users").document(email).set(userData).get();
            System.out.println("✅ Seeded Bank & User: " + name + " (" + email + ")");
        }
    }

    private static void cleanup(Firestore db, String collection) throws Exception {
        List<QueryDocumentSnapshot> docs = db.collection(collection).get().get().getDocuments();
        WriteBatch batch = db.batch();
        for (QueryDocumentSnapshot doc : docs) {
            batch.delete(doc.getReference());
        }
        batch.commit().get();
    }

    private static void cleanupUsers(Firestore db) throws Exception {
        // Only cleanup BANK users to avoid deleting admins or donors
        List<QueryDocumentSnapshot> docs = db.collection("users").whereEqualTo("role", "BANK").get().get().getDocuments();
        WriteBatch batch = db.batch();
        for (QueryDocumentSnapshot doc : docs) {
            batch.delete(doc.getReference());
        }
        batch.commit().get();
    }
}

