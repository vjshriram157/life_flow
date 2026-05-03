package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet({"/ExportReportServlet", "/ExportReport"})
public class ExportReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"LifeFlow_System_Report.csv\"");

        try (PrintWriter out = response.getWriter()) {
            // CSV Headers
            out.println("ID,Full Name,Role,Email,Phone,Blood Group,Status,City");

            try {
                Firestore db = FirebaseConfig.getFirestore();
                QuerySnapshot usersSnapshot = db.collection("users").get().get();
                List<QueryDocumentSnapshot> users = usersSnapshot.getDocuments();

                for (QueryDocumentSnapshot user : users) {
                    String id = escapeCSV(user.getId());
                    String name = escapeCSV(user.getString("full_name"));
                    String role = escapeCSV(user.getString("role"));
                    String email = escapeCSV(user.getString("email"));
                    String phone = escapeCSV(user.getString("phone"));
                    String bg = escapeCSV(user.getString("blood_group"));
                    String status = escapeCSV(user.getString("status"));
                    String city = escapeCSV(user.getString("city"));
                    
                    out.println(id + "," + name + "," + role + "," + email + "," + phone + "," + bg + "," + status + "," + city);
                }

            } catch (Exception fe) {
                out.println("ERROR,DATA FETCH ERROR: QUOTA EXCEEDED,The Firestore daily free tier limit has been reached.,,,,,");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating report");
        }
    }

    private String escapeCSV(String data) {
        if (data == null) return "";
        data = data.replace("\"", "\"\""); // Escape quotes
        if (data.contains(",") || data.contains("\"") || data.contains("\n")) {
            return "\"" + data + "\""; // Enclose in quotes if contains comma, quote, or newline
        }
        return data;
    }
}
