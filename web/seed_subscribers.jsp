<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,java.util.*" %>
<%
    try {
        Firestore db = FirebaseConfig.getFirestore();
        String[] emails = {
            "vj.shriram157@gmail.com",
            "vijayshriram718@gmail.com",
            "vj.shriram1574@gmail.com",
            "bshankar0705@gmail.com"
        };

        int count = 0;
        for (String email : emails) {
            QuerySnapshot qs = db.collection("subscribers").whereEqualTo("email", email).get().get();
            if (qs.isEmpty()) {
                Map<String, Object> sub = new HashMap<>();
                sub.put("email", email);
                sub.put("status", "ACTIVE");
                sub.put("subscribed_at", "2024-04-23 12:00:00");
                db.collection("subscribers").add(sub).get();
                count++;
            }
        }
        out.println("<h3>Seeding Subscribers Complete</h3>");
        out.println("<p>Successfully added " + count + " active subscribers.</p>");
    } catch (Exception e) {
        out.println("<h3>Error</h3><pre>" + e.getMessage() + "</pre>");
    }
%>
