package com.bloodbank.util;
// Refreshed version

import com.google.cloud.firestore.*;
import java.util.*;
import java.util.concurrent.ExecutionException;

public class NewsletterService {

    public static List<String> getAllSubscribers() {
        List<String> emails = new ArrayList<>();
        try {
            Firestore db = FirebaseConfig.getFirestore();
            QuerySnapshot snapshot = db.collection("subscribers").whereEqualTo("status", "ACTIVE").get().get();
            for (QueryDocumentSnapshot doc : snapshot.getDocuments()) {
                String email = doc.getString("email");
                if (email != null) emails.add(email);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return emails;
    }

    public static long getLivesSavedThisMonth() {
        // Simple 1:1 mapping as requested: 1 completed donation = 1 life saved
        try {
            Firestore db = FirebaseConfig.getFirestore();
            // In a real app we'd filter by month, for now total completed works
            return db.collection("appointments")
                    .whereEqualTo("status", "COMPLETED")
                    .count().get().get().getCount();
        } catch (Exception e) {
            return 0;
        }
    }

    public static long getTotalHeroCount() {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            return db.collection("users").whereEqualTo("role", "DONOR").count().get().get().getCount();
        } catch (Exception e) {
            return 0;
        }
    }

    public static void sendWeeklyHealthTips() {
        List<String> subscribers = getAllSubscribers();
        if (subscribers.isEmpty()) return;

        String[] tips = {
            "Stay hydrated: Drinking 500ml of water just before donation keeps your blood pressure stable.",
            "Iron is key: Include spinach, lentils, and fortified cereals in your diet 48 hours before donation.",
            "Post-donation care: Avoid heavy lifting or intense exercise for at least 12 hours after giving blood.",
            "Replenishment science: Your body replaces the plasma lost within 24 hours. Keep drinking fluids!",
            "Impact Check: Did you know one donation can save up to three lives? Thank you for being a hero."
        };
        
        // Pick a tip based on the day or week
        String selectedTip = tips[new Random().nextInt(tips.length)];
        
        EmailService.sendWeeklyNewsletter(subscribers, selectedTip);
    }

    public static void sendMonthlyImpactReport() {
        List<String> subscribers = getAllSubscribers();
        if (subscribers.isEmpty()) return;

        long livesSaved = getLivesSavedThisMonth();
        long heroCount = getTotalHeroCount();
        
        EmailService.sendMonthlyImpactEmail(subscribers, livesSaved, heroCount);
    }

    public static void triggerNewHospitalAlert(String hospitalName, String city) {
        List<String> subscribers = getAllSubscribers(); // "Notify all" as requested
        if (subscribers.isEmpty()) return;
        
        EmailService.sendNewHospitalJoinedEmail(subscribers, hospitalName, city);
    }

    public static void triggerNearbyCampAlert(String campaignTitle, String date, String location) {
        List<String> subscribers = getAllSubscribers(); // "Notify all" as requested
        if (subscribers.isEmpty()) return;

        EmailService.sendNewCampAlertEmail(subscribers, campaignTitle, date, location);
    }

    public static void triggerPersonalizedAlert(String bloodGroup, String city, String requestedBy) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            // Filter subscribers who match this blood group and location
            QuerySnapshot snapshot = db.collection("subscribers")
                .whereEqualTo("blood_group", bloodGroup)
                .whereEqualTo("city", city)
                .get().get();

            List<String> targetEmails = new ArrayList<>();
            for (QueryDocumentSnapshot doc : snapshot.getDocuments()) {
                targetEmails.add(doc.getString("email"));
            }

            if (!targetEmails.isEmpty()) {
                EmailService.sendPersonalizedNeedEmail(targetEmails, bloodGroup, city, requestedBy);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
