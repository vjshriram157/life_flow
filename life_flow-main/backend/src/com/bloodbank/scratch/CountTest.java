package com.bloodbank.scratch;

import com.bloodbank.util.FirebaseConfig;
import com.bloodbank.util.PasswordUtil;
import com.google.cloud.firestore.Firestore;
import java.util.HashMap;
import java.util.Map;

public class CountTest {
    public static void main(String[] args) throws Exception {
        Firestore db = FirebaseConfig.getFirestore();
        Map<String, Object> userData = new HashMap<>();
        userData.put("full_name", "System Admin");
        userData.put("email", "admin@lifeflow.com");
        userData.put("password_hash", PasswordUtil.hashPassword("admin123"));
        userData.put("role", "ADMIN");
        userData.put("status", "APPROVED");
        db.collection("users").document("admin@lifeflow.com").set(userData).get();
        System.out.println("Admin created: admin@lifeflow.com / admin123");
        System.exit(0);
    }
}
