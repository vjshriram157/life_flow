package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import java.util.ArrayList;
import java.util.List;

/**
 * Logic for calculating donor achievements and gamification stats.
 */
public class AchievementUtil {

    public static class DonorStats {
        public int totalDonations;
        public String rank;
        public List<String> badges = new ArrayList<>();
        public int livesSaved;
    }

    public static DonorStats getStats(String userId) {
        DonorStats stats = new DonorStats();
        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            // Count completed appointments
            QuerySnapshot apptSnapshot = db.collection("appointments")
                .whereEqualTo("donor_id", userId)
                .whereEqualTo("status", "COMPLETED")
                .get().get();
                
            stats.totalDonations = apptSnapshot.size();
            stats.livesSaved = stats.totalDonations * 3; // Standard calculation: 1 donation saves up to 3 lives

            // Hierarchy and Badges
            if (stats.totalDonations >= 1) {
                stats.badges.add("First Hero");
                stats.rank = "Bronze Donor";
            }
            if (stats.totalDonations >= 5) {
                stats.badges.add("Silver Life Saver");
                stats.rank = "Silver Donor";
            }
            if (stats.totalDonations >= 10) {
                stats.badges.add("Golden Guardian");
                stats.rank = "Gold Donor";
            }
            if (stats.totalDonations >= 25) {
                stats.badges.add("LifeFlow Legend");
                stats.rank = "Platinum Hero";
            }

            if (stats.totalDonations == 0) {
                stats.rank = "Recruit";
            }

        } catch (Exception e) {
            e.printStackTrace();
            stats.rank = "Unknown";
        }
        return stats;
    }
}
