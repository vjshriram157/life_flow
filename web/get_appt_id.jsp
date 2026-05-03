<%@ page import="com.bloodbank.util.FirebaseConfig,com.google.cloud.firestore.*,java.util.List" %>
<%
    try {
        Firestore db = FirebaseConfig.getFirestore();
        QuerySnapshot qs = db.collection("appointments").whereEqualTo("status", "COMPLETED").limit(1).get().get();
        if(!qs.isEmpty()) {
            out.println(qs.getDocuments().get(0).getId());
        } else {
            out.println("NO_COMPLETED_APPT");
        }
    } catch (Exception e) {
        out.println("ERROR: " + e.getMessage());
    }
%>
