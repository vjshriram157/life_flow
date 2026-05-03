package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.QuerySnapshot;

import java.util.HashMap;
import java.util.Map;
import java.util.List;

public class AdminUserSeeder {
    public static void main(String[] args) {
        System.out.println("Generating authentication profiles for all Blood Banks...");
        try {
            Firestore db = FirebaseConfig.getFirestore();
            String passwordHash = PasswordUtil.hashPassword("test123");

            ApiFuture<QuerySnapshot> future = db.collection("blood_banks").get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();

            int authAccountsCreated = 0;

            for (QueryDocumentSnapshot document : documents) {
                String bankName = document.getString("bank_name");
                String city = document.getString("city");
                
                // create a safe email from bankName
                String cleanName = bankName.replaceAll("[^a-zA-Z0-9]", "").toLowerCase();
                String email = "admin@" + cleanName + ".com";

                // Update blood bank with email
                document.getReference().update("email", email).get();

                // Check if user already exists
                ApiFuture<QuerySnapshot> userFuture = db.collection("users").whereEqualTo("email", email).get();
                if (userFuture.get().isEmpty()) {
                    Map<String, Object> userData = new HashMap<>();
                    userData.put("full_name", bankName);
                    userData.put("email", email);
                    userData.put("phone", document.getString("contact_number"));
                    userData.put("password_hash", passwordHash);
                    userData.put("role", "BANK");
                    userData.put("status", "APPROVED"); // Need to be approved to login
                    userData.put("city", city);

                    db.collection("users").add(userData).get();
                    System.out.println("Created Login -> Email: " + email + "  |  Password: test123");
                    authAccountsCreated++;
                } else {
                    System.out.println("Login already exists for: " + email);
                }
            }
            
            System.out.println("Done! Successfully provisioned " + authAccountsCreated + " secure authentication profiles.");
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
