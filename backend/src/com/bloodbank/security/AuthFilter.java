package com.bloodbank.security;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/dashboard/*", "/api/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpResp = (HttpServletResponse) response;
        HttpSession session = httpReq.getSession(false);

        String contextPath = httpReq.getContextPath();
        String uri = httpReq.getRequestURI();
        String loginPage = contextPath + "/login.jsp";

        boolean loggedIn = (session != null && session.getAttribute("userId") != null);
        boolean loginRequest = uri.equals(loginPage) || uri.endsWith("LoginServlet");

        if (uri.contains("/api/locator") || uri.contains("/api/register-device")
                || uri.contains("/api/chat") || uri.contains("/api/emergency-broadcast")
                || uri.contains("/api/subscribe") || uri.contains("/api/demand-prediction")
                || uri.contains("/api/analytics") || uri.contains("/api/emergency-locations")
                || uri.contains("/api/intelligence-briefing")) {
            chain.doFilter(request, response);
            return;
        }

        // ❌ Not logged in
        if (!loggedIn && !loginRequest) {
            if (uri.startsWith(contextPath + "/api/")) {
                httpResp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                httpResp.sendRedirect(loginPage);
            }
            return;
        }

        // 🔐 ROLE-BASED ACCESS CONTROL
        if (loggedIn) {
            String role = (String) session.getAttribute("role");

            // Admin pages
            if (uri.startsWith(contextPath + "/dashboard/admin")) {
                if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
                    httpResp.sendRedirect(loginPage);
                    return;
                }
            }

            // Bank pages
            if (uri.startsWith(contextPath + "/dashboard/bank")) {
                if (role == null || !"BANK".equalsIgnoreCase(role)) {
                    httpResp.sendRedirect(loginPage);
                    return;
                }
            }

            // Donor pages
            if (uri.startsWith(contextPath + "/dashboard/donor")) {
                if (role == null || !"DONOR".equalsIgnoreCase(role)) {
                    httpResp.sendRedirect(loginPage);
                    return;
                }
            }
        }

        // ✅ All checks passed
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
