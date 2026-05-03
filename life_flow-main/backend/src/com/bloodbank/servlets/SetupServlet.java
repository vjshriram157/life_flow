package com.bloodbank.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet(name = "SetupServlet", urlPatterns = {"/setup-db"})
public class SetupServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><body><h1>Database Setup</h1>");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/blood_bank_db?useSSL=false&serverTimezone=UTC", "root", "Mukesh@18");
            Statement stmt = conn.createStatement();
            
            String[] banks = {
                "Central India Blood Bank|central@bloodbank.com|0712-222222|Near Zero Mile Stone|Nagpur|440001|21.1458|79.0882",
                "Delhi Red Cross|delhi@bloodbank.com|011-23333333|1 Red Cross Road|New Delhi|110001|28.6139|77.2090",
                "Mumbai Life Care|mumbai@bloodbank.com|022-24444444|Dadar West|Mumbai|400028|19.0760|72.8777",
                "Chennai Lions Blood Bank|lions@chennaiblood.com|044-28414444|130 Marshalls Road|Chennai|600008|13.0694|80.2591",
                "Bangalore Rashtrotthana|info@rashtrotthana.org|080-26613333|Gavipuram Guttahalli|Bangalore|560019|12.9430|77.5670",
                "Kolkata Central Blood Bank|kolkata@cbb.gov.in|033-23510620|205 Vivekananda Road|Kolkata|700006|22.5835|88.3734",
                "Hyderabad Chiranjeevi BB|contact@chiranjeevibb.com|040-23555005|Road No 1, Jubilee Hills|Hyderabad|500033|17.4265|78.4120",
                "Ahmedabad Prathama|info@prathama.org|079-26600101|Near Vasna Barrage|Ahmedabad|380007|23.0031|72.5413",
                "Pune Poona Blood Bank|info@poonabloodbank.org|020-24444545|1222 Sadashiv Peth|Pune|411030|18.5089|73.8446",
                "Lucknow KGMU Blood Bank|kgmu@up.gov.in|0522-2257540|Shah Mina Road|Lucknow|226003|26.8667|80.9167",
                "Jaipur Swasthya Kalyan|sk@bloodbank.com|0141-2565656|Sitapura Industrial Area|Jaipur|302022|26.7794|75.8361",
                "Patna Red Cross|patna@redcross.com|0612-2222123|Gandhi Maidan Path|Patna|800001|25.6188|85.1404",
                "Indore MY Hospital BB|myh@indore.gov.in|0731-2527301|MY Hospital Campus|Indore|452001|22.7125|75.8770",
                "Chandigarh PGI Blood Bank|pgi@chd.nic.in|0172-2747585|Sector 12|Chandigarh|160012|30.7651|76.7731",
                "Guwahati State Blood Bank|guwahati@assam.gov.in|0361-2529457|Boruah Road|Guwahati|781005|26.1750|91.7500",
                "Government General Hospital BB|gh.bloodbank@tn.gov.in|044-25305000|Near Central Railway Station|Chennai|600003|13.0827|80.2707",
                "Madurai Rajaji Hospital BB|grh.mdu@tn.gov.in|0452-2532535|Panagal Road|Madurai|625020|9.9257|78.1273",
                "Coimbatore Medical College BB|cmc.cbe@tn.gov.in|0422-2301393|Avinashi Road|Coimbatore|641018|11.0018|76.9747",
                "Trichy MGM Hospital BB|mgm.try@tn.gov.in|0431-2415524|Puthur|Trichy|620017|10.8158|78.6888",
                "Salem Government Hospital BB|gh.salem@tn.gov.in|0427-2211883|Collectorate Road|Salem|636001|11.6643|78.1460",
                "Tirunelveli Medical College BB|tvmc.tvl@tn.gov.in|0462-2572633|High Ground|Tirunelveli|627011|8.7186|77.7471",
                "Vellore CMC Blood Bank|bloodbank@cmcvellore.ac.in|0416-2282335|Ida Scudder Road|Vellore|632004|12.9260|79.1350",
                "Tiruppur District Hospital BB|gh.tiruppur@tn.gov.in|0421-2242108|Dharapuram Road|Tiruppur|641604|11.1085|77.3411",
                "Erode Government Hospital|gh.erode@tn.gov.in|0424-2258355|Chennimalai Road|Erode|638001|11.3410|77.7172",
                "Thanjavur Medical College BB|tmc.tnj@tn.gov.in|04362-240024|Medical College Road|Thanjavur|613004|10.7589|79.1037",
                "Kanchipuram District Hospital|gh.kanchi@tn.gov.in|044-27222028|Railway Station Road|Kanchipuram|631501|12.8342|79.7036",
                "Tuticorin Medical College BB|tmc.tut@tn.gov.in|0461-2322603|Palayamkottai Road|Tuticorin|628003|8.7984|78.1348",
                "Cuddalore GH Blood Bank|gh.cud@tn.gov.in|04142-230351|Hospital Road|Cuddalore|607001|11.7512|79.7645",
                "Nagercoil Kanyakumari MCH|mch.ngl@tn.gov.in|04652-223201|Asaripallam|Nagercoil|629201|8.1884|77.4102",
                "Dharmapuri Medical College BB|mch.dpi@tn.gov.in|04342-233033|Netaji Bye Pass Road|Dharmapuri|636701|12.1353|78.1576",
                "Chennai Blood Centre|info@chennaibloodcentre.com|044-48504455|Sindhoor Complex, 5th Street|Anna Nagar|600040|13.0850|80.2121",
                "Rotary Central TTK VHS|info@vhschennai.org|044-22541672|Rajiv Gandhi Salai, Tharamani|Adyar|600113|12.9863|80.2457",
                "Dhanvantri Blood Bank|dhanvantri@mail.com|044-24310660|South West Boag Road|T Nagar|600017|13.0394|80.2323",
                "Egmore Lions Blood Bank|lions@egmoreblood.com|044-28414949|130 Marshalls Road|Egmore|600008|13.0732|80.2609",
                "Kilpauk Medical College BB|gh.kmc@tn.gov.in|044-28364955|Poonamallee High Road|Kilpauk|600010|13.0785|80.2429",
                "Vijaya Hospital BB|care@vijayahospital.org|044-24802221|NSK Salai|Vadapalani|600026|13.0499|80.2089",
                "Government Stanley Hospital|stanley.bb@tn.gov.in|044-25284941|Old Jail Road|Royapuram|600001|13.1065|80.2811",
                "Hindu Mission Hospital BB|info@hindumission.org|044-22262244|103 GST Road|Tambaram|600045|12.9249|80.1218",
                "Sanjeevan Voluntary BB|contact@sanjeevan.com|044-42002288|Tansi Nagar 2nd Street|Velachery|600042|12.9801|80.2228",
                "Madras Medical Mission|mmm.blood@mail.com|044-26565961|4 Dr. Jayalalitha Nagar|Mogappair|600050|13.0844|80.1811",
                "St. Thomas Blood Bank|st.thomas@mail.com|044-22332144|Defence Colony Road|St. Thomas Mount|600016|13.0039|80.2017",
                "Apollo Hospitals BB|apollo.gh@mail.com|044-28293333|21 Greams Road|Thousand Lights|600006|13.0607|80.2526",
                "MIOT International BB|miot.bb@mail.com|044-22492288|Mount Poonamallee Road|Manapakkam|600089|13.0215|80.1741",
                "Sri Ramachandra Hospital|srmc.bb@mail.com|044-24768000|Ramachandra Nagar|Porur|600116|13.0358|80.1411",
                "Kamatchi Memorial BB|kamatchi@mail.com|044-22463272|Radial Road, Pallikaranai|Velachery|600100|12.9365|80.2104",
                "K.K. Nagar Blood Bank|kknagar.bb@mail.com|044-24741010|Sector 10, K.K. Nagar|Chennai|600078|13.0410|80.1985",
                "ESIC Hospital Blood Bank|esic.kknagar@nic.in|044-24893714|Ashok Pillar Road, K.K. Nagar|Chennai|600078|13.0360|80.1998",
                "SIMS Hospital Blood Bank|bloodbank@simshospitals.com|044-45674567|Pawah Salai, Near Vadapalani Metro|Chennai|600026|13.0485|80.2094",
                "Sooriya Hospital BB|info@sooryahospital.com|044-24891151|1, 100 Feet Road, Vadapalani|Chennai|600026|13.0512|80.2105",
                "Annai Multi Speciality BB|annai.hospital@mail.com|044-24716501|6th Sector, K.K. Nagar|Chennai|600078|13.0385|80.1925",
                "Amrita Blood Bank|amrita.bb@mail.com|044-24833215|Arcot Road|Vadapalani|600026|13.0505|80.2115",
                "Bharath Blood Bank|bharath.bb@mail.com|044-22395566|Velachery Main Road|Selaiyur|600073|12.9123|80.1441",
                "Child Trust Hospital BB|cth.blood@mail.com|044-42271007|Nageswara Road|Nungambakkam|600034|13.0583|80.2458",
                "Deepam Hospital BB|deepam.bb@mail.com|044-22411122|GST Road|Pallavaram|600043|12.9675|80.1505",
                "Dr. Mehta Hospital BB|mehta.bb@mail.com|044-42271001|McNichols Road|Chetpet|600031|13.0694|80.2422",
                "Global Hospital BB|global.bb@mail.com|044-22777000|Cheran Nagar|Perumbakkam|600100|12.9056|80.2081",
                "Hindustan Blood Bank|hindustan.bb@mail.com|044-22340523|GST Road|Guindy|600032|13.0067|80.2206",
                "Janani Blood Bank|janani.bb@mail.com|044-26211111|2nd Avenue|Anna Nagar|600040|13.0842|80.2188",
                "Kanchi Kamakoti Childs Trust|kkcth.bb@mail.com|044-42251234|Nungambakkam|Chennai|600034|13.0590|80.2460",
                "Lifeline Hospital BB|lifeline.bb@mail.com|044-42454545|Perungudi|OMR Chennai|600096|12.9654|80.2461",
                "Malas Blood Bank|malas.bb@mail.com|044-24991122|Luz Church Road|Mylapore|600004|13.0336|80.2625",
                "Nerukkundram Blood Bank|nrk.bb@mail.com|044-24791010|PH Road|Koyambedu|600107|13.0692|80.1915",
                "Prashanth Hospital BB|prashanth.bb@mail.com|044-42277777|Velachery Main Road|Velachery|600042|12.9789|80.2215",
                "Rai Memorial BB|rai.bb@mail.com|044-24349549|Anna Salai|Teynampet|600018|13.0401|80.2503",
                "Santhosh Hospital BB|santhosh.bb@mail.com|044-22312233|GST Road|West Tambaram|600045|12.9240|80.1190",
                "Tiruvallur GH Blood Bank|gh.tvl@tn.gov.in|044-27660201|JN Road|Tiruvallur|602001|13.1435|79.9077",
                "VHS Blood Bank|vhs.mrp@mail.com|044-22542971|Taramani|Adyar|600113|12.9860|80.2450",
                "X-Cell Blood Bank|xcell.bb@mail.com|044-24411133|LB Road|Thiruvanmiyur|600041|12.9894|80.2575",
                "YRG Care Blood Bank|yrg.bb@mail.com|044-22542929|VHS Campus|Taramani|600113|12.9865|80.2455",
                "Zion Blood Bank|zion.bb@mail.com|044-22245678|Camp Road|Selaiyur|600073|12.9150|80.1550",
                "Billroth Hospital BB|billroth.bb@mail.com|044-26444666|Shenoy Nagar|Chennai|600030|13.0781|80.2315",
                "Fortis Malar BB|fortis.malar@mail.com|044-42892222|Gandhi Nagar|Adyar|600020|13.0063|80.2568",
                "Kaliappa Hospital BB|kaliappa.bb@mail.com|044-24911010|Billroth Road|R.A. Puram|600028|13.0245|80.2588",
                "Kumaran Hospital BB|kumaran.bb@mail.com|044-26423000|Poonamallee High Road|Kilpauk|600010|13.0765|80.2405",
                "Soundarapandian BB|sp.bb@mail.com|044-26214444|AA Block|Anna Nagar|600040|13.0865|80.2150"
            };



            for(String b : banks) {
                String[] parts = b.split("\\|");
                String name = parts[0];
                ResultSet rs = stmt.executeQuery("SELECT count(*) FROM blood_banks WHERE bank_name='" + name + "'");
                rs.next();
                if(rs.getInt(1) == 0) {
                     stmt.executeUpdate("INSERT INTO blood_banks (bank_name, email, phone, address_line1, city, pincode, latitude, longitude, status) " +
                                     "VALUES ('" + parts[0] + "', '" + parts[1] + "', '" + parts[2] + "', '" + parts[3] + "', '" + parts[4] + "', '" + parts[5] + "', " + parts[6] + ", " + parts[7] + ", 'APPROVED')");
                     out.println("Added: " + name + "<br>");
                     
                     ResultSet bankIdRs = stmt.executeQuery("SELECT id FROM blood_banks WHERE bank_name='" + name + "'");
                     if (bankIdRs.next()) {
                         long newId = bankIdRs.getLong(1);
                         stmt.executeUpdate("INSERT INTO blood_stock (bank_id, blood_group, units_available) VALUES (" + newId + ", 'A+', 10)");
                         stmt.executeUpdate("INSERT INTO blood_stock (bank_id, blood_group, units_available) VALUES (" + newId + ", 'B+', 5)");
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
            e.printStackTrace(out);
        }
        out.println("</body></html>");
    }
}
