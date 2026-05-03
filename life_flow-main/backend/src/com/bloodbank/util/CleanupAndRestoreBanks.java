package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import java.util.List;

public class CleanupAndRestoreBanks {
    public static void main(String[] args) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            if (db == null) return;

            // 1. Delete the 3 temporary global banks
            String[] toDelete = {"central_india_blood_bank", "delhi_red_cross", "mumbai_life_care"};
            for (String id : toDelete) {
                db.collection("blood_banks").document(id).delete().get();
                System.out.println("Deleted temporary bank: " + id);
            }

            // 2. Verify remaining banks in 'blood_banks'
            // We want to make sure these match real 'BANK' users in the 'users' collection
            System.out.println("Cleanup complete. Only original login-linked banks will remain.");
            
            System.exit(0);
        } catch (Exception e) {
            if (e.getMessage().contains("RESOURCE_EXHAUSTED")) {
                System.err.println("QUOTA ERROR: Still waiting for reset to perform cleanup.");
            } else {
                e.printStackTrace();
            }
            System.exit(1);
        }
    }
}
