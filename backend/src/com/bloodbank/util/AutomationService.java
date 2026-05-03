package com.bloodbank.util;

import com.google.cloud.firestore.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class AutomationService {
    
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * Triggered when a donation is completed.
     * Handles: Achievement Milestones, Critical Stock Alerts, and Replenishment Scheduling.
     */
    public static void processDonationImpact(String donorId, String bankId, String bloodGroup) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // 1. Milestone Check & Last Donation Update
            DocumentSnapshot donorDoc = db.collection("users").document(donorId).get().get();
            if (donorDoc.exists()) {
                long count = donorDoc.getLong("donation_count");
                String name = donorDoc.getString("full_name");
                String email = donorDoc.getString("email");
                
                checkAndNotifyMilestone(email, name, count);

                // 🎯 OPTIMIZATION: Update last_donation_date for faster future filtering
                db.collection("users").document(donorId).update("last_donation_date", LocalDateTime.now().format(formatter)).get();
            }

            // 2. Critical Stock Alert (Smart Guard)
            // If stock for this group is now low relative to predicted demand
            checkCriticalStockAlert(db, bankId, bloodGroup);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void checkAndNotifyMilestone(String email, String name, long count) {
        String rank = null;
        if (count == 1) rank = "Bronze Hero";
        else if (count == 5) rank = "Silver Life Saver";
        else if (count == 10) rank = "Golden Guardian";
        else if (count == 25) rank = "LifeFlow Legend";

        if (rank != null) {
            List<String> recipients = Collections.singletonList(email);
            String message = "Congratulations " + name + "! You've just reached the '" + rank + "' milestone with " + count + " life-saving donations. Your dedication is inspiring!";
            EmailService.sendWeeklyNewsletter(recipients, message); // Reusing newsletter logic for blast
        }
    }

    private static void checkCriticalStockAlert(Firestore db, String bankId, String bloodGroup) {
        try {
            // Simple threshold-based automation: if stock < 5 units, trigger alert
            DocumentSnapshot stockDoc = db.collection("blood_stock")
                .document(bankId + "_" + bloodGroup).get().get();
            
            if (stockDoc.exists()) {
                long units = stockDoc.getLong("units");
                if (units < 5) {
                    DocumentSnapshot bankDoc = db.collection("blood_banks").document(bankId).get().get();
                    String bankName = bankDoc.getString("bank_name");
                    String city = bankDoc.getString("city");
                    
                    // Auto-trigger city-wide newsletter alert
                    NewsletterService.triggerPersonalizedAlert(bloodGroup, city, bankName);
                }
            }
        } catch (Exception ignored) {}
    }

    private static long lastMaintenanceTime = 0;
    private static final long MAINTENANCE_INTERVAL_MS = 12 * 60 * 60 * 1000; // 12 hours

    /**
     * Cleans up appointments older than 24 hours that were never completed.
     */
    public static void runSystemMaintenance() {
        // 🎯 OPTIMIZATION: 12-hour cooldown lock to prevent read quota exhaustion
        if (System.currentTimeMillis() - lastMaintenanceTime < MAINTENANCE_INTERVAL_MS) {
            return;
        }
        lastMaintenanceTime = System.currentTimeMillis();
        
        try {
            Firestore db = FirebaseConfig.getFirestore();
            LocalDateTime cutoff = LocalDateTime.now().minusHours(24);
            
            QuerySnapshot pendingAppts = db.collection("appointments")
                .whereEqualTo("status", "PENDING")
                .get().get();

            WriteBatch batch = db.batch();
            int count = 0;

            for (QueryDocumentSnapshot doc : pendingAppts.getDocuments()) {
                String timeStr = doc.getString("appointment_time");
                if (timeStr != null) {
                    try {
                        LocalDateTime apptTime = LocalDateTime.parse(timeStr, formatter);
                        if (apptTime.isBefore(cutoff)) {
                            batch.delete(doc.getReference());
                            count++;
                        }
                    } catch (Exception ignored) {}
                }
            }

            if (count > 0) {
                batch.commit().get();
                System.out.println("🤖 AUTOMATION: Purged " + count + " stale appointments.");
            }
            
            // Trigger replenishment invites for donors who donated 90 days ago
            processReplenishmentInvites(db);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void processReplenishmentInvites(Firestore db) {
        try {
            LocalDateTime targetDate = LocalDateTime.now().minusDays(90);
            String datePrefix = targetDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            
            // Find completion events from exactly 90 days ago
            QuerySnapshot recentCompletions = db.collection("appointments")
                .whereEqualTo("status", "COMPLETED")
                .get().get();

            for (QueryDocumentSnapshot doc : recentCompletions.getDocuments()) {
                String time = doc.getString("appointment_time");
                if (time != null && time.startsWith(datePrefix)) {
                    String donorId = doc.getString("donor_id");
                    DocumentSnapshot donor = db.collection("users").document(donorId).get().get();
                    if (donor.exists()) {
                        String email = donor.getString("email");
                        String name = donor.getString("full_name");
                        EmailService.sendWeeklyNewsletter(Collections.singletonList(email), 
                            "Hi " + name + "! It's been 90 days since your last donation. You are now eligible to save lives again! Book your next appointment today.");
                    }
                }
            }
        } catch (Exception ignored) {}
    }
}
