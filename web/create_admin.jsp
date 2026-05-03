<%@ page import="java.sql.*" %>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <html>

        <head>
            <title>Create Admin</title>
        </head>

        <body>
            <h2>Admin Account Setup</h2>
            <% String url="jdbc:mysql://localhost:3306/blood_bank_db?useSSL=false&serverTimezone=UTC" ; String
                dbUser="root" ; String dbPass="Mukesh@18" ; String
                passHash="8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918" ; try { try {
                Class.forName("com.mysql.cj.jdbc.Driver"); } catch (Exception e) {} Connection
                conn=DriverManager.getConnection(url, dbUser, dbPass); // Simple manual check Statement
                st=conn.createStatement(); ResultSet rs=st.executeQuery("SELECT count(*) FROM users WHERE
                email='admin@bloodbank.com'");
        rs.next();
        int count = rs.getInt(1);
        
        if (count > 0) {
             PreparedStatement psUpdate = conn.prepareStatement(" UPDATE users SET password_hash=?, role='ADMIN' ,
                status='APPROVED' WHERE email='admin@bloodbank.com'");
             psUpdate.setString(1, passHash);
             psUpdate.executeUpdate();
             out.println(" Updated existing admin."); } else { PreparedStatement psInsert=conn.prepareStatement("INSERT
                INTO users (full_name, email, phone, password_hash, role, status, city) VALUES ('System
                Admin', 'admin@bloodbank.com' , '0000' , ?, 'ADMIN' , 'APPROVED' , 'HQ' )"); psInsert.setString(1,
                passHash); psInsert.executeUpdate(); out.println("Created new admin."); } conn.close(); } catch
                (Exception e) { out.println("Error: " + e.toString());
    }
    %>
    <br><a href=" login.jsp">Login Now</a>
        </body>

        </html>