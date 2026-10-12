package com.skytech.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Represents a booking cancellation and refund record.
 */
public class Cancellation implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long cancellationId;
    private Long bookingId;
    private String pnr;
    private String cancellationReason;
    private BigDecimal cancellationFee;
    private BigDecimal refundAmount;
    private String refundStatus; // PENDING, COMPLETED, REJECTED
    private String refundReference;
    private Long cancelledByUserId;
    private Timestamp cancelledAt;

    public Cancellation() {
        this.cancellationFee = BigDecimal.ZERO;
        this.refundAmount = BigDecimal.ZERO;
        this.refundStatus = "PENDING";
    }

    public Long getCancellationId() {
        return cancellationId;
    }

    public void setCancellationId(Long cancellationId) {
        this.cancellationId = cancellationId;
    }

    public Long getBookingId() {
        return bookingId;
    }

    public void setBookingId(Long bookingId) {
        this.bookingId = bookingId;
    }

    public String getPnr() {
        return pnr;
    }

    public void setPnr(String pnr) {
        this.pnr = pnr;
    }

    public String getCancellationReason() {
        return cancellationReason;
    }

    public void setCancellationReason(String cancellationReason) {
        this.cancellationReason = cancellationReason;
    }

    public BigDecimal getCancellationFee() {
        return cancellationFee;
    }

    public void setCancellationFee(BigDecimal cancellationFee) {
        this.cancellationFee = cancellationFee;
    }

    public BigDecimal getRefundAmount() {
        return refundAmount;
    }

    public void setRefundAmount(BigDecimal refundAmount) {
        this.refundAmount = refundAmount;
    }

    public String getRefundStatus() {
        return refundStatus;
    }

    public void setRefundStatus(String refundStatus) {
        this.refundStatus = refundStatus;
    }

    public String getRefundReference() {
        return refundReference;
    }

    public void setRefundReference(String refundReference) {
        this.refundReference = refundReference;
    }

    public Long getCancelledByUserId() {
        return cancelledByUserId;
    }

    public void setCancelledByUserId(Long cancelledByUserId) {
        this.cancelledByUserId = cancelledByUserId;
    }

    public Timestamp getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(Timestamp cancelledAt) {
        this.cancelledAt = cancelledAt;
    }
}
