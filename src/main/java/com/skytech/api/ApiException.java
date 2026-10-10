package com.skytech.api;

/**
 * Clean application exception representing external API errors without exposing
 * internal keys, sensitive credentials, or raw stack traces to end users.
 */
public class ApiException extends Exception {

    private static final long serialVersionUID = 1L;

    public enum ErrorCategory {
        CONFIGURATION,
        AUTHENTICATION,
        AUTHORIZATION,
        CREDIT_EXHAUSTED,
        RATE_LIMIT,
        QUOTA_EXCEEDED,
        BAD_REQUEST,
        NOT_FOUND,
        SERVER_ERROR,
        NETWORK_TIMEOUT,
        GENERAL
    }

    private final int statusCode;
    private final ErrorCategory category;
    private final String userFriendlyMessage;

    public ApiException(String message) {
        this(message, 0, ErrorCategory.GENERAL, message);
    }

    public ApiException(String message, int statusCode) {
        this(message, statusCode, resolveCategory(statusCode, message), message);
    }

    public ApiException(String message, Throwable cause) {
        super(message, cause);
        this.statusCode = 0;
        this.category = ErrorCategory.GENERAL;
        this.userFriendlyMessage = message;
    }

    public ApiException(String message, int statusCode, ErrorCategory category, String userFriendlyMessage) {
        super(message);
        this.statusCode = statusCode;
        this.category = category != null ? category : resolveCategory(statusCode, message);
        this.userFriendlyMessage = userFriendlyMessage != null ? userFriendlyMessage : message;
    }

    private static ErrorCategory resolveCategory(int code, String msg) {
        if (code == 401) return ErrorCategory.AUTHENTICATION;
        if (code == 402) return ErrorCategory.CREDIT_EXHAUSTED;
        if (code == 403) return ErrorCategory.AUTHORIZATION;
        if (code == 429) {
            if (msg != null && (msg.toLowerCase().contains("quota") || msg.toLowerCase().contains("monthly") || msg.toLowerCase().contains("credit"))) {
                return ErrorCategory.CREDIT_EXHAUSTED;
            }
            return ErrorCategory.RATE_LIMIT;
        }
        if (code == 400) return ErrorCategory.BAD_REQUEST;
        if (code == 404) return ErrorCategory.NOT_FOUND;
        if (code >= 500) return ErrorCategory.SERVER_ERROR;
        return ErrorCategory.GENERAL;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public ErrorCategory getCategory() {
        return category;
    }

    public String getUserFriendlyMessage() {
        return userFriendlyMessage;
    }
}

