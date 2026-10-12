package com.skytech.airlines.booking.util;

import com.skytech.airlines.booking.config.AppConfig;

/**
 * Payment and Razorpay configuration utility.
 */
public final class PaymentConfig {

    private PaymentConfig() {}

    public static String getKeyId() {
        return AppConfig.getRazorpayKeyId();
    }

    public static String getKeySecret() {
        return AppConfig.getRazorpayKeySecret();
    }

    public static String getWebhookSecret() {
        return AppConfig.getRazorpayWebhookSecret();
    }

    public static String getCurrency() {
        return AppConfig.getCurrency();
    }

    public static long getSeatHoldSeconds() {
        return AppConfig.getSeatHoldSeconds();
    }
}
