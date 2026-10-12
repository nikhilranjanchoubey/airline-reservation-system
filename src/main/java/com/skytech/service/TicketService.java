package com.skytech.service;

import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.skytech.model.Booking;
import com.skytech.model.Passenger;
import com.skytech.model.Ticket;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service for generating electronic tickets, boarding documentation, and downloadable PDF tickets.
 */
public class TicketService {

    private static final Logger LOGGER = Logger.getLogger(TicketService.class.getName());

    private static final Color BRAND_NAVY = new Color(7, 26, 53);      // #071A35
    private static final Color BRAND_BLUE = new Color(22, 139, 255);   // #168BFF
    private static final Color BRAND_LIGHT = new Color(244, 248, 252); // #F4F8FC
    private static final Color TEXT_MUTED = new Color(100, 116, 139);  // #64748B
    private static final Color BORDER_COLOR = new Color(216, 227, 239);

    /**
     * Generates a beautifully formatted PDF E-Ticket document for a confirmed booking.
     *
     * @param booking confirmed booking entity
     * @param specificTicket optional individual passenger ticket (or null for all tickets)
     * @return byte array containing the generated PDF
     */
    public byte[] generateTicketPdf(Booking booking, Ticket specificTicket) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 36, 36);

        try {
            PdfWriter.getInstance(document, baos);
            document.open();

            // Fonts
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, BRAND_NAVY);
            Font subtitleFont = FontFactory.getFont(FontFactory.HELVETICA, 10, TEXT_MUTED);
            Font sectionHeadingFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BRAND_NAVY);
            Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, TEXT_MUTED);
            Font valueFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.BLACK);
            Font boldValueFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, Color.BLACK);
            Font accentFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BRAND_BLUE);
            Font pnrFont = FontFactory.getFont(FontFactory.COURIER_BOLD, 18, BRAND_BLUE);

            // 1. Header Banner
            PdfPTable headerTable = new PdfPTable(2);
            headerTable.setWidthPercentage(100);
            headerTable.setWidths(new float[]{60, 40});

            PdfPCell brandCell = new PdfPCell();
            brandCell.setBorder(Rectangle.NO_BORDER);
            brandCell.addElement(new Paragraph("SkyTech", titleFont));
            brandCell.addElement(new Paragraph("Electronic Ticket & Passenger Itinerary Receipt", subtitleFont));
            headerTable.addCell(brandCell);

            PdfPCell pnrCell = new PdfPCell();
            pnrCell.setBorder(Rectangle.NO_BORDER);
            pnrCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            Paragraph pnrLabel = new Paragraph("BOOKING REFERENCE / PNR", labelFont);
            pnrLabel.setAlignment(Element.ALIGN_RIGHT);
            Paragraph pnrVal = new Paragraph(booking.getPnr() != null ? booking.getPnr() : booking.getBookingReference(), pnrFont);
            pnrVal.setAlignment(Element.ALIGN_RIGHT);
            pnrCell.addElement(pnrLabel);
            pnrCell.addElement(pnrVal);
            headerTable.addCell(pnrCell);

            document.add(headerTable);
            document.add(new Paragraph(" "));

            // 2. Flight Information Card Table
            PdfPTable flightTable = new PdfPTable(4);
            flightTable.setWidthPercentage(100);
            flightTable.setWidths(new float[]{25, 25, 25, 25});
            flightTable.setSpacingBefore(10f);

            addHeaderCell(flightTable, "FLIGHT SUMMARY", 4, sectionHeadingFont);

            addCardCell(flightTable, "FLIGHT NUMBER", booking.getFlightNumber() != null ? booking.getFlightNumber() : "SK-101", labelFont, boldValueFont);
            addCardCell(flightTable, "CABIN CLASS", booking.getTravelClass() != null ? booking.getTravelClass() : "Economy", labelFont, boldValueFont);
            addCardCell(flightTable, "ROUTE", booking.getOriginCode() + " -> " + booking.getDestinationCode(), labelFont, boldValueFont);
            addCardCell(flightTable, "BOOKING STATUS", booking.getStatus(), labelFont, accentFont);

            addCardCell(flightTable, "DEPARTURE DATE", booking.getDepartureDate() != null ? booking.getDepartureDate().toString() : "Scheduled", labelFont, valueFont);
            addCardCell(flightTable, "DEPARTURE AIRPORT", booking.getOriginCode(), labelFont, valueFont);
            addCardCell(flightTable, "ARRIVAL AIRPORT", booking.getDestinationCode(), labelFont, valueFont);
            addCardCell(flightTable, "SEAT(S)", booking.getSeatNumbers() != null ? booking.getSeatNumbers() : "Assigned at Gate", labelFont, valueFont);

            document.add(flightTable);
            document.add(new Paragraph(" "));

            // 3. Passenger Details Table
            List<Passenger> passengers = booking.getPassengers();
            PdfPTable passTable = new PdfPTable(4);
            passTable.setWidthPercentage(100);
            passTable.setWidths(new float[]{40, 20, 20, 20});
            passTable.setSpacingBefore(10f);

            addHeaderCell(passTable, "PASSENGER DETAILS", 4, sectionHeadingFont);
            addColHeader(passTable, "Passenger Name", labelFont);
            addColHeader(passTable, "Type", labelFont);
            addColHeader(passTable, "Seat", labelFont);
            addColHeader(passTable, "Ticket Number", labelFont);

            if (passengers != null && !passengers.isEmpty()) {
                for (Passenger p : passengers) {
                    passTable.addCell(createCell(p.getFullName(), valueFont));
                    passTable.addCell(createCell(p.getPassengerType(), valueFont));
                    passTable.addCell(createCell(p.getSeatNumber() != null ? p.getSeatNumber() : "-", boldValueFont));
                    passTable.addCell(createCell(p.getTicketNumber() != null ? p.getTicketNumber() : "098-" + booking.getId(), valueFont));
                }
            } else {
                passTable.addCell(createCell("Valued Passenger", valueFont));
                passTable.addCell(createCell("Adult", valueFont));
                passTable.addCell(createCell(booking.getSeatNumbers() != null ? booking.getSeatNumbers() : "-", boldValueFont));
                passTable.addCell(createCell("098-" + booking.getId(), valueFont));
            }

            document.add(passTable);
            document.add(new Paragraph(" "));

            // 4. Payment & Fare Summary Table
            PdfPTable fareTable = new PdfPTable(2);
            fareTable.setWidthPercentage(100);
            fareTable.setWidths(new float[]{70, 30});
            fareTable.setSpacingBefore(10f);

            addHeaderCell(fareTable, "PAYMENT RECEIPT", 2, sectionHeadingFont);

            fareTable.addCell(createCell("Total Fare (Statutory Taxes & GST Included):", valueFont));
            fareTable.addCell(createRightCell("INR " + (booking.getTotalAmount() != null ? booking.getTotalAmount().toPlainString() : "0.00"), boldValueFont));

            fareTable.addCell(createCell("Payment Status:", valueFont));
            fareTable.addCell(createRightCell(booking.isConfirmed() ? "PAID (VERIFIED)" : booking.getStatus(), accentFont));

            fareTable.addCell(createCell("Contact Email:", valueFont));
            fareTable.addCell(createRightCell(booking.getContactEmail() != null ? booking.getContactEmail() : "Registered Account", valueFont));

            fareTable.addCell(createCell("Contact Phone:", valueFont));
            fareTable.addCell(createRightCell(booking.getContactPhone() != null ? booking.getContactPhone() : "-", valueFont));

            document.add(fareTable);
            document.add(new Paragraph(" "));

            // 5. Travel Guidance & Notice
            PdfPTable noticeTable = new PdfPTable(1);
            noticeTable.setWidthPercentage(100);
            noticeTable.setSpacingBefore(15f);

            PdfPCell noticeCell = new PdfPCell();
            noticeCell.setBackgroundColor(BRAND_LIGHT);
            noticeCell.setBorderColor(BORDER_COLOR);
            noticeCell.setPadding(12f);

            Paragraph noticeTitle = new Paragraph("IMPORTANT TRAVEL & CHECK-IN INFORMATION", labelFont);
            Paragraph noticeText1 = new Paragraph("- Airport check-in counters open 2 hours and close 60 minutes prior to scheduled departure.", valueFont);
            Paragraph noticeText2 = new Paragraph("- Cabin Baggage: 1 piece up to 7 kg. Check-in Baggage: 15 kg per adult/child.", valueFont);
            Paragraph noticeText3 = new Paragraph("- Please present this E-Ticket and a valid government photo ID at the airport security gate.", valueFont);
            Paragraph noticeText4 = new Paragraph("- SkyTech Airline Reservation System (Academic Capstone Project Demonstration).", subtitleFont);

            noticeCell.addElement(noticeTitle);
            noticeCell.addElement(noticeText1);
            noticeCell.addElement(noticeText2);
            noticeCell.addElement(noticeText3);
            noticeCell.addElement(noticeText4);
            noticeTable.addCell(noticeCell);

            document.add(noticeTable);

            document.close();
        } catch (DocumentException e) {
            LOGGER.log(Level.SEVERE, "Failed to render PDF Ticket: " + e.getMessage(), e);
        }

        return baos.toByteArray();
    }

    private void addHeaderCell(PdfPTable table, String text, int colspan, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setColspan(colspan);
        cell.setBackgroundColor(BRAND_LIGHT);
        cell.setBorderColor(BORDER_COLOR);
        cell.setPadding(8f);
        table.addCell(cell);
    }

    private void addColHeader(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new Color(230, 240, 250));
        cell.setBorderColor(BORDER_COLOR);
        cell.setPadding(6f);
        table.addCell(cell);
    }

    private void addCardCell(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell cell = new PdfPCell();
        cell.setBorderColor(BORDER_COLOR);
        cell.setPadding(6f);
        cell.addElement(new Paragraph(label, labelFont));
        cell.addElement(new Paragraph(value, valueFont));
        table.addCell(cell);
    }

    private PdfPCell createCell(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorderColor(BORDER_COLOR);
        cell.setPadding(6f);
        return cell;
    }

    private PdfPCell createRightCell(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorderColor(BORDER_COLOR);
        cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        cell.setPadding(6f);
        return cell;
    }
}
