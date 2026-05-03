package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.EnumMap;
import java.util.Map;

/**
 * Generates a QR code PNG that encodes a verification URL for a given appointmentId.
 *
 * Requires ZXing core + javase libraries on the classpath.
 */
@WebServlet(name = "CertificateQrServlet", urlPatterns = {"/certificate-qr"})
public class CertificateQrServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String appointmentId = request.getParameter("appointmentId");
        if (appointmentId == null || appointmentId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing appointmentId");
            return;
        }

        // Verify that appointment exists and is completed
        try {
            Firestore db = FirebaseConfig.getFirestore();
            DocumentSnapshot apptDoc = db.collection("appointments").document(appointmentId).get().get();
            
            if (!apptDoc.exists() || !"COMPLETED".equals(apptDoc.getString("status"))) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No completed appointment");
                return;
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
            return;
        }

        String verifyUrl = request.getRequestURL().toString().replace("certificate-qr", "verify-certificate")
                + "?appointmentId=" + appointmentId;

        int size = 260;
        QRCodeWriter qrCodeWriter = new QRCodeWriter();
        Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
        hints.put(EncodeHintType.MARGIN, 1);

        BitMatrix bitMatrix;
        try {
            bitMatrix = qrCodeWriter.encode(verifyUrl, BarcodeFormat.QR_CODE, size, size, hints);
        } catch (WriterException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
            return;
        }

        BufferedImage image = MatrixToImageWriter.toBufferedImage(bitMatrix);
        response.setContentType("image/png");
        ImageIO.write(image, "png", response.getOutputStream());
    }
}

