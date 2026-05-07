package com.lifeos.backend.financial.infrastructure.provider.payway;

import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.security.PublicKey;
import java.util.Base64;

@Service
public class PayWayRsaService {

    public String encryptLongText(String source, PublicKey publicKey) {
        try {
            int maxChunk = 117;
            byte[] sourceBytes = source.getBytes(StandardCharsets.UTF_8);
            ByteArrayOutputStream output = new ByteArrayOutputStream();

            Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
            cipher.init(Cipher.ENCRYPT_MODE, publicKey);

            int offset = 0;
            while (offset < sourceBytes.length) {
                int length = Math.min(maxChunk, sourceBytes.length - offset);
                output.write(cipher.doFinal(sourceBytes, offset, length));
                offset += length;
            }

            return Base64.getEncoder().encodeToString(output.toByteArray());
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to encrypt PayWay merchant_auth", ex);
        }
    }
}