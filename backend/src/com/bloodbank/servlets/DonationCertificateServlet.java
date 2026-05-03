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

@WebServlet(name = "DonationCertificateServlet", urlPatterns = {"/certificate"})
public class DonationCertificateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        String userId = (String) session.getAttribute("userId");

        String appointmentId = request.getParameter("appointmentId");
        if (appointmentId == null || appointmentId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing appointmentId");
            return;
        }

        String donorName = null;
        String bloodGroup = null;
        String bankName = null;
        String city = null;
        String completedOn = null;

        try {
            Firestore db = FirebaseConfig.getFirestore();
            
            DocumentSnapshot apptDoc = db.collection("appointments").document(appointmentId).get().get();
            if (!apptDoc.exists() || !userId.equals(apptDoc.getString("donor_id")) || !"COMPLETED".equals(apptDoc.getString("status"))) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No completed donation found for this appointment.");
                return;
            }
            
            completedOn = apptDoc.getString("appointment_time");
            String bankId = apptDoc.getString("bank_id");
            
            DocumentSnapshot donorDoc = db.collection("users").document(userId).get().get();
            if (donorDoc.exists()) {
                donorName = donorDoc.getString("full_name");
                bloodGroup = donorDoc.getString("blood_group");
            }
            
            if (bankId != null) {
                DocumentSnapshot bankDoc = db.collection("blood_banks").document(bankId).get().get();
                if (bankDoc.exists()) {
                    bankName = bankDoc.getString("bank_name");
                    city = bankDoc.getString("city");
                }
            }

        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
            return;
        }

        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String ctx = request.getContextPath();
            String qrUrl = ctx + "/certificate-qr?appointmentId=" + appointmentId;

            out.println("<!DOCTYPE html>");
            out.println("<html lang='en'><head><meta charset='UTF-8'><title>Hero's Recognition | LifeFlow</title>");
            out.println("<link href='https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&family=Playfair+Display:wght@700&family=Dancing+Script:wght@700&display=swap' rel='stylesheet'>");
            out.println("<style>");
            out.println(":root { --gold: #d4af37; --crimson: #e11d48; --slate: #0f172a; }");
            out.println("body { font-family: 'Outfit', sans-serif; background: #020617; margin: 0; padding: 40px; display: flex; justify-content: center; align-items: center; min-height: 90vh; }");
            out.println(".cert-container { position: relative; width: 100%; max-width: 850px; background: white; padding: 60px; border-radius: 4px; box-shadow: 0 40px 100px rgba(0,0,0,0.5); overflow: hidden; border: 12px double var(--gold); }");
            out.println(".cert-container::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 10px; background: linear-gradient(90deg, var(--gold), #fef3c7, var(--gold)); }");
            out.println(".header { text-align: center; margin-bottom: 40px; }");
            out.println(".header img { width: 60px; margin-bottom: 15px; }");
            out.println(".header h2 { font-family: 'Playfair Display', serif; color: var(--slate); font-size: 2.8rem; margin: 0; font-weight: 700; text-transform: uppercase; letter-spacing: 2px; }");
            out.println(".header p { color: var(--crimson); font-weight: 600; letter-spacing: 4px; font-size: 0.9rem; margin-top: 10px; }");
            out.println(".content { text-align: center; color: var(--slate); line-height: 1.6; }");
            out.println(".recipient-label { font-size: 1.1rem; color: #64748b; margin-bottom: 20px; }");
            out.println(".recipient-name { font-family: 'Playfair Display', serif; font-size: 3.5rem; color: var(--slate); border-bottom: 2px solid #e2e8f0; display: inline-block; padding: 0 40px; margin-bottom: 30px; }");
            out.println(".desc { font-size: 1.15rem; max-width: 600px; margin: 0 auto 40px; }");
            out.println(".footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; border-top: 1px solid #f1f5f9; padding-top: 40px; }");
            out.println(".signature { text-align: left; }");
            out.println(".sig-name { font-family: 'Dancing Script', cursive; font-size: 2.2rem; color: var(--slate); margin-bottom: 4px; line-height: 1; }");
            out.println(".sig-line { width: 200px; border-bottom: 1px solid var(--slate); margin-bottom: 8px; }");
            out.println(".sig-label { font-size: 0.8rem; color: #64748b; font-weight: 600; text-transform: uppercase; }");
            out.println(".qr-box { position: relative; }");
            out.println(".qr-box img { width: 120px; height: 120px; padding: 8px; background: white; border: 1px solid #e2e8f0; }");
            out.println(".seal { position: absolute; bottom: 150px; right: 60px; width: 120px; height: 120px; background: var(--gold); border-radius: 50%; display: flex; justify-content: center; align-items: center; color: white; flex-direction: column; opacity: 0.9; transform: rotate(-15deg); box-shadow: 0 10px 20px rgba(212,175,55,0.3); border: 2px dashed rgba(255,255,255,0.5); }");
            out.println(".seal span { font-size: 0.6rem; font-weight: 800; text-transform: uppercase; }");
            out.println(".seal i { font-size: 1.5rem; margin: 4px 0; }");
            out.println("</style>");
            out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'>");
            out.println("</head><body>");
            out.println("<div class='cert-container'>");
            out.println("  <div class='seal'>");
            out.println("    <span>Verified</span>");
            out.println("    <i class='fa-solid fa-award'></i>");
            out.println("    <span>Official Hero</span>");
            out.println("  </div>");
            out.println("  <div class='header'>");
            out.println("    <h2 style='color: #b91c1c;'>LIFELOW</h2>");
            out.println("    <p>CERTIFICATE OF RECOGNITION</p>");
            out.println("  </div>");
            out.println("  <div class='content'>");
            out.println("    <div class='recipient-label'>This high honor is presented to</div>");
            out.println("    <div class='recipient-name'>" + escape(donorName) + "</div>");
            out.println("    <div class='desc'>");
            out.println("      In grateful recognition of the life-saving <strong>Blood Donation (" + escape(bloodGroup) + ")</strong><br>");
            out.println("      made at <strong>" + escape(bankName) + "</strong> in " + escape(city) + ".<br>");
            out.println("      Your selfless contribution on " + completedOn + " has helped sustain life and bring hope to those in need.");
            out.println("    </div>");
            out.println("  </div>");
            out.println("  <div class='footer'>");
            out.println("    <div class='signature'>");
            out.println("      <div class='sig-name'>Dr. A. Sharma</div>");
            out.println("      <div class='sig-line'></div>");
            out.println("      <div class='sig-label'>Medical Director, LifeFlow</div>");
            out.println("      <div style='font-size: 0.75rem; color: #94a3b8; margin-top: 15px;'>ID: " + appointmentId + "</div>");
            out.println("    </div>");
            out.println("    <div class='qr-box'>");
            out.println("      <img src='" + qrUrl + "' alt='Verification QR'>");
            out.println("    </div>");
            out.println("  </div>");
            out.println("</div>");

            // Social Action Bar
            out.println("<div class='action-bar'>");
            out.println("  <button onclick='downloadCert()' class='action-btn' title='Download Certificate'><i class='fa-solid fa-download'></i></button>");
            out.println("  <button onclick='shareLinkedIn()' class='action-btn linkedin' title='Share on LinkedIn'><i class='fa-brands fa-linkedin-in'></i></button>");
            out.println("  <button onclick='shareWhatsApp()' class='action-btn whatsapp' title='Share on WhatsApp'><i class='fa-brands fa-whatsapp'></i></button>");
            out.println("</div>");

            out.println("<style>");
            out.println(".action-bar { position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%); display: flex; gap: 15px; background: rgba(15, 23, 42, 0.8); backdrop-filter: blur(10px); padding: 12px 25px; border-radius: 50px; border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 20px 40px rgba(0,0,0,0.4); z-index: 1000; }");
            out.println(".action-btn { width: 50px; height: 50px; border-radius: 50%; border: none; background: rgba(255,255,255,0.1); color: white; cursor: pointer; transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; }");
            out.println(".action-btn:hover { transform: scale(1.15) translateY(-5px); background: var(--crimson); box-shadow: 0 10px 20px rgba(225, 29, 72, 0.4); }");
            out.println(".action-btn.linkedin:hover { background: #0077b5; box-shadow: 0 10px 20px rgba(0, 119, 181, 0.4); }");
            out.println(".action-btn.whatsapp:hover { background: #25d366; box-shadow: 0 10px 20px rgba(37, 211, 102, 0.4); }");
            out.println("@media print { .action-bar { display: none; } body { background: white; padding: 0; } .cert-container { box-shadow: none; border: 6px double var(--gold); } }");
            out.println("</style>");

            out.println("<script src='https://html2canvas.hertzen.com/dist/html2canvas.min.js'></script>");
            out.println("<script>");
            out.println("function downloadCert() {");
            out.println("  const container = document.querySelector('.cert-container');");
            out.println("  html2canvas(container, { scale: 2 }).then(canvas => {");
            out.println("    const link = document.createElement('a');");
            out.println("    link.download = 'LifeFlow_Hero_Certificate_" + appointmentId + ".png';");
            out.println("    link.href = canvas.toDataURL('image/png');");
            out.println("    link.click();");
            out.println("  });");
            out.println("}");
            out.println("function shareLinkedIn() {");
            out.println("  const url = encodeURIComponent(window.location.href);");
            out.println("  const text = encodeURIComponent('Proud to share that I just donated blood through LifeFlow! Saving lives, one unit at a time. #LifeFlow #BloodDonor #Hero');");
            out.println("  window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${url}`, '_blank');");
            out.println("}");
            out.println("function shareWhatsApp() {");
            out.println("  const text = encodeURIComponent('I just donated blood at " + escape(bankName) + "! You can also save lives by joining LifeFlow: ' + window.location.origin);");
            out.println("  window.open(`https://api.whatsapp.com/send?text=${text}`, '_blank');");
            out.println("}");
            out.println("</script>");

            out.println("</body></html>");
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}

