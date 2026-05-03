<%@ page import="java.sql.*" %>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <% try { Class.forName("com.mysql.cj.jdbc.Driver"); Connection
            conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/blood_bank_db?useSSL=false&serverTimezone=UTC", "root"
            , "Mukesh@18" ); Statement stmt=conn.createStatement(); String[]
            banks={ "Central India Blood Bank|central@bloodbank.com|0712-222222|Near Zero Mile Stone|Nagpur|440001|21.1458|79.0882"
            , "Delhi Red Cross|delhi@bloodbank.com|011-23333333|1 Red Cross Road|New Delhi|110001|28.6139|77.2090"
            , "Mumbai Life Care|mumbai@bloodbank.com|022-24444444|Dadar West|Mumbai|400028|19.0760|72.8777" };
            for(String b : banks) { String[] parts=b.split("\\|"); String name=parts[0]; ResultSet
            rs=stmt.executeQuery("SELECT count(*) FROM blood_banks WHERE bank_name='" + name + "'");
            rs.next();
            if(rs.getInt(1) == 0) {
                 stmt.executeUpdate(" INSERT INTO blood_banks (bank_name, email, phone, address_line1, city, pincode,
            latitude, longitude, status) VALUES ('" + parts[0] + "', '" + parts[1] + "', '" + parts[2] + "', '" +
            parts[3] + "', '" + parts[4] + "', '" + parts[5] + "', " + parts[6] + ", " + parts[7] + ", 'APPROVED')" );
            out.println("Added: " + name + " <br>");

            ResultSet bankIdRs = stmt.executeQuery("SELECT id FROM blood_banks WHERE bank_name='" + name + "'");
            if (bankIdRs.next()) {
            long newId = bankIdRs.getLong(1);
            stmt.executeUpdate("INSERT INTO blood_stock (bank_id, blood_group, units_available) VALUES (" + newId + ",
            'A+', 10)");
            }
            bankIdRs.close();
            } else {
            out.println("Exists: " + name + "<br>");
            }
            rs.close();
            }
            conn.close();
            out.println("Done.");
            } catch (Exception e) {
            out.println("Error: " + e.getMessage());
            e.printStackTrace(new java.io.PrintWriter(out));
            }
            %>