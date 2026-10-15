package com.skytech.service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.Month;
import java.time.ZoneId;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Natural language date parsing utility for SkyTech AI Flight Assistant.
 * Accurately parses relative dates, weekdays, explicit months, and standard formats.
 */
public class AiDateParser {

    private static final ZoneId APP_ZONE = ZoneId.of("Asia/Kolkata");

    public static class DateParseResult {
        public LocalDate departureDate;
        public LocalDate returnDate;
        public boolean isPastDate;
        public boolean isReturnBeforeDeparture;
        public String rawDepartureText;
        public String rawReturnText;
    }

    /**
     * Parses departure and optional return dates from natural language text.
     */
    public static DateParseResult parseDates(String text, LocalDate baseDate) {
        DateParseResult result = new DateParseResult();
        if (text == null || text.trim().isEmpty()) {
            return result;
        }

        LocalDate today = (baseDate != null) ? baseDate : LocalDate.now(APP_ZONE);
        String lower = text.toLowerCase(Locale.ENGLISH);

        // 1. Check for return date patterns: e.g. "returning on 20 October", "return 25 Oct", "returning tomorrow"
        Matcher returnMatcher = Pattern.compile("(?i)(?:returning|return\\s+date|return\\s+on|back\\s+on)\\s+([a-zA-Z0-9\\s,/-]+?)(?:\\s+(?:for|adults?|class|under|cheapest)|$)").matcher(text);
        if (returnMatcher.find()) {
            String returnSnippet = returnMatcher.group(1).trim();
            result.rawReturnText = returnSnippet;
            result.returnDate = parseSingleDate(returnSnippet, today);
        }

        // 2. Parse departure date from the text (excluding the return snippet if found)
        String departureText = text;
        if (returnMatcher.find(0)) {
            departureText = text.substring(0, returnMatcher.start()) + " " + text.substring(returnMatcher.end());
        }

        result.departureDate = parseSingleDate(departureText, today);

        // Validate
        if (result.departureDate != null && result.departureDate.isBefore(today)) {
            result.isPastDate = true;
        }
        if (result.returnDate != null && result.returnDate.isBefore(today)) {
            result.isPastDate = true;
        }
        if (result.departureDate != null && result.returnDate != null && result.returnDate.isBefore(result.departureDate)) {
            result.isReturnBeforeDeparture = true;
        }

        return result;
    }

    public static LocalDate parseSingleDate(String text, LocalDate today) {
        if (text == null || text.trim().isEmpty()) return null;
        String lower = text.toLowerCase(Locale.ENGLISH);

        // Relative Keywords
        if (lower.contains("day after tomorrow")) {
            return today.plusDays(2);
        }
        if (lower.contains("tomorrow")) {
            return today.plusDays(1);
        }
        if (lower.contains("today")) {
            return today;
        }

        // Day of Week: e.g. "next friday", "this friday", "friday", "next monday"
        Matcher dowMatcher = Pattern.compile("(?i)\\b(?:(this|next)\\s+)?(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\\b").matcher(text);
        if (dowMatcher.find()) {
            String modifier = dowMatcher.group(1);
            String dowName = dowMatcher.group(2).toUpperCase(Locale.ENGLISH);
            try {
                DayOfWeek targetDow = DayOfWeek.valueOf(dowName);
                LocalDate candidate = today.plusDays(1);
                while (candidate.getDayOfWeek() != targetDow) {
                    candidate = candidate.plusDays(1);
                }
                if ("next".equalsIgnoreCase(modifier) && candidate.isBefore(today.plusDays(4))) {
                    candidate = candidate.plusWeeks(1);
                }
                return candidate;
            } catch (Exception ignored) {}
        }

        // Explicit ISO format: YYYY-MM-DD
        Matcher isoMatcher = Pattern.compile("\\b(20\\d{2})[-/](\\d{1,2})[-/](\\d{1,2})\\b").matcher(text);
        if (isoMatcher.find()) {
            try {
                int y = Integer.parseInt(isoMatcher.group(1));
                int m = Integer.parseInt(isoMatcher.group(2));
                int d = Integer.parseInt(isoMatcher.group(3));
                return LocalDate.of(y, m, d);
            } catch (Exception ignored) {}
        }

        // Numeric format: DD-MM-YYYY or DD/MM/YYYY
        Matcher numMatcher = Pattern.compile("\\b(\\d{1,2})[-/](\\d{1,2})[-/](20\\d{2})\\b").matcher(text);
        if (numMatcher.find()) {
            try {
                int d = Integer.parseInt(numMatcher.group(1));
                int m = Integer.parseInt(numMatcher.group(2));
                int y = Integer.parseInt(numMatcher.group(3));
                return LocalDate.of(y, m, d);
            } catch (Exception ignored) {}
        }

        // Named Month format: e.g. "25 October 2026", "25th October 2026", "25 Oct 2026", "October 25, 2026"
        // Also: "25 October", "25th Oct", "30 October", "15 November"
        Pattern monthPattern = Pattern.compile(
                "(?i)\\b(?:on\\s+)?(\\d{1,2})(?:st|nd|rd|th)?\\s+(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)(?:\\s+(20\\d{2}))?\\b");
        Matcher mMatcher = monthPattern.matcher(text);
        if (mMatcher.find()) {
            try {
                int day = Integer.parseInt(mMatcher.group(1));
                Month month = parseMonth(mMatcher.group(2));
                int year = (mMatcher.group(3) != null) ? Integer.parseInt(mMatcher.group(3)) : today.getYear();

                LocalDate date = LocalDate.of(year, month, day);
                // If year wasn't specified and the date is in the past for this year, assume next year
                if (mMatcher.group(3) == null && date.isBefore(today)) {
                    date = date.plusYears(1);
                }
                return date;
            } catch (Exception ignored) {}
        }

        // Reversed month-first: "October 25, 2026" or "Oct 25"
        Pattern revMonthPattern = Pattern.compile(
                "(?i)\\b(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)\\s+(\\d{1,2})(?:st|nd|rd|th)?(?:,?\\s+(20\\d{2}))?\\b");
        Matcher revMatcher = revMonthPattern.matcher(text);
        if (revMatcher.find()) {
            try {
                Month month = parseMonth(revMatcher.group(1));
                int day = Integer.parseInt(revMatcher.group(2));
                int year = (revMatcher.group(3) != null) ? Integer.parseInt(revMatcher.group(3)) : today.getYear();

                LocalDate date = LocalDate.of(year, month, day);
                if (revMatcher.group(3) == null && date.isBefore(today)) {
                    date = date.plusYears(1);
                }
                return date;
            } catch (Exception ignored) {}
        }

        return null;
    }

    private static Month parseMonth(String raw) {
        String m = raw.toLowerCase(Locale.ENGLISH);
        if (m.startsWith("jan")) return Month.JANUARY;
        if (m.startsWith("feb")) return Month.FEBRUARY;
        if (m.startsWith("mar")) return Month.MARCH;
        if (m.startsWith("apr")) return Month.APRIL;
        if (m.startsWith("may")) return Month.MAY;
        if (m.startsWith("jun")) return Month.JUNE;
        if (m.startsWith("jul")) return Month.JULY;
        if (m.startsWith("aug")) return Month.AUGUST;
        if (m.startsWith("sep")) return Month.SEPTEMBER;
        if (m.startsWith("oct")) return Month.OCTOBER;
        if (m.startsWith("nov")) return Month.NOVEMBER;
        if (m.startsWith("dec")) return Month.DECEMBER;
        return Month.OCTOBER;
    }
}
