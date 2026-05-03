package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.QuerySnapshot;
import java.util.List;

public class ListUsers {
    public static void main(String[] args) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            ApiFuture<QuerySnapshot> future = db.collection("users").get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            for (QueryDocumentSnapshot document : documents) {
                System.out.println("Email: " + document.getString("email") + " | Role: " + document.getString("role"));
            }
            System.exit(0);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
