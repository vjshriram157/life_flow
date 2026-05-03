<%@ page import="java.sql.*" %>
    <%@ page import="com.bloodbank.util.DBConnectionUtil" %>
        <%@ page contentType="text/html;charset=UTF-8" language="java" %>
            <html>

            <body>
                <h1>Database Setup</h1>
                <% Connection conn=null; try { // Use the util class conn=DBConnectionUtil.getConnection(); Statement
                    stmt=conn.createStatement(); // 1. Nagpur String n="Central India Blood Bank" ; ResultSet
                    rs1=stmt.executeQuery("SELECT count(*) FROM blood_banks WHERE bank_name='" + n + "'");
        rs1.next();
        if(rs1.getInt(1) == 0) {
             stmt.executeUpdate(" INSERT INTO blood_banks (bank_name, email, phone, address_line1, city, pincode,
                    latitude, longitude, status) VALUES ('" + n
                    + "', 'central@bloodbank.com', '0712-222222', 'Near Zero Mile Stone', 'Nagpur', '440001', 21.1458, 79.0882, 'APPROVED')"
                    ); out.println("Added: " + n + " <br>");

                    // Stock
                    ResultSet idRs = stmt.executeQuery("SELECT id FROM blood_banks WHERE bank_name='" + n + "'");
                    if(idRs.next()) {
                    long id = idRs.getLong(1);
                    stmt.executeUpdate("INSERT INTO blood_stock (bank_id, blood_group, units_available) VALUES (" + id +
                    ", 'A+', 10)");
                    stmt.executeUpdate("INSERT INTO blood_stock (bank_id, blood_group, units_available) VALUES (" + id +
                    ", 'B+', 5)");
                    }
                    idRs.close();

                    } else {
                    out.println("Exists: " + n + "<br>");
                    }
                    rs1.close();

                    // 2. Delhi
                    n = "Delhi Red Cross";
                    ResultSet rs2 = stmt.executeQuery("SELECT count(*) FROM blood_banks WHERE bank_name='" + n + "'");
                    rs2.next();
                    if(rs2.getInt(1) == 0) {
                    stmt.executeUpdate("INSERT INTO blood_banks (bank_name, email, phone, address_line1, city, pincode,
                    latitude, longitude, status) VALUES ('" + n + "', 'delhi@bloodbank.com', '011-23333333', '1 Red
                    Cross Road', 'New Delhi', '110001', 28.6139, 77.2090, 'APPROVED')");
                    out.println("Added: " + n + "<br>");
                    } else {
                    out.println("Exists: " + n + "<br>");
                    }
                    rs2.close();

                    // 3. Mumbai
                    n = "Mumbai Life Care";
                    ResultSet rs3 = stmt.executeQuery("SELECT count(*) FROM blood_banks WHERE bank_name='" + n + "'");
                    rs3.next();
                    if(rs3.getInt(1) == 0) {
                    stmt.executeUpdate("INSERT INTO blood_banks (bank_name, email, phone, address_line1, city, pincode,
                    latitude, longitude, status) VALUES ('" + n + "', 'mumbai@bloodbank.com', '022-24444444', 'Dadar
                    West', 'Mumbai', '400028', 19.0760, 72.8777, 'APPROVED')");
                    out.println("Added: " + n + "<br>");
                    } else {
                    out.println("Exists: " + n + "<br>");
                    }
                    rs3.close();

                    out.println("Done.");
                    } catch (Exception e) {
                    out.println("Error: " + e.getMessage());
                    e.printStackTrace(new java.io.PrintWriter(out));
                    } finally {
                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                    }
                    %>
            </body>

            </html>