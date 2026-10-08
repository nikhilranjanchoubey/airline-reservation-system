package com.skytech.filter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.annotation.WebInitParam;
import java.io.IOException;

/**
 * Filter that enforces UTF-8 character encoding on all incoming requests and outgoing responses.
 */
@WebFilter(
    filterName = "CharacterEncodingFilter",
    urlPatterns = {"/*"},
    initParams = {
        @WebInitParam(name = "encoding", value = "UTF-8")
    }
)
public class CharacterEncodingFilter implements Filter {

    private String encoding = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String configuredEncoding = filterConfig.getInitParameter("encoding");
        if (configuredEncoding != null && !configuredEncoding.trim().isEmpty()) {
            this.encoding = configuredEncoding.trim();
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request.getCharacterEncoding() == null) {
            request.setCharacterEncoding(encoding);
        }
        response.setCharacterEncoding(encoding);
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if required
    }
}
