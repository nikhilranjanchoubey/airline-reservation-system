package com.skytech.service;

import com.skytech.model.SeatCategory;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * Configurable, airline-specific ancillary seat pricing system.
 *
 * NOTE: AeroDataBox FIDS does not provide ancillary seat fees.
 * Seat fees in SkyTech are estimated models derived from published domestic
 * carrier structures (IndiGo, Air India, Akasa Air, Air India Express).
 */
public class SeatPricingConfig {

    public static class SeatPricingInfo {
        private final SeatCategory category;
        private final BigDecimal price;
        private final String categoryLabel;
        private final String currency;
        private final boolean estimated;
        private final String sourceNotice;

        public SeatPricingInfo(SeatCategory category, BigDecimal price, String categoryLabel) {
            this.category = category;
            this.price = price;
            this.categoryLabel = categoryLabel;
            this.currency = "INR";
            this.estimated = true;
            this.sourceNotice = "SkyTech demonstration seat fee — live airline ancillary pricing is not available from current flight provider";
        }

        public SeatCategory getCategory() {
            return category;
        }

        public BigDecimal getPrice() {
            return price;
        }

        public String getCategoryLabel() {
            return categoryLabel;
        }

        public String getCurrency() {
            return currency;
        }

        public boolean isEstimated() {
            return estimated;
        }

        public String getSourceNotice() {
            return sourceNotice;
        }
    }

    /**
     * Resolves realistic ancillary seat fee based on airline code, row number, and column.
     *
     * @param airlineCode 2-character IATA airline code (e.g. 6E, AI, QP, IX)
     * @param row row index (1 to 20+)
     * @param col column letter (A to F)
     * @return {@link SeatPricingInfo} with category, fee, and descriptive metadata
     */
    public static SeatPricingInfo resolveSeatPricing(String airlineCode, int row, String col) {
        String code = airlineCode != null ? airlineCode.trim().toUpperCase() : "6E";
        boolean isWindowOrAisle = "A".equalsIgnoreCase(col) || "F".equalsIgnoreCase(col) ||
                                  "C".equalsIgnoreCase(col) || "D".equalsIgnoreCase(col);

        // Row 1: Front bulkhead - Maximum legroom
        if (row == 1) {
            BigDecimal fee;
            switch (code) {
                case "AI": fee = BigDecimal.valueOf(1199); break; // Air India Extra Legroom
                case "UK": fee = BigDecimal.valueOf(1100); break; // Vistara
                case "QP": fee = BigDecimal.valueOf(899); break;  // Akasa Air
                case "IX": fee = BigDecimal.valueOf(850); break;  // Air India Express
                case "6E":
                default:   fee = BigDecimal.valueOf(999); break;  // IndiGo XL Seat
            }
            return new SeatPricingInfo(SeatCategory.EXTRA_LEGROOM, fee, "Extra Legroom (Row 1)");
        }

        // Row 12 & 13: Emergency Exit Rows
        if (row == 12 || row == 13) {
            BigDecimal fee;
            switch (code) {
                case "AI": fee = BigDecimal.valueOf(999); break;
                case "UK": fee = BigDecimal.valueOf(950); break;
                case "QP": fee = BigDecimal.valueOf(799); break;
                case "IX": fee = BigDecimal.valueOf(750); break;
                case "6E":
                default:   fee = BigDecimal.valueOf(899); break;
            }
            return new SeatPricingInfo(SeatCategory.EXTRA_LEGROOM, fee, "Exit Row Legroom");
        }

        // Rows 2 & 3: Front rows
        if (row >= 2 && row <= 3) {
            BigDecimal fee;
            if (isWindowOrAisle) {
                switch (code) {
                    case "AI": fee = BigDecimal.valueOf(550); break;
                    case "QP": fee = BigDecimal.valueOf(450); break;
                    case "6E":
                    default:   fee = BigDecimal.valueOf(499); break;
                }
            } else {
                // Middle seat front row
                fee = BigDecimal.valueOf(350);
            }
            return new SeatPricingInfo(SeatCategory.FRONT_ROW, fee, isWindowOrAisle ? "Front Row" : "Front Row Middle");
        }

        // Rows 4 to 8: Preferred forward rows
        if (row >= 4 && row <= 8) {
            BigDecimal fee;
            if (isWindowOrAisle) {
                fee = BigDecimal.valueOf(350);
            } else {
                fee = BigDecimal.valueOf(250);
            }
            return new SeatPricingInfo(SeatCategory.PREFERRED, fee, isWindowOrAisle ? "Preferred Seat" : "Preferred Middle");
        }

        // Standard Rows (Rows 9+):
        if (isWindowOrAisle) {
            // Window or aisle standard seat
            BigDecimal fee = BigDecimal.valueOf(150);
            return new SeatPricingInfo(SeatCategory.STANDARD, fee, "Standard Seat");
        } else {
            // Middle standard seat is complimentary (₹0)
            return new SeatPricingInfo(SeatCategory.STANDARD, BigDecimal.ZERO, "Standard Complimentary");
        }
    }
}
