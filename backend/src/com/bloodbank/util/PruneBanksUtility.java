package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import java.util.List;

public class PruneBanksUtility {
    public static void main(String[] args) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            if (db == null) {
                System.err.println("Firestore not initialized.");
                return;
            }

            QuerySnapshot snapshot = db.collection("blood_banks").get().get();
            List<QueryDocumentSnapshot> documents = snapshot.getDocuments();
            int total = documents.size();
            System.out.println("Current Total Banks: " + total);

            if (total > 15) {
                int toDelete = total - 15;
                System.out.println("Pruning " + toDelete + " excess banks...");
                
                int deletedCount = 0;
                for (QueryDocumentSnapshot doc : documents) {
                    String id = doc.getId();
                    // Don't delete the primary ones we just seeded
                    if (id.equals("central_india_blood_bank") || 
                        id.equals("delhi_red_cross") || 
                        id.equals("mumbai_life_care")) {
                        continue;
                    }

                    db.collection("blood_banks").document(id).delete().get();
                    deletedCount++;
                    
                    if (deletedCount >= toDelete) break;
                }
                System.out.println("Pruning complete. Deleted " + deletedCount + " banks.");
            } else {
                System.out.println("Database is already lean (<= 15 banks). No pruning needed.");
            }

            System.exit(0);
        } catch (Exception e) {
            // Handle Quota error gracefully if pruning fails too
            if (e.getMessage().contains("RESOURCE_EXHAUSTED")) {
                System.err.println("Cannot prune right now: Firestore Quota is completely exhausted.");
            } else {
                e.printStackTrace();
            }
            System.exit(1);
        }
    }
}
