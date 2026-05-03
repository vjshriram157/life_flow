package com.bloodbank.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailService {

    // ⚠️ IMPORTANT: You must replace these with your actual Gmail and App Password!
    // For Gmail, you must enable 2-Step Verification and generate an "App Password"
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static String USERNAME; 
    private static String PASSWORD;
    private static String FROM_NAME;

    static {
        try {
            java.util.Properties props = new java.util.Properties();
            java.io.InputStream propStream = EmailService.class.getClassLoader().getResourceAsStream("config.properties");
            if (propStream != null) {
                props.load(propStream);
            }
            USERNAME = props.getProperty("gmail.username", "lifeflowad@gmail.com");
            PASSWORD = props.getProperty("gmail.password", "jelmkdzvswkpszpt");
            FROM_NAME = props.getProperty("gmail.from.name", "LifeFlow Emergency Center");
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }
    }

    public static void sendOtpEmail(String toAddress, String otp) {
        System.out.println("Attempting to send real OTP email to: " + toAddress);
        System.out.println("=====================================================");
        System.out.println("🔑 [LOCAL FALLBACK] GENERATED OTP FOR " + toAddress + ": " + otp);
        System.out.println("=====================================================");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
            message.setSubject("LifeFlow - Your Password Reset OTP");
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>"
                    + "<h2 style='color: #e11d48;'>LifeFlow Password Reset</h2>"
                    + "<p>You recently requested to reset your password. Use the following OTP to complete the process:</p>"
                    + "<h1 style='background: #f1f5f9; padding: 15px; border-radius: 8px; letter-spacing: 5px; text-align: center; color: #0f172a;'>" + otp + "</h1>"
                    + "<p style='font-size: 0.9em; color: #666;'>If you did not make this request, please ignore this email.</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Real OTP email sent successfully to " + toAddress);
        } catch (Exception e) {
            System.err.println("❌ Failed to send email: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void sendEmergencyBroadcastEmail(java.util.List<String> bccEmails, String bloodGroup, String facilityName, String emergencyMessage) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        
        System.out.println("Attempting to send EMERGENCY email broadcast to " + bccEmails.size() + " donors.");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            
            // Set all donors as BCC to protect their privacy
            InternetAddress[] bccAddresses = new InternetAddress[bccEmails.size()];
            for (int i = 0; i < bccEmails.size(); i++) {
                bccAddresses[i] = new InternetAddress(bccEmails.get(i));
            }
            message.setRecipients(Message.RecipientType.BCC, bccAddresses);
            
            // So the 'To' field isn't completely blank, set it to the system email
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(USERNAME));
            
            message.setSubject("🚨 URGENT: " + bloodGroup + " Blood Needed Immediately at " + facilityName);
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #e11d48; border-radius: 8px;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h1 style='color: #e11d48; margin: 0;'>CRITICAL DEMAND</h1>"
                    + "  <p style='color: #666; font-size: 1.2em; margin-top: 5px;'>Your community needs you.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em;'>Dear Donor,</p>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>A medical emergency has resulted in a critical shortage of <strong>" + bloodGroup + "</strong> blood. Because you are uniquely positioned to help, we are contacting you immediately.</p>"
                    + "<div style='background: #fee2e2; border-left: 4px solid #ef4444; padding: 15px; margin: 25px 0;'>"
                    + "  <p style='margin: 0; font-size: 1.1em; color: #7f1d1d;'><strong>Facility:</strong> " + facilityName + "</p>"
                    + "  <p style='margin: 10px 0 0 0; font-size: 1.0em; color: #991b1b;'><em>\"" + (emergencyMessage != null ? emergencyMessage : "Urgent stock required to handle trauma/surgical event.") + "\"</em></p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>If you are healthy and able to donate, please proceed to the facility or open your LifeFlow App to book a fast-track appointment.</p>"
                    + "<div style='text-align: center; margin-top: 30px;'>"
                    + "  <a href='http://localhost:9090/blood-bank/login.jsp' style='background-color: #e11d48; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 1.1em;'>Respond to Request</a>"
                    + "</div>"
                    + "<p style='font-size: 0.8em; color: #999; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; text-align: center;'>This is an automated emergency broadcast generated by the LifeFlow Medical Grid.</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ EMERGENCY Email broadcast successfully sent to " + bccEmails.size() + " donors.");
        } catch (Exception e) {
            System.err.println("❌ Failed to broadcast emergency email.");
            e.printStackTrace();
        }
    }
    public static void sendLifeSavedEmail(String toEmail, String donorName, String bloodGroup) {
        System.out.println("Sending Life Saved celebration email to: " + toEmail);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            
            message.setSubject("LifeFlow: Your Donation Just Saved a Life! ❤️");
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #10b981; border-radius: 8px;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h1 style='color: #10b981; margin: 0;'>YOU ARE A HERO!</h1>"
                    + "  <p style='color: #666; font-size: 1.2em; margin-top: 5px;'>Impact achieved.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em;'>Dear " + donorName + ",</p>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>We have incredible news! Your blood donation (<strong>" + bloodGroup + "</strong>) has just been utilized at a medical facility to help a patient in need.</p>"
                    + "<div style='background: #ecfdf5; border-left: 4px solid #10b981; padding: 15px; margin: 25px 0;'>"
                    + "  <p style='margin: 0; font-size: 1.1em; color: #065f46;'><strong>Status:</strong> Life Saved</p>"
                    + "  <p style='margin: 10px 0 0 0; font-size: 1.0em; color: #047857;'>Your selfless contribution has made the ultimate difference today.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>You can view your updated impact statistics and download your official Hero Certificate in the LifeFlow dashboard.</p>"
                    + "<div style='text-align: center; margin-top: 30px;'>"
                    + "  <a href='http://localhost:9090/blood-bank/login.jsp' style='background-color: #10b981; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 1.1em;'>View Your Impact</a>"
                    + "</div>"
                    + "<p style='font-size: 0.8em; color: #999; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; text-align: center;'>Thank you for being part of the LifeFlow lifesaving network.</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Life Saved email sent successfully to " + toEmail);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendSupportEmail(String fromName, String fromEmail, String messageBody) {
        System.out.println("Attempting to send Support Inquiry from: " + fromEmail + " to Admin.");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, "LifeFlow Support Bot"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(USERNAME)); // Send to admin
            message.setReplyTo(new Address[]{new InternetAddress(fromEmail)});
            
            message.setSubject("LifeFlow Support Inquiry from " + fromName);
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 25px; color: #333; border: 1px solid #eee; border-radius: 8px;'>"
                    + "<h2 style='color: #e11d48; border-bottom: 2px solid #e11d48; padding-bottom: 10px;'>New Support Request</h2>"
                    + "<p><strong>From:</strong> " + fromName + " (" + fromEmail + ")</p>"
                    + "<div style='background: #f8fafc; padding: 15px; border-radius: 5px; margin-top: 20px; font-style: italic; color: #475569;'>"
                    + "\"" + messageBody + "\""
                    + "</div>"
                    + "<p style='margin-top: 25px; font-size: 0.85em; color: #94a3b8;'>LifeFlow Management System &bull; Support Route Active</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Support email sent successfully to admin.");
        } catch (Exception e) {
            System.err.println("❌ Failed to send support email: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void sendPeerRequestBroadcastEmail(java.util.List<String> bccEmails, String requesterName, String bloodGroup, String location, String urgency, String notes) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        
        System.out.println("Attempting to send Community Blood Request broadcast to " + bccEmails.size() + " matching donors.");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            
            InternetAddress[] bccAddresses = new InternetAddress[bccEmails.size()];
            for (int i = 0; i < bccEmails.size(); i++) {
                bccAddresses[i] = new InternetAddress(bccEmails.get(i));
            }
            message.setRecipients(Message.RecipientType.BCC, bccAddresses);
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(USERNAME));
            
            String subjectPrefix = "Emergency".equalsIgnoreCase(urgency) ? "🚨 URGENT: " : "📢 Alert: ";
            message.setSubject(subjectPrefix + bloodGroup + " Blood Requested by " + requesterName);
            
            String bannerColor = "Emergency".equalsIgnoreCase(urgency) ? "#e11d48" : "#2563eb";
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid " + bannerColor + "; border-radius: 8px;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h1 style='color: " + bannerColor + "; margin: 0;'>COMMUNITY BLOOD REQUEST</h1>"
                    + "  <p style='color: #666; font-size: 1.2em; margin-top: 5px;'>A fellow community member needs your blood type.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em;'>Dear Donor,</p>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>Because you are a registered <strong>" + bloodGroup + "</strong> donor, we are notifying you that <strong>" + requesterName + "</strong> has requested blood in your network.</p>"
                    + "<div style='background: #f8fafc; border-left: 4px solid " + bannerColor + "; padding: 15px; margin: 25px 0;'>"
                    + "  <p style='margin: 0; font-size: 1.1em; color: #334155;'><strong>Location:</strong> " + location + "</p>"
                    + "  <p style='margin: 10px 0 0 0; font-size: 1.0em; color: #475569;'><strong>Urgency:</strong> " + urgency + "</p>"
                    + "  <p style='margin: 10px 0 0 0; font-size: 1.0em; color: #475569;'><em>\"" + (notes != null && !notes.isEmpty() ? notes : "No additional notes provided.") + "\"</em></p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>If you are healthy and able to help, please login to your dashboard to respond to this request.</p>"
                    + "<div style='text-align: center; margin-top: 30px;'>"
                    + "  <a href='http://localhost:9090/blood-bank/login.jsp' style='background-color: " + bannerColor + "; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 1.1em;'>View Request</a>"
                    + "</div>"
                    + "<p style='font-size: 0.8em; color: #999; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; text-align: center;'>This is an automated community broadcast generated by LifeFlow.</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Community Broadcast successfully sent to " + bccEmails.size() + " matching donors.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ─────────────────────────────────────────────────────────────────
    //  NEW: Newsletter & Smart Trigger Templates
    // ─────────────────────────────────────────────────────────────────

    public static void sendWeeklyNewsletter(java.util.List<String> bccEmails, String healthTip) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        sendBroadcast(bccEmails, "\uD83D\uDCA1 LifeFlow Health Radar: This Week's Tip", 
            "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #e11d48; border-radius: 8px;'>" +
            "  <div style='text-align: center; margin-bottom: 24px;'>" +
            "    <h2 style='color: #e11d48; margin: 0;'>\uD83D\uDCA1 HEALTH RADAR</h2>" +
            "    <p style='color: #666;'>Empowering your life so you can save others.</p>" +
            "  </div>" +
            "  <div style='background: #f8fafc; padding: 25px; border-radius: 12px; margin: 20px 0; border: 1px solid #e2e8f0;'>" +
            "    <h3 style='margin-top: 0; color: #0f172a;'>Hero's Guide to Wellness</h3>" +
            "    <p style='font-size: 1.1em; line-height: 1.6; color: #334155;'>" + healthTip + "</p>" +
            "  </div>" +
            "  <p style='font-size: 0.95em; line-height: 1.5;'>Maintaining your health is the first step in being a reliable donor. Stay strong, Hero!</p>" +
            "  <div style='text-align: center; margin-top: 30px;'>" +
            "    <a href='http://localhost:9090/blood-bank/blog.jsp' style='background-color: #0f172a; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold;'>Read More Health Insights</a>" +
            "  </div>" +
            "</div>");
    }

    public static void sendMonthlyImpactEmail(java.util.List<String> bccEmails, long livesSaved, long heroCount) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        sendBroadcast(bccEmails, "\uD83C\uDFC6 Your Monthly Impact Report - LifeFlow", 
            "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #e11d48; border-radius: 8px;'>" +
            "  <div style='text-align: center; margin-bottom: 30px;'>" +
            "    <h1 style='color: #e11d48; margin: 0;'>\uD83C\uDFC6 IMPACT UPDATE</h1>" +
            "    <p style='color: #666; font-size: 1.1em;'>The power of a community in motion.</p>" +
            "  </div>" +
            "  <div style='display: flex; gap: 20px; margin-bottom: 30px;'>" +
            "    <div style='flex: 1; background: #fff1f2; padding: 20px; border-radius: 10px; text-align: center;'>" +
            "      <h2 style='margin: 0; color: #be123c;'>" + livesSaved + "</h2>" +
            "      <p style='margin: 5px 0 0; font-size: 0.85em; color: #9f1239; font-weight: bold;'>LIVES SAVED</p>" +
            "    </div>" +
            "    <div style='flex: 1; background: #f8fafc; padding: 20px; border-radius: 10px; text-align: center;'>" +
            "      <h2 style='margin: 0; color: #0f172a;'>" + (heroCount > 5000 ? heroCount : "5,000+") + "</h2>" +
            "      <p style='margin: 5px 0 0; font-size: 0.85em; color: #475569; font-weight: bold;'>HEROES IN NETWORK</p>" +
            "    </div>" +
            "  </div>" +
            "  <p style='font-size: 1.05em; line-height: 1.6;'>This month, because of selfless individuals like you, we were able to fulfill critical blood demands across the grid. Every unit moved is a family protected.</p>" +
            "  <div style='text-align: center; margin-top: 35px; border-top: 1px solid #eee; padding-top: 25px;'>" +
            "    <p style='font-style: italic; color: #64748b;'>\"You're part of something bigger than ourselves.\"</p>" +
            "  </div>" +
            "</div>");
    }

    public static void sendPersonalizedNeedEmail(java.util.List<String> bccEmails, String bloodGroup, String city, String requestedBy) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        sendBroadcast(bccEmails, "❗ Required: " + bloodGroup + " donors needed in " + city, 
            "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #e11d48; border-radius: 8px;'>" +
            "  <h2 style='color: #e11d48; text-align: center;'>LOCALIZED ALERT</h2>" +
            "  <p style='font-size: 1.1em;'>Hey Hero,</p>" +
            "  <p style='font-size: 1.1em; line-height: 1.6;'>We're reaching out because <strong>" + bloodGroup + "</strong> donors are currently in high demand in your area (<strong>" + city + "</strong>).</p>" +
            "  <div style='background: #fee2e2; border-left: 4px solid #ef4444; padding: 20px; margin: 25px 0;'>" +
            "    <p style='margin: 0; font-size: 1.1em; color: #7f1d1d;'><strong>Urgent Need:</strong> " + bloodGroup + " (matching yours!)</p>" +
            "    <p style='margin: 5px 0 0; color: #991b1b;'>Requested by: " + requestedBy + "</p>" +
            "  </div>" +
            "  <div style='text-align: center; margin-top: 30px;'>" +
            "    <a href='http://localhost:9090/blood-bank/login.jsp' style='background-color: #e11d48; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold;'>Respond Immediately</a>" +
            "  </div>" +
            "</div>");
    }

    public static void sendNewHospitalJoinedEmail(java.util.List<String> bccEmails, String hospitalName, String city) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        sendBroadcast(bccEmails, "\uD83C\uDFE5 New Facility Joined: " + hospitalName + " (" + city + ")", 
            "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #0f172a; border-radius: 8px;'>" +
            "  <div style='text-align: center;'>" +
            "    <h2 style='color: #0f172a;'>NETWORK GROWTH</h2>" +
            "    <p style='color: #666;'>The LifeFlow grid is expanding.</p>" +
            "  </div>" +
            "  <p style='font-size: 1.1em; line-height: 1.6; margin-top: 25px;'>We are proud to welcome <strong>" + hospitalName + "</strong> in <strong>" + city + "</strong> to our global medical logistics network.</p>" +
            "  <p>Users in this region now have faster access to critical stock and faster dispatch routes.</p>" +
            "  <div style='text-align: center; margin-top: 30px;'>" +
            "    <a href='http://localhost:9090/blood-bank/features.jsp' style='background-color: #0f172a; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold;'>Explore the Network</a>" +
            "  </div>" +
            "</div>");
    }

    public static void sendNewCampAlertEmail(java.util.List<String> bccEmails, String title, String date, String location) {
        if (bccEmails == null || bccEmails.isEmpty()) return;
        sendBroadcast(bccEmails, "\uD83D\uDCCD New Donation Camp: " + title, 
            "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #2563eb; border-radius: 8px;'>" +
            "  <h2 style='color: #2563eb; text-align: center;'>UPCOMING DONATION CAMP</h2>" +
            "  <p style='font-size: 1.1em; line-height: 1.6;'>A new community event has been scheduled. Join your fellow heroes and contribute to the local supply!</p>" +
            "  <div style='background: #eff6ff; border: 1px solid #bfdbfe; padding: 15px; border-radius: 8px; margin: 20px 0;'>" +
            "    <p style='margin: 0;'><strong>Event:</strong> " + title + "</p>" +
            "    <p style='margin: 8px 0 0;'><strong>Date:</strong> " + date + "</p>" +
            "    <p style='margin: 8px 0 0;'><strong>Location:</strong> " + location + "</p>" +
            "  </div>" +
            "  <div style='text-align: center; margin-top: 30px;'>" +
            "    <a href='http://localhost:9090/blood-bank/login.jsp' style='background-color: #2563eb; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold;'>Set a Reminder</a>" +
            "  </div>" +
            "</div>");
    }

    public static void sendNewsletterConfirmationEmail(String toEmail) {
        System.out.println("Sending Newsletter Confirmation to: " + toEmail);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            
            message.setSubject("\uD83D\uDCE2 Welcome to the LifeFlow Network!");
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #e11d48; border-radius: 8px;'>" +
                    "  <div style='text-align: center; margin-bottom: 20px;'>" +
                    "    <h1 style='color: #e11d48; margin: 0;'>WELCOME, HERO!</h1>" +
                    "  </div>" +
                    "  <p style='font-size: 1.1em; line-height: 1.6;'>You have successfully subscribed to the LifeFlow Medical Newsletter.</p>" +
                    "  <p>You'll now receive real-time updates on critical blood shortages, community impact reports, and health tips specifically curated for our donor network.</p>" +
                    "  <div style='background: #f8fafc; border-left: 4px solid #e11d48; padding: 15px; margin: 25px 0;'>" +
                    "    <p style='margin: 0; font-size: 1.1em; color: #334155;'><strong>Status:</strong> Active Dispatch Alert Ready</p>" +
                    "  </div>" +
                    "  <p style='font-size: 0.8em; color: #999; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; text-align: center;'>Thank you for standing by to save lives.</p>" +
                    "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Newsletter confirmation email sent successfully to " + toEmail);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendRegistrationReceivedEmail(String toEmail, String userName) {
        System.out.println("Sending Registration Received email to: " + toEmail);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            
            message.setSubject("LifeFlow: Registration Received! 📥");
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #64748b; border-radius: 8px;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h1 style='color: #0f172a; margin: 0;'>REGISTRATION RECEIVED</h1>"
                    + "  <p style='color: #666; font-size: 1.1em; margin-top: 5px;'>Thank you for joining our network.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em;'>Hi " + userName + ",</p>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>We've successfully received your registration request for LifeFlow. Our administrators are currently reviewing your details to ensure the integrity of our medical network.</p>"
                    + "<div style='background: #f1f5f9; border-left: 4px solid #64748b; padding: 15px; margin: 25px 0;'>"
                    + "  <p style='margin: 0; font-size: 1.1em; color: #334155;'><strong>Current Status:</strong> Awaiting Approval</p>"
                    + "  <p style='margin: 10px 0 0 0; font-size: 1.0em; color: #475569;'>You will receive another email as soon as your account is activated (usually within 24 hours).</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>Once approved, you'll be able to login and start your mission as a LifeFlow Hero.</p>"
                    + "<p style='font-size: 0.8em; color: #999; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; text-align: center;'>LifeFlow Global &bull; Medical Logistics Platform</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Registration received email sent successfully to " + toEmail);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendRegistrationApprovalEmail(String toEmail, String userName) {
        System.out.println("Sending Registration Approval email to: " + toEmail);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            
            message.setSubject("LifeFlow: Your Account has been Approved! \uD83C\uDF89");
            
            String htmlBody = "<div style='font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 600px; margin: auto; border: 1px solid #ddd; border-top: 5px solid #e11d48; border-radius: 8px;'>"
                    + "<div style='text-align: center; margin-bottom: 20px;'>"
                    + "  <h1 style='color: #e11d48; margin: 0;'>WELCOME TO THE GRID</h1>"
                    + "  <p style='color: #666; font-size: 1.2em; margin-top: 5px;'>Your journey starts here.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em;'>Dear " + userName + ",</p>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>Great news! Your registration for the LifeFlow platform has been <strong>Approved</strong> by our administration team.</p>"
                    + "<div style='background: #f8fafc; border-left: 4px solid #e11d48; padding: 15px; margin: 25px 0;'>"
                    + "  <p style='margin: 0; font-size: 1.1em; color: #334155;'><strong>Account Status:</strong> Verified & Active</p>"
                    + "  <p style='margin: 10px 0 0 0; font-size: 1.0em; color: #475569;'>You now have full access to blood tracking, emergency alerts, and donor analytics.</p>"
                    + "</div>"
                    + "<p style='font-size: 1.1em; line-height: 1.6;'>You can now login to your dashboard using your registered email address.</p>"
                    + "<div style='text-align: center; margin-top: 30px;'>"
                    + "  <a href='http://localhost:9090/blood-bank/login.jsp' style='background-color: #e11d48; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 1.1em;'>Login to Dashboard</a>"
                    + "</div>"
                    + "<p style='font-size: 0.8em; color: #999; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; text-align: center;'>Thank you for joining the LifeFlow mission to protect and save lives.</p>"
                    + "</div>";
                    
            message.setContent(htmlBody, "text/html");
            Transport.send(message);
            System.out.println("✅ Registration approval email sent successfully to " + toEmail);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void sendBroadcast(java.util.List<String> bccEmails, String subject, String htmlBody) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            
            InternetAddress[] bccAddresses = new InternetAddress[bccEmails.size()];
            for (int i = 0; i < bccEmails.size(); i++) {
                bccAddresses[i] = new InternetAddress(bccEmails.get(i));
            }
            message.setRecipients(Message.RecipientType.BCC, bccAddresses);
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(USERNAME));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=UTF-8");
            
            Transport.send(message);
            System.out.println("✅ Newsletter/Broadcast sent successfully to " + bccEmails.size() + " recipients.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

