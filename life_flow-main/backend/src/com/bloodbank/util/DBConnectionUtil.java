package com.bloodbank.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnectionUtil {

private static final String URL =
"jdbc:mysql://127.0.0.1:3306/bloodbank?useSSL=false&allowPublicKeyRetrieval=true";

    private static final String USERNAME = "root";
    private static final String PASSWORD = "Vijay@150704";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}

