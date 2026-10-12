package com.skytech.service;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.skytech.model.Booking;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import com.skytech.model.Passenger;
import com.skytech.model.Payment;
import com.skytech.model.Ticket;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service for generating premium electronic flight tickets and boarding passes for SkyTech.
 * Produces clean, print-friendly, airline-grade PDF documents using OpenPDF.
 */
public class TicketService {

    private static final Logger LOGGER = Logger.getLogger(TicketService.class.getName());

    // SkyTech Brand Color Palette
    private static final Color NAVY_PRIMARY = new Color(7, 26, 53);       // #071A35 Deep Aviation Navy
    private static final Color BLUE_ACCENT = new Color(2, 132, 199);      // #0284C7 Aviation Blue
    private static final Color BLUE_DARK = new Color(11, 45, 82);         // #0B2D52
    private static final Color BG_LIGHT = new Color(248, 250, 252);       // #F8FAFC Clean Light Gray
    private static final Color BG_TINT = new Color(240, 246, 252);        // #F0F6FC Aviation Tint
    private static final Color TEXT_MAIN = new Color(15, 23, 42);         // #0F172A Slate 900
    private static final Color TEXT_MUTED = new Color(100, 116, 139);     // #64748B Slate 500
    private static final Color BORDER_LIGHT = new Color(226, 232, 240);   // #E2E8F0
    private static final Color GREEN_CONFIRMED = new Color(22, 163, 74);  // #16A34A Success Green

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("EEE, dd MMM yyyy");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    /**
     * Generates a beautifully formatted PDF E-Ticket document for a confirmed booking.
     *
     * @param booking confirmed booking entity with passenger, flight, and payment details
     * @param specificTicket optional individual passenger ticket (or null for complete manifest)
     * @return byte array containing the generated PDF
     */
    public byte[] generateTicketPdf(Booking booking, Ticket specificTicket) {
        if (booking == null) {
            return new byte[0];
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 32, 32, 32, 32);

        try {
            PdfWriter writer = PdfWriter.getInstance(document, baos);
            writer.setPdfVersion(PdfWriter.PDF_VERSION_1_7);
            
            // Document Metadata
            String pnr = getPnrSafe(booking);
            document.addTitle("SkyTech Electronic Ticket - " + pnr);
            document.addSubject("Electronic Flight Ticket and Itinerary Receipt");
            document.addAuthor("SkyTech");
            document.addCreator("SkyTech Flight Operations System");

            document.open();

            // Font definitions
            Font brandFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, NAVY_PRIMARY);
            Font brandSubFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, BLUE_ACCENT);
            Font sectionTitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, NAVY_PRIMARY);
            Font pnrLabelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, TEXT_MUTED);
            Font pnrValFont = FontFactory.getFont(FontFactory.COURIER_BOLD, 16, BLUE_ACCENT);
            Font airportCodeFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, NAVY_PRIMARY);
            Font arrowFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BLUE_ACCENT);
            Font cityNameFont = FontFactory.getFont(FontFactory.HELVETICA, 10, TEXT_MUTED);
            Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 7, TEXT_MUTED);
            Font valFont = FontFactory.getFont(FontFactory.HELVETICA, 9, TEXT_MAIN);
            Font valBoldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, TEXT_MAIN);
            Font statusFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, GREEN_CONFIRMED);
            Font footerFont = FontFactory.getFont(FontFactory.HELVETICA, 8, TEXT_MUTED);
            Font noticeFont = FontFactory.getFont(FontFactory.HELVETICA, 8, TEXT_MAIN);

            // =================================================================
            // 1. TOP HEADER BANNER: BRANDING + PNR & STATUS
            // =================================================================
            PdfPTable headerTable = new PdfPTable(2);
            headerTable.setWidthPercentage(100);
            headerTable.setWidths(new float[]{55, 45});

            // Brand cell
            PdfPCell brandCell = new PdfPCell();
            brandCell.setBorder(Rectangle.NO_BORDER);
            brandCell.setPadding(0);
            
            Paragraph pBrand = new Paragraph("SkyTech", brandFont);
            Paragraph pTagline = new Paragraph("OFFICIAL ELECTRONIC TICKET & BOARDING PASS", brandSubFont);
            brandCell.addElement(pBrand);
            brandCell.addElement(pTagline);
            headerTable.addCell(brandCell);

            // PNR & Status Cell (Right)
            PdfPCell pnrCell = new PdfPCell();
            pnrCell.setBorder(Rectangle.BOX);
            pnrCell.setBorderColor(BORDER_LIGHT);
            pnrCell.setBackgroundColor(BG_TINT);
            pnrCell.setPadding(8);
            pnrCell.setHorizontalAlignment(Element.ALIGN_RIGHT);

            Paragraph pnrLbl = new Paragraph("BOOKING REFERENCE (PNR)", pnrLabelFont);
            pnrLbl.setAlignment(Element.ALIGN_RIGHT);
            Paragraph pnrTxt = new Paragraph(pnr, pnrValFont);
            pnrTxt.setAlignment(Element.ALIGN_RIGHT);
            
            String statusText = (booking.getStatus() != null && booking.getStatus().equalsIgnoreCase("CONFIRMED"))
                    ? "STATUS: CONFIRMED - TICKET ISSUED"
                    : "STATUS: " + (booking.getStatus() != null ? booking.getStatus() : "PENDING");
            Paragraph statusPara = new Paragraph(statusText, statusFont);
            statusPara.setAlignment(Element.ALIGN_RIGHT);

            pnrCell.addElement(pnrLbl);
            pnrCell.addElement(pnrTxt);
            pnrCell.addElement(statusPara);
            headerTable.addCell(pnrCell);

            document.add(headerTable);
            document.add(new Paragraph(" "));

            // =================================================================
            // 2. FLIGHT ITINERARY & JOURNEY SUMMARY
            // =================================================================
            PdfPTable journeyHeader = new PdfPTable(1);
            journeyHeader.setWidthPercentage(100);
            addSectionBanner(journeyHeader, "FLIGHT ITINERARY & ROUTE", sectionTitleFont);
            document.add(journeyHeader);

            PdfPTable routeTable = new PdfPTable(3);
            routeTable.setWidthPercentage(100);
            routeTable.setWidths(new float[]{42, 16, 42});

            String originCode = booking.getOriginCode() != null ? booking.getOriginCode() : "ORIG";
            String destCode = booking.getDestinationCode() != null ? booking.getDestinationCode() : "DEST";
            String originCity = getOriginCitySafe(booking);
            String destCity = getDestinationCitySafe(booking);
            String depTimeStr = getDepartureTimeSafe(booking);
            String arrTimeStr = getArrivalTimeSafe(booking);
            String depDateStr = getDepartureDateSafe(booking);

            // Origin Card
            PdfPCell origCell = new PdfPCell();
            origCell.setBorder(Rectangle.BOX);
            origCell.setBorderColor(BORDER_LIGHT);
            origCell.setBackgroundColor(BG_LIGHT);
            origCell.setPadding(8);
            origCell.addElement(new Paragraph("DEPARTURE", labelFont));
            origCell.addElement(new Paragraph(originCode, airportCodeFont));
            origCell.addElement(new Paragraph(originCity, cityNameFont));
            origCell.addElement(new Paragraph(depDateStr + " at " + depTimeStr, valBoldFont));
            routeTable.addCell(origCell);

            // Center Route Indicator
            PdfPCell centerCell = new PdfPCell();
            centerCell.setBorder(Rectangle.NO_BORDER);
            centerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            centerCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            centerCell.setPadding(8);
            Paragraph arrowPara = new Paragraph("----->", arrowFont);
            arrowPara.setAlignment(Element.ALIGN_CENTER);
            Paragraph flightNumPara = new Paragraph(getFlightNumSafe(booking), valBoldFont);
            flightNumPara.setAlignment(Element.ALIGN_CENTER);
            centerCell.addElement(arrowPara);
            centerCell.addElement(flightNumPara);
            routeTable.addCell(centerCell);

            // Destination Card
            PdfPCell destCell = new PdfPCell();
            destCell.setBorder(Rectangle.BOX);
            destCell.setBorderColor(BORDER_LIGHT);
            destCell.setBackgroundColor(BG_LIGHT);
            destCell.setPadding(8);
            destCell.addElement(new Paragraph("ARRIVAL", labelFont));
            destCell.addElement(new Paragraph(destCode, airportCodeFont));
            destCell.addElement(new Paragraph(destCity, cityNameFont));
            destCell.addElement(new Paragraph(depDateStr + " at " + arrTimeStr, valBoldFont));
            routeTable.addCell(destCell);

            document.add(routeTable);

            // Flight metadata strip
            PdfPTable metaTable = new PdfPTable(4);
            metaTable.setWidthPercentage(100);
            metaTable.setWidths(new float[]{25, 25, 25, 25});

            addCardCell(metaTable, "FLIGHT NUMBER", getFlightNumSafe(booking), labelFont, valBoldFont);
            addCardCell(metaTable, "CABIN CLASS", booking.getTravelClass() != null ? booking.getTravelClass() : "Economy", labelFont, valBoldFont);
            addCardCell(metaTable, "BOARDING TIME", getBoardingTimeSafe(depTimeStr), labelFont, valBoldFont);
            addCardCell(metaTable, "GATE CLOSES", getGateClosingTimeSafe(depTimeStr), labelFont, valBoldFont);

            document.add(metaTable);
            document.add(new Paragraph(" "));

            // =================================================================
            // 3. PASSENGER MANIFEST & SEAT ASSIGNMENTS
            // =================================================================
            PdfPTable passHeader = new PdfPTable(1);
            passHeader.setWidthPercentage(100);
            addSectionBanner(passHeader, "PASSENGER MANIFEST & SEATS", sectionTitleFont);
            document.add(passHeader);

            PdfPTable passTable = new PdfPTable(5);
            passTable.setWidthPercentage(100);
            passTable.setWidths(new float[]{36, 16, 16, 16, 16});

            addColHeader(passTable, "PASSENGER NAME", labelFont);
            addColHeader(passTable, "TYPE", labelFont);
            addColHeader(passTable, "SEAT", labelFont);
            addColHeader(passTable, "TICKET NUMBER", labelFont);
            addColHeader(passTable, "BAGGAGE", labelFont);

            List<Passenger> passengers = booking.getPassengers();
            if (passengers != null && !passengers.isEmpty()) {
                for (Passenger p : passengers) {
                    passTable.addCell(createCell(p.getFullName(), valBoldFont));
                    passTable.addCell(createCell(p.getPassengerType() != null ? p.getPassengerType() : "Adult", valFont));
                    String seat = p.getSeatNumber() != null ? p.getSeatNumber() : (booking.getSeatNumbers() != null ? booking.getSeatNumbers() : "Assigned at Gate");
                    passTable.addCell(createCell(seat, valBoldFont));
                    String ticketNum = p.getTicketNumber() != null ? p.getTicketNumber() : ("098-" + booking.getId());
                    passTable.addCell(createCell(ticketNum, valFont));
                    passTable.addCell(createCell("15kg Check-in / 7kg Cabin", valFont));
                }
            } else {
                passTable.addCell(createCell("Passenger (Confidential)", valBoldFont));
                passTable.addCell(createCell("Adult", valFont));
                passTable.addCell(createCell(booking.getSeatNumbers() != null ? booking.getSeatNumbers() : "Assigned at Gate", valBoldFont));
                passTable.addCell(createCell("098-" + booking.getId(), valFont));
                passTable.addCell(createCell("15kg Check-in / 7kg Cabin", valFont));
            }
            document.add(passTable);
            document.add(new Paragraph(" "));

            // =================================================================
            // 4. FARE BREAKDOWN & PAYMENT RECEIPT
            // =================================================================
            PdfPTable payHeader = new PdfPTable(1);
            payHeader.setWidthPercentage(100);
            addSectionBanner(payHeader, "FARE BREAKDOWN & PAYMENT DETAILS", sectionTitleFont);
            document.add(payHeader);

            PdfPTable fareTable = new PdfPTable(4);
            fareTable.setWidthPercentage(100);
            fareTable.setWidths(new float[]{30, 20, 25, 25});

            BigDecimal total = booking.getTotalAmount() != null ? booking.getTotalAmount() : BigDecimal.ZERO;
            // Base fare ~82%, Taxes/GST ~18%
            BigDecimal taxes = total.multiply(new BigDecimal("0.18")).setScale(2, java.math.RoundingMode.HALF_UP);
            BigDecimal baseFare = total.subtract(taxes);

            addCardCell(fareTable, "BASE AIRFARE", "INR " + baseFare.toPlainString(), labelFont, valFont);
            addCardCell(fareTable, "TAXES & GST (18%)", "INR " + taxes.toPlainString(), labelFont, valFont);
            addCardCell(fareTable, "TOTAL AMOUNT PAID", "INR " + total.toPlainString(), labelFont, valBoldFont);
            
            String payStatus = booking.isConfirmed() ? "PAID (VERIFIED)" : (booking.getStatus() != null ? booking.getStatus() : "PENDING");
            addCardCell(fareTable, "PAYMENT STATUS", payStatus, labelFont, statusFont);

            addCardCell(fareTable, "CONTACT EMAIL", booking.getContactEmail() != null ? booking.getContactEmail() : "Registered Passenger", labelFont, valFont);
            addCardCell(fareTable, "CONTACT PHONE", booking.getContactPhone() != null ? booking.getContactPhone() : "-", labelFont, valFont);
            
            Payment payment = booking.getPayment();
            String payMethod = (payment != null && payment.getPaymentMethod() != null) ? payment.getPaymentMethod() : "Razorpay Online Payment";
            addCardCell(fareTable, "PAYMENT METHOD", payMethod, labelFont, valFont);
            
            String rzpId = (payment != null && payment.getRazorpayPaymentId() != null) ? payment.getRazorpayPaymentId() : ("TXN-" + booking.getId());
            addCardCell(fareTable, "TRANSACTION REF", rzpId, labelFont, valFont);

            document.add(fareTable);
            document.add(new Paragraph(" "));

            // =================================================================
            // 5. VECTOR BARCODE (Code128) & VERIFICATION CODE
            // =================================================================
            PdfPTable barcodeTable = new PdfPTable(1);
            barcodeTable.setWidthPercentage(100);

            PdfPCell barCell = new PdfPCell();
            barCell.setBorder(Rectangle.BOX);
            barCell.setBorderColor(BORDER_LIGHT);
            barCell.setBackgroundColor(BG_LIGHT);
            barCell.setPadding(10);
            barCell.setHorizontalAlignment(Element.ALIGN_CENTER);

            try {
                Barcode128 barcode = new Barcode128();
                barcode.setCode(pnr != null ? pnr : "SKYT-" + booking.getId());
                barcode.setCodeType(Barcode128.CODE128);
                barcode.setBarHeight(32f);
                barcode.setX(1.1f);
                Image barcodeImg = barcode.createImageWithBarcode(writer.getDirectContent(), null, null);
                barcodeImg.setAlignment(Element.ALIGN_CENTER);
                barCell.addElement(barcodeImg);
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING, "Vector barcode generation fallback: " + ex.getMessage());
                Paragraph fallbackPnr = new Paragraph("VERIFICATION CODE: " + pnr, pnrValFont);
                fallbackPnr.setAlignment(Element.ALIGN_CENTER);
                barCell.addElement(fallbackPnr);
            }

            Paragraph verifyPara = new Paragraph("Electronic Ticket Verification • SkyTech Flight Operations Management", footerFont);
            verifyPara.setAlignment(Element.ALIGN_CENTER);
            barCell.addElement(verifyPara);
            barcodeTable.addCell(barCell);

            document.add(barcodeTable);
            document.add(new Paragraph(" "));

            // =================================================================
            // 6. IMPORTANT TRAVEL & CHECK-IN GUIDELINES
            // =================================================================
            PdfPTable noticeTable = new PdfPTable(1);
            noticeTable.setWidthPercentage(100);

            PdfPCell noticeCell = new PdfPCell();
            noticeCell.setBorder(Rectangle.BOX);
            noticeCell.setBorderColor(BORDER_LIGHT);
            noticeCell.setBackgroundColor(BG_TINT);
            noticeCell.setPadding(10);

            Paragraph noticeHeader = new Paragraph("IMPORTANT TRAVEL INFORMATION & TERMS OF CARRIAGE", labelFont);
            noticeCell.addElement(noticeHeader);

            noticeCell.addElement(new Paragraph("1. Airport Reporting: Check-in counters open 2 hours and close 60 minutes prior to scheduled departure.", noticeFont));
            noticeCell.addElement(new Paragraph("2. Boarding Gates: Gates close 25 minutes prior to scheduled departure. Passengers arriving late will not be accommodated.", noticeFont));
            noticeCell.addElement(new Paragraph("3. Mandatory Identity: All passengers must present a government-issued photo ID (Passport / Aadhaar / Voter ID) matching the ticket name.", noticeFont));
            noticeCell.addElement(new Paragraph("4. Baggage Allowance: 15 kg check-in baggage and 1 piece hand baggage up to 7 kg per adult passenger.", noticeFont));
            noticeCell.addElement(new Paragraph("5. SkyTech Support: 24x7 Customer Care: support@skytech.com | Toll-free: 1800-SKY-TECH.", footerFont));

            noticeTable.addCell(noticeCell);
            document.add(noticeTable);

            // Document Footer / Sign-off
            Paragraph footerNote = new Paragraph("Thank you for choosing SkyTech. Have a pleasant flight!", footerFont);
            footerNote.setAlignment(Element.ALIGN_CENTER);
            footerNote.setSpacingBefore(8f);
            document.add(footerNote);

            document.close();
        } catch (DocumentException e) {
            LOGGER.log(Level.SEVERE, "Failed to render PDF Ticket: " + e.getMessage(), e);
        }

        return baos.toByteArray();
    }

    private void addSectionBanner(PdfPTable table, String title, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(title, font));
        cell.setBackgroundColor(BG_TINT);
        cell.setBorderColor(BORDER_LIGHT);
        cell.setPadding(6f);
        table.addCell(cell);
    }

    private void addColHeader(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new Color(235, 243, 252));
        cell.setBorderColor(BORDER_LIGHT);
        cell.setPadding(5f);
        table.addCell(cell);
    }

    private void addCardCell(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell cell = new PdfPCell();
        cell.setBorderColor(BORDER_LIGHT);
        cell.setPadding(6f);
        cell.addElement(new Paragraph(label, labelFont));
        cell.addElement(new Paragraph(value, valueFont));
        table.addCell(cell);
    }

    private PdfPCell createCell(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text != null ? text : "-", font));
        cell.setBorderColor(BORDER_LIGHT);
        cell.setPadding(5f);
        return cell;
    }

    private String getPnrSafe(Booking booking) {
        if (booking.getPnr() != null && !booking.getPnr().trim().isEmpty()) {
            return booking.getPnr();
        }
        if (booking.getBookingReference() != null && !booking.getBookingReference().trim().isEmpty()) {
            return booking.getBookingReference();
        }
        return "SKYT-" + booking.getId();
    }

    private String getFlightNumSafe(Booking booking) {
        if (booking.getFlightNumber() != null && !booking.getFlightNumber().trim().isEmpty()) {
            return booking.getFlightNumber();
        }
        FlightSchedule schedule = booking.getSchedule();
        if (schedule != null && schedule.getFlight() != null && schedule.getFlight().getFlightNumber() != null) {
            return schedule.getFlight().getFlightNumber();
        }
        return "SK-101";
    }

    private String getOriginCitySafe(Booking booking) {
        FlightSchedule schedule = booking.getSchedule();
        if (schedule != null && schedule.getFlight() != null && schedule.getFlight().getSourceAirport() != null) {
            String city = schedule.getFlight().getSourceAirport().getCity();
            if (city != null && !city.trim().isEmpty()) {
                return city;
            }
        }
        return booking.getOriginCode() != null ? booking.getOriginCode() : "Departure City";
    }

    private String getDestinationCitySafe(Booking booking) {
        FlightSchedule schedule = booking.getSchedule();
        if (schedule != null && schedule.getFlight() != null && schedule.getFlight().getDestinationAirport() != null) {
            String city = schedule.getFlight().getDestinationAirport().getCity();
            if (city != null && !city.trim().isEmpty()) {
                return city;
            }
        }
        return booking.getDestinationCode() != null ? booking.getDestinationCode() : "Arrival City";
    }

    private String getDepartureDateSafe(Booking booking) {
        if (booking.getDepartureDate() != null) {
            return booking.getDepartureDate().format(DATE_FMT);
        }
        FlightSchedule schedule = booking.getSchedule();
        if (schedule != null && schedule.getFlightDate() != null) {
            return schedule.getFlightDate().toLocalDate().format(DATE_FMT);
        }
        return LocalDate.now().format(DATE_FMT);
    }

    private String getDepartureTimeSafe(Booking booking) {
        FlightSchedule schedule = booking.getSchedule();
        if (schedule != null && schedule.getFlight() != null && schedule.getFlight().getDepartureTime() != null) {
            return schedule.getFlight().getDepartureTime().toLocalTime().format(TIME_FMT);
        }
        return "10:00";
    }

    private String getArrivalTimeSafe(Booking booking) {
        FlightSchedule schedule = booking.getSchedule();
        if (schedule != null && schedule.getFlight() != null && schedule.getFlight().getArrivalTime() != null) {
            return schedule.getFlight().getArrivalTime().toLocalTime().format(TIME_FMT);
        }
        return "12:15";
    }

    private String getBoardingTimeSafe(String depTimeStr) {
        try {
            java.time.LocalTime dep = java.time.LocalTime.parse(depTimeStr, TIME_FMT);
            return dep.minusMinutes(45).format(TIME_FMT);
        } catch (Exception ignored) {
            return "45 mins prior";
        }
    }

    private String getGateClosingTimeSafe(String depTimeStr) {
        try {
            java.time.LocalTime dep = java.time.LocalTime.parse(depTimeStr, TIME_FMT);
            return dep.minusMinutes(25).format(TIME_FMT);
        } catch (Exception ignored) {
            return "25 mins prior";
        }
    }
}
