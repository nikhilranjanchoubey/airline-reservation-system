package com.skytech.api;

/**
 * Clean application exception representing external API errors without exposing
 * internal keys, sensitive credentials, or raw stack traces to end users.
 */
public class ApiException extends Exception {

    private static final long serialVersionUID = 1L;
    private final int statusCode;

    public ApiException(String message) {
        super(message);
        this.statusCode = 0;
    }

    public ApiException(String message, int statusCode) {
        super(message);
        this.statusCode = statusCode;
    }

    public ApiException(String message, Throwable cause) {
        super(message, cause);
        this.statusCode = 0;
    }

    public int getStatusCode() {
        return statusCode;
    }
}
