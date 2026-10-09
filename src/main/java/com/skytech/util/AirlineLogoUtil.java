package com.skytech.util;

/**
 * Utility to map airline IATA codes to local SVG logo assets with safe fallback.
 */
public class AirlineLogoUtil {

    public static String getLogoUrl(String airlineCode, String contextPath) {
        if (airlineCode == null) {
            return null;
        }
        String code = airlineCode.trim().toUpperCase();
        switch (code) {
            case "6E":
            case "AI":
            case "QP":
            case "UK":
            case "SG":
                return contextPath + "/assets/images/airlines/" + code + ".svg";
            case "IX":
                return contextPath + "/assets/images/airlines/AI.svg";
            default:
                return null;
        }
    }
}
