package com.bloodbank.util;

import com.bloodbank.models.BlogModel;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.DocumentSnapshot;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class BlogService {

    public static List<BlogModel> getAllPosts() {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            List<QueryDocumentSnapshot> docs = db.collection("blog_posts").get().get().getDocuments();
            
            if (docs.isEmpty()) {
                seedInitialPosts(db);
                docs = db.collection("blog_posts").get().get().getDocuments();
            }

            List<BlogModel> result = new ArrayList<>();
            for (QueryDocumentSnapshot doc : docs) {
                result.add(new BlogModel(
                    doc.getId(),
                    doc.getString("title"),
                    doc.getString("category"),
                    doc.getString("date"),
                    doc.getString("author"),
                    doc.getString("preview"),
                    doc.getString("content"),
                    doc.getString("imageUrl"),
                    "" // Reverting icon logic for blog
                ));
            }
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static BlogModel getPostById(String id) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            DocumentSnapshot doc = db.collection("blog_posts").document(id).get().get();
            if (doc.exists()) {
                return new BlogModel(
                    doc.getId(),
                    doc.getString("title"),
                    doc.getString("category"),
                    doc.getString("date"),
                    doc.getString("author"),
                    doc.getString("preview"),
                    doc.getString("content"),
                    doc.getString("imageUrl"),
                    "" // Reverting icon logic for blog
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static void seedInitialPosts(Firestore db) {
        try {
            BlogModel[] initial = new BlogModel[] {
                new BlogModel("1", "The Lifesaving Power of Platelet Donation", "IMPACT", "Oct 12, 2026", "LifeFlow Editorial", "While whole blood donations are what most people think of, platelets play an essential role for cancer patients undergoing chemotherapy. Learn why we need more active platelet donors immediately.", "Platelets are tiny cells in your blood that form clots and stop bleeding. For patients undergoing chemotherapy, surgery, or those with serious injuries, platelet transfusions are often a life-saving necessity. Unlike whole blood, platelets have a very short shelf life—only five days. This means we need a constant, steady stream of donors to meet the demand. When you donate platelets, your red cells and plasma are returned to you, and you can actually donate more frequently than whole blood. Join us in this critical mission to ensure no patient has to wait for this vital resource.", "https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80", ""),
                new BlogModel("2", "Future of Transfusions: LifeFlow's Smart Locator", "TECHNOLOGY", "Oct 05, 2026", "Tech Team", "How LifeFlow's AI-driven distribution system is reducing waste and saving thousands of critical minutes in emergency medical transit.", "The traditional blood supply chain has long been plagued by inefficiencies and data siloes. At LifeFlow, we've implemented an AI-driven smart locator system that monitors inventory levels across the entire national grid in real-time. By predicting demand spikes and identifying the most efficient transport routes, we're not just moving blood—we're saving time that translates directly into lives saved. Our latest update includes localized geospatial tracking, ensuring that emergency clinics can see exactly where their Nearest compatible unit is located, down to the city block.", "https://images.unsplash.com/photo-1631549916768-4119b2e5f926?auto=format&fit=crop&q=80", ""),
                new BlogModel("3", "Superfoods for Donors: The Science of Recovery", "NUTRITION", "Sep 28, 2026", "Health & Wellness", "Maintaining a stable blood supply is a global challenge. What you eat before and after donation directly impacts your body's ability to recover and replenish.", "<h4 class='text-white mb-3'>1. The Science of Recovery</h4><p class='text-secondary'>When you donate blood, your body works immediately to replace the lost fluids and cells. For most donors, this process is seamless, but it can be enhanced through specific nutritional choices. Increasing your intake of iron, folate, and Vitamin B12 in the 48 hours following a donation is crucial.</p><h4 class='text-white mb-3'>2. Iron-Rich Superfoods</h4><p class='text-secondary'>Spinach, lentils, and fortified cereals are excellent plant-based sources of iron. For non-vegetarians, lean meats and seafood provide heme iron, which is absorbed more efficiently by the body. Pairing these with Vitamin C-rich foods like oranges or bell peppers further boosts absorption.</p>", "https://images.unsplash.com/photo-1542884748-2b87b36c6b90?auto=format&fit=crop&q=80", ""),
                new BlogModel("4", "5 Iron-Rich Foods to Boost Donation Readiness", "NUTRITION", "Oct 20, 2026", "Healthy Living", "Low hemoglobin is the #1 reason for deferred donations. These 5 foods can help you stay eligible and healthy.", "<h4 class='text-white mb-3'>The Hemoglobin Factor</h4><p class='text-secondary'>Hemoglobin is the protein in your red blood cells that carries oxygen. To produce it, your body needs iron. If your iron levels are low, you may be deferred from donating blood. Here are five foods to boost your levels:</p><ul class='text-secondary'><li><strong>Leafy Greens:</strong> Spinach and kale are packed with non-heme iron.</li><li><strong>Red Meat & Poultry:</strong> Providing easily absorbed heme iron.</li><li><strong>Lentils & Beans:</strong> A powerhouse of plant-based protein and iron.</li><li><strong>Pumpkin Seeds:</strong> A perfect snack for iron and zinc.</li><li><strong>Dark Chocolate:</strong> Yes, in moderation, it's a great source of iron and antioxidants!</li></ul>", "https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&q=80", ""),
                new BlogModel("5", "The Ultimate Post-Donation Recovery Plate", "HEALTH", "Oct 23, 2026", "Nutritionist's Desk", "What you eat after donating is just as important as what you eat before. Learn how to refuel like a pro.", "<h4 class='text-white mb-3'>The 4-Step Recovery Plan</h4><p class='text-secondary'>After donating, your body needs to replenish fluids and energy. Follow this simple guide:</p><p class='text-secondary'><strong>1. Hydration is Key:</strong> Drink plenty of water or fruit juices. Avoid caffeine for at least 6 hours.</p><p class='text-secondary'><strong>2. Savory Snacks:</strong> Salty snacks like pretzels can help replace the sodium lost during donation.</p><p class='text-secondary'><strong>3. Vitamin C Boost:</strong> Citrus fruits, strawberries, and kiwis help your body absorb iron from your next meal.</p><p class='text-secondary'><strong>4. Complex Carbs:</strong> Whole-grain bread or oats provide sustained energy to prevent that post-donation 'slump'.</p>", "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&q=80", "")
            };
            
            for (BlogModel post : initial) {
                Map<String, Object> data = new HashMap<>();
                data.put("title", post.getTitle());
                data.put("category", post.getCategory());
                data.put("date", post.getDate());
                data.put("author", post.getAuthor());
                data.put("preview", post.getPreview());
                data.put("content", post.getContent());
                data.put("imageUrl", post.getImageUrl());
                data.put("icon", "");
                
                db.collection("blog_posts").document(post.getId()).set(data).get();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
