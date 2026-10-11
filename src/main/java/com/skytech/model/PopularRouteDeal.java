package com.skytech.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Model representing a featured popular route deal or Daily Shuffle recommendation
 * with dynamically resolved pricing from central inventory.
 */
public class PopularRouteDeal implements Serializable {

    private static final long serialVersionUID = 1L;

    private String sourceCode;
    private String destinationCode;
    private String sourceCity;
    private String destinationCity;
    private String airlineSummary;
    private BigDecimal lowestPrice;
    private String durationFormatted;
    private String stopsDescription;
    private String imageUrl;
    private String imageAlt;
    private String tag;
    private boolean dailyShuffle;
    private LocalDate searchDate;

    public PopularRouteDeal() {
    }

    public PopularRouteDeal(String sourceCode, String destinationCode, String sourceCity,
                            String destinationCity, String airlineSummary, BigDecimal lowestPrice,
                            String durationFormatted, String stopsDescription, String imageUrl,
                            String imageAlt, String tag, boolean dailyShuffle, LocalDate searchDate) {
        this.sourceCode = sourceCode;
        this.destinationCode = destinationCode;
        this.sourceCity = sourceCity;
        this.destinationCity = destinationCity;
        this.airlineSummary = airlineSummary;
        this.lowestPrice = lowestPrice;
        this.durationFormatted = durationFormatted;
        this.stopsDescription = stopsDescription;
        this.imageUrl = imageUrl;
        this.imageAlt = imageAlt;
        this.tag = tag;
        this.dailyShuffle = dailyShuffle;
        this.searchDate = searchDate;
    }

    public String getSourceCode() {
        return sourceCode;
    }

    public void setSourceCode(String sourceCode) {
        this.sourceCode = sourceCode;
    }

    public String getDestinationCode() {
        return destinationCode;
    }

    public void setDestinationCode(String destinationCode) {
        this.destinationCode = destinationCode;
    }

    public String getSourceCity() {
        return sourceCity;
    }

    public void setSourceCity(String sourceCity) {
        this.sourceCity = sourceCity;
    }

    public String getDestinationCity() {
        return destinationCity;
    }

    public void setDestinationCity(String destinationCity) {
        this.destinationCity = destinationCity;
    }

    public String getAirlineSummary() {
        return airlineSummary;
    }

    public void setAirlineSummary(String airlineSummary) {
        this.airlineSummary = airlineSummary;
    }

    public BigDecimal getLowestPrice() {
        return lowestPrice;
    }

    public void setLowestPrice(BigDecimal lowestPrice) {
        this.lowestPrice = lowestPrice;
    }

    public String getDurationFormatted() {
        return durationFormatted;
    }

    public void setDurationFormatted(String durationFormatted) {
        this.durationFormatted = durationFormatted;
    }

    public String getStopsDescription() {
        return stopsDescription;
    }

    public void setStopsDescription(String stopsDescription) {
        this.stopsDescription = stopsDescription;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getImageAlt() {
        return (imageAlt != null && !imageAlt.isEmpty()) ? imageAlt : (destinationCity + " Landmark");
    }

    public void setImageAlt(String imageAlt) {
        this.imageAlt = imageAlt;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public boolean isDailyShuffle() {
        return dailyShuffle;
    }

    public void setDailyShuffle(boolean dailyShuffle) {
        this.dailyShuffle = dailyShuffle;
    }

    public LocalDate getSearchDate() {
        return searchDate;
    }

    public void setSearchDate(LocalDate searchDate) {
        this.searchDate = searchDate;
    }

    public String getFormattedPrice() {
        if (lowestPrice == null) {
            return null;
        }
        return java.text.NumberFormat.getIntegerInstance(new java.util.Locale("en", "IN")).format(lowestPrice);
    }
}
