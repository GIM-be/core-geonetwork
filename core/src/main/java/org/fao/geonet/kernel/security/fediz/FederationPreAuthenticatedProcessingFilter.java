/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.fao.geonet.kernel.security.fediz;

import java.io.IOException;
import java.security.Principal;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.cxf.fediz.core.FedizPrincipal;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.NullRememberMeServices;
import org.springframework.security.web.authentication.RememberMeServices;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.security.web.authentication.preauth.AbstractPreAuthenticatedProcessingFilter;
import org.springframework.util.Assert;

/**
 * This AbstractPreAuthenticatedProcessingFilter implementation is based on the
 * J2EE container-based authentication mechanism. It will use the J2EE user
 * principal name as the pre-authenticated principal and the WS-Federation signin request
 * as the credentials.
 */
public class FederationPreAuthenticatedProcessingFilter extends AbstractPreAuthenticatedProcessingFilter {

    private static final String SECURITY_TOKEN_ATTR = "org.apache.fediz.SECURITY_TOKEN";
    private AuthenticationSuccessHandler successHandler = new SavedRequestAwareAuthenticationSuccessHandler();
    private AuthenticationFailureHandler failureHandler = new SimpleUrlAuthenticationFailureHandler();
    private RememberMeServices rememberMeServices = new NullRememberMeServices();

    /**
     * Return the J2EE user name.
     */
    protected Object getPreAuthenticatedPrincipal(HttpServletRequest httpRequest) {
        Principal principal = httpRequest.getUserPrincipal();
        if (logger.isDebugEnabled()) {
            logger.debug("PreAuthenticated J2EE principal: "
                         + principal == null ? null : principal.getName());
        }
        return principal;
    }

    /**
     * For J2EE container-based authentication there is no generic way to
     * retrieve the credentials, as such this method returns a fixed dummy
     * value.
     */
    protected Object getPreAuthenticatedCredentials(HttpServletRequest httpRequest) {
        Principal principal = httpRequest.getUserPrincipal() == null ? null : httpRequest.getUserPrincipal();
        if (principal instanceof FedizPrincipal) {
            Object obj = httpRequest.getSession(false).getAttribute(SECURITY_TOKEN_ATTR);
            if (obj != null)  {
                return obj;
            } else {
                logger.error("Session must contain Federation response");
                throw new IllegalStateException("Session must contain Federation response");
            }
        } else {
            logger.error("Principal must be instance of FedizPrincipal: " + principal);
            throw new IllegalStateException("Principal must be instance of FedizPrincipal");
        }
        //return "N/A";
    }


    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        Principal principal = httpRequest.getUserPrincipal() == null ? null : httpRequest.getUserPrincipal();
        if (principal instanceof FedizPrincipal) {
            super.doFilter(request, response, chain);
        } else {
            chain.doFilter(request, response);            
        }
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, Authentication authResult) {
        super.successfulAuthentication(request, response, authResult);          
        try {
            successHandler.onAuthenticationSuccess(request, response, authResult);
        } catch (IOException | ServletException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void unsuccessfulAuthentication(HttpServletRequest request, HttpServletResponse response, AuthenticationException failed) {
        super.unsuccessfulAuthentication(request, response, failed);          
        rememberMeServices.loginFail(request, response);
        try {
            failureHandler.onAuthenticationFailure(request, response, failed);
        } catch (IOException | ServletException e) {
            e.printStackTrace();
        }
    }

    /**
     * Sets the strategy used to handle a successful authentication.
     * By default a {@link SavedRequestAwareAuthenticationSuccessHandler} is used.
     */
    public void setAuthenticationSuccessHandler(AuthenticationSuccessHandler successHandler) {
        Assert.notNull(successHandler, "successHandler cannot be null");
        this.successHandler = successHandler;
    }

    public void setAuthenticationFailureHandler(AuthenticationFailureHandler failureHandler) {
        Assert.notNull(failureHandler, "failureHandler cannot be null");
        this.failureHandler = failureHandler;
    }

    protected AuthenticationSuccessHandler getSuccessHandler() {
        return successHandler;
    }

    protected AuthenticationFailureHandler getFailureHandler() {
        return failureHandler;
    }
}
