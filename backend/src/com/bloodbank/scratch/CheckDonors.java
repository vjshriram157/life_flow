package com.bloodbank.scratch;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import java.util.List;

public class CheckDonors {
    public static void main(String[] args) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            if (db == null) {
                System.out.println("Firestore initialization failed.");
                return;
            }
            System.out.println("Checking Firestore for donors with donation_count...");
            
            QuerySnapshot donors = db.collection("users")
                .whereEqualTo("role", "DONOR")
                .get().get();
                
            List<QueryDocumentSnapshot> docs = donors.getDocuments();
            System.out.println("Found " + docs.size() + " donors.");
            
            for (QueryDocumentSnapshot doc : docs) {
                Object count = doc.get("donation_count");
                System.out.println("Donor: " + doc.getString("full_name") + " | email: " + doc.getString("email") + " | count: " + count);
            }
            
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
