package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "DonorIdServlet", urlPatterns = {"/donor-id"})
public class DonorIdServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        String userId = (String) session.getAttribute("userId");

        String donorName = "Hero";
        String bloodGroup = "??";
        long donations = 0;
        String rank = "Citizen";
        String rankColor = "#64748b";

        try {
            Firestore db = FirebaseConfig.getFirestore();
            DocumentSnapshot donorDoc = db.collection("users").document(userId).get().get();
            
            if (donorDoc.exists()) {
                donorName = donorDoc.getString("full_name");
                bloodGroup = donorDoc.getString("blood_group");
                donations = donorDoc.getLong("donation_count");
                
                // Determine Rank
                if (donations >= 25) { rank = "LifeFlow Legend"; rankColor = "#e5e4e2"; }
                else if (donations >= 10) { rank = "Golden Guardian"; rankColor = "#ffd700"; }
                else if (donations >= 5) { rank = "Silver Warden"; rankColor = "#c0c0c0"; }
                else if (donations >= 1) { rank = "Bronze Hero"; rankColor = "#cd7f32"; }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        boolean isAjax = "true".equalsIgnoreCase(request.getParameter("ajax"));
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String ctx = request.getContextPath();
            
            if (!isAjax) {
                out.println("<!DOCTYPE html>");
                out.println("<html><head><meta charset='UTF-8'><title>Digital Hero ID | LifeFlow</title>");
                out.println("<link href='https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap' rel='stylesheet'>");
                out.println("<style>");
                out.println("body { font-family: 'Outfit', sans-serif; background: #020617; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }");
                out.println(".id-card { width: 450px; height: 280px; background: linear-gradient(135deg, #1e1b4b 0%, #4c0519 100%); border-radius: 20px; position: relative; padding: 25px; box-shadow: 0 50px 100px rgba(0,0,0,0.8); overflow: hidden; border: 1px solid rgba(255,255,255,0.1); }");
                out.println(".id-card::before { content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%; background: radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%); pointer-events: none; }");
                out.println(".header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 30px; }");
                out.println(".logo { color: white; font-weight: 800; font-size: 1.2rem; letter-spacing: 2px; }");
                out.println(".chip { width: 40px; height: 30px; background: linear-gradient(135deg, #ffd700, #b8860b); border-radius: 6px; }");
                out.println(".main { display: flex; gap: 20px; align-items: center; }");
                out.println(".blood-seal { width: 70px; height: 70px; background: rgba(225,29,72,0.2); border: 2px solid #e11d48; border-radius: 50%; display: flex; justify-content: center; align-items: center; color: #e11d48; font-weight: 800; font-size: 1.5rem; text-shadow: 0 0 10px rgba(225,29,72,0.5); }");
                out.println(".info-box { color: white; }");
                out.println(".name { font-size: 1.4rem; font-weight: 700; text-transform: uppercase; margin: 0; }");
                out.println(".rank { font-size: 0.8rem; color: " + rankColor + "; font-weight: 600; text-transform: uppercase; letter-spacing: 1.5px; margin-top: 4px; }");
                out.println(".stats { display: flex; gap: 20px; margin-top: 25px; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 15px; }");
                out.println(".stat-item { text-align: left; }");
                out.println(".stat-val { color: white; font-weight: 700; font-size: 1rem; }");
                out.println(".stat-lbl { color: rgba(255,255,255,0.5); font-size: 0.6rem; text-transform: uppercase; font-weight: 600; }");
                out.println(".footer { position: absolute; bottom: 20px; right: 25px; color: rgba(255,255,255,0.3); font-size: 0.6rem; text-transform: uppercase; letter-spacing: 1px; }");
                out.println("</style></head><body>");
            }
            out.println("<div class='id-card'>");
            out.println("  <div class='header'><div class='logo'>LIFELOW HERO</div><div class='chip'></div></div>");
            out.println("  <div class='main'>");
            out.println("    <div class='blood-seal'>" + bloodGroup + "</div>");
            out.println("    <div class='info-box'>");
            out.println("      <div class='name'>" + donorName + "</div>");
            out.println("      <div class='rank'>" + rank + "</div>");
            out.println("    </div>");
            out.println("  </div>");
            out.println("  <div class='stats'>");
            out.println("    <div class='stat-item'><div class='stat-val'>" + donations + "</div><div class='stat-lbl'>Lifes Saved</div></div>");
            out.println("    <div class='stat-item'><div class='stat-val'>NETWORK</div><div class='stat-lbl'>Membership</div></div>");
            out.println("    <div class='stat-item'><div class='stat-val'>" + userId.substring(0, 8).toUpperCase() + "</div><div class='stat-lbl'>Hero ID</div></div>");
            out.println("  </div>");
            out.println("  <div class='footer'>Valid Globally | LifeFlow Blood Network</div>");
            out.println("</div>");
            if (!isAjax) {
                out.println("</body></html>");
            }
        }
    }
}
