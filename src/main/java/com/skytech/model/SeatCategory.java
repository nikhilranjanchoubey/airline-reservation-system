package com.skytech.model;

/**
 * Standard airline seat pricing categories across Indian domestic carriers.
 */
public enum SeatCategory {
    EXTRA_LEGROOM("Extra Legroom", "Bulkhead Row 1 & Emergency Exit Rows with extended pitch"),
    FRONT_ROW("Front Row", "Rows 2–3 for priority deplaning and convenience"),
    PREFERRED("Preferred", "Forward rows 4–8 with quicker embarkation/disembarkation"),
    STANDARD("Standard", "Standard cabin seating with complimentary middle seats");

    private final String displayName;
    private final String description;

    SeatCategory(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }
}
