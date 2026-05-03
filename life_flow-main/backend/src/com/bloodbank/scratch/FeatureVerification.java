package com.bloodbank.scratch;

import com.bloodbank.util.AchievementUtil;

public class FeatureVerification {

    public static void main(String[] args) {
        System.out.println("=== 🏆 GAMIFICATION LOGIC TEST ===");
        testGamification();
        
        System.out.println("\n=== 🧠 FORECASTING LOGIC TEST ===");
        testForecasting();
        
        System.out.println("\n=== ✅ VERIFICATION COMPLETE ===");
    }

    private static void testGamification() {
        int[] testDonations = {0, 1, 3, 5, 12, 30};
        for (int count : testDonations) {
            // Simulated logic from AchievementUtil (since we can't easily mock Firestore here)
            String rank = "Recruit";
            int badges = 0;
            if (count >= 1) { rank = "Bronze Donor"; badges = 1; }
            if (count >= 5) { rank = "Silver Donor"; badges = 2; }
            if (count >= 10) { rank = "Gold Donor"; badges = 3; }
            if (count >= 25) { rank = "Platinum Hero"; badges = 4; }
            
            System.out.printf("Donations: %d | Rank: %s | Badges Earned: %d\n", count, rank, badges);
        }
    }

    private static void testForecasting() {
        // Simulated logic from AdminDemandPredictionServlet
        double avgMonthlyDemand = 10.0;
        long[] testStocks = {0, 2, 5, 20};
        
        for (long stock : testStocks) {
            double daysOfCover = (avgMonthlyDemand > 0) ? (stock / (avgMonthlyDemand / 30.0)) : 365.0;
            int prob = (int) Math.min(100, Math.max(0, (30 - daysOfCover) * 3.33));
            String status = daysOfCover < 7 ? "CRITICAL" : (daysOfCover < 14 ? "WARNING" : "STABLE");
            
            System.out.printf("Stock: %d | Days of Cover: %.1f | Risk: %d%% | Status: %s\n", 
                               stock, daysOfCover, prob, status);
        }
    }
}
