package com.bloodbank.util;

import com.google.cloud.firestore.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class MockDataSeeder {
    public static void main(String[] args) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            if (db == null) return;

            String[] bloodGroups = {"O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"};
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

            System.out.println("🧙 Creating Virtual Donors for all blood groups...");
            Map<String, String> donorMap = new HashMap<>();
            for (String bg : bloodGroups) {
                String email = "virtual_" + bg.replace("+", "p").replace("-", "n").toLowerCase() + "@lifeflow.org";
                Map<String, Object> donor = new HashMap<>();
                donor.put("full_name", "Virtual Donor " + bg);
                donor.put("email", email);
                donor.put("blood_group", bg);
                donor.put("role", "DONOR");
                donor.put("status", "APPROVED");
                donor.put("city", "System");
                donor.put("donation_count", 10);
                
                db.collection("users").document(email).set(donor).get();
                donorMap.put(bg, email);
            }

            System.out.println("📊 Populating Stock and Appointments for all banks...");
            List<QueryDocumentSnapshot> banks = db.collection("blood_banks").get().get().getDocuments();
            Random rand = new Random();

            for (QueryDocumentSnapshot bank : banks) {
                String bankId = bank.getId();
                String bankName = bank.getString("bank_name");

                // 1. Seed Stock
                for (String bg : bloodGroups) {
                    Map<String, Object> stock = new HashMap<>();
                    stock.put("blood_bank_id", bankId);
                    stock.put("blood_group", bg);
                    stock.put("units", rand.nextInt(15) + 2); // 2 to 17 units
                    stock.put("last_updated", LocalDateTime.now().format(formatter));
                    
                    db.collection("blood_stock").document(bankId + "_" + bg).set(stock).get();
                }

                // 2. Seed Mock History (Last 60 days)
                for (int i = 0; i < 15; i++) {
                    String bg = bloodGroups[rand.nextInt(bloodGroups.length)];
                    LocalDateTime time = LocalDateTime.now().minusDays(rand.nextInt(60)).minusHours(rand.nextInt(24));
                    
                    Map<String, Object> appt = new HashMap<>();
                    appt.put("bank_id", bankId);
                    appt.put("donor_id", donorMap.get(bg));
                    appt.put("blood_group", bg);
                    appt.put("appointment_time", time.format(formatter));
                    appt.put("status", "COMPLETED");
                    
                    db.collection("appointments").add(appt).get();
                }
                System.out.println("✅ Populated " + bankName);
            }

            System.out.println("✨ Simulation Complete! Your dashboard should now be full of data.");
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
