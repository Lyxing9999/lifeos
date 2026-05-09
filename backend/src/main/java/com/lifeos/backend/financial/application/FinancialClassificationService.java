//package com.lifeos.backend.financial.application;
//
//import com.lifeos.backend.financial.domain.FinancialCategory;
//import org.springframework.stereotype.Service;
//
//import java.math.BigDecimal;
//
//@Service
//public class FinancialClassificationService {
//
//    public String normalizeMerchantName(String merchantName) {
//        return merchantName == null ? null : merchantName.trim().toUpperCase();
//    }
//
//    public double merchantConfidence(String merchantName) {
//        return merchantName == null || merchantName.isBlank() ? 0.2 : 0.9;
//    }
//
//    public FinancialCategory inferCategory(String merchantName, String description, BigDecimal amount) {
//        String text = ((merchantName == null ? "" : merchantName) + " " +
//                (description == null ? "" : description)).toLowerCase();
//
//        if (text.contains("coffee") || text.contains("cafe") || text.contains("food") || text.contains("burger")) {
//            return FinancialCategory.FOOD;
//        }
//        if (text.contains("grab") || text.contains("taxi") || text.contains("ride")) {
//            return FinancialCategory.TRANSPORT;
//        }
//        if (text.contains("school") || text.contains("book") || text.contains("course")) {
//            return FinancialCategory.EDUCATION;
//        }
//        return FinancialCategory.OTHER;
//    }
//}