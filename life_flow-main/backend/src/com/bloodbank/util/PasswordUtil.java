package com.bloodbank.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Simple SHA-256 based password hashing utility.
 *
 * NOTE: For production, prefer a strong adaptive algorithm such as BCrypt, Argon2 or PBKDF2.
 */
public class PasswordUtil {

    private static final String ALGORITHM = "SHA-256";

    public static String hashPassword(String plainText) {
        if (plainText == null) {
            throw new IllegalArgumentException("Password cannot be null");
        }
        try {
            MessageDigest digest = MessageDigest.getInstance(ALGORITHM);
            byte[] hash = digest.digest(plainText.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }

    public static boolean verifyPassword(String plainText, String expectedHash) {
        if (plainText == null || expectedHash == null) {
            return false;
        }
        String actualHash = hashPassword(plainText);
        return slowEquals(actualHash, expectedHash);
    }

    private static boolean slowEquals(String a, String b) {
        int diff = a.length() ^ b.length();
        for (int i = 0; i < a.length() && i < b.length(); i++) {
            diff |= a.charAt(i) ^ b.charAt(i);
        }
        return diff == 0;
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                sb.append('0');
            }
            sb.append(hex);
        }
        return sb.toString();
    }
}

