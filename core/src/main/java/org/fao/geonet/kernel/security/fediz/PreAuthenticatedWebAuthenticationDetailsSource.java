package org.fao.geonet.kernel.security.fediz;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.cxf.fediz.core.FedizPrincipal;
import org.apache.cxf.fediz.spring.SpringFedizMessageSource;
import org.fao.geonet.ApplicationContextHolder;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.security.authentication.AuthenticationDetailsSource;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedGrantedAuthoritiesWebAuthenticationDetails;

/**
 * Implementation of AuthenticationDetailsSource which converts the user's J2EE roles (as obtained by calling
 * {@link HttpServletRequest#isUserInRole(String)}) into {@code GrantedAuthority}s and stores these in the authentication
 * details object.
 *
 */
public class PreAuthenticatedWebAuthenticationDetailsSource
        implements AuthenticationDetailsSource<HttpServletRequest, PreAuthenticatedGrantedAuthoritiesWebAuthenticationDetails>,
        InitializingBean {

    protected final Log logger = LogFactory.getLog(getClass());
    protected MessageSourceAccessor messages = SpringFedizMessageSource.getAccessor();

    /**
     * Check that all required properties have been set.
     */
    public void afterPropertiesSet() throws Exception {
    }

    /**
     * Builds the authentication details object.
     *
     * @see org.springframework.security.authentication.AuthenticationDetailsSource#buildDetails(Object)
     */
    public PreAuthenticatedGrantedAuthoritiesWebAuthenticationDetails buildDetails(HttpServletRequest context) {
        try {
            FedizPrincipal principal = (FedizPrincipal) context.getUserPrincipal();
            FedizClaimsUserDetailsMapper fedizClaimsUserDetailsMapper = ApplicationContextHolder.get().getBean(FedizClaimsUserDetailsMapper.class);
            UserDetails user = fedizClaimsUserDetailsMapper.mapUserFromClaimsAndRoles(principal.getClaims());
            PreAuthenticatedGrantedAuthoritiesWebAuthenticationDetails result =
                    new PreAuthenticatedGrantedAuthoritiesWebAuthenticationDetails(context, user.getAuthorities());

            return result;
        } catch (UsernameNotFoundException notFound) {
            throw new BadCredentialsException(messages.getMessage(
                    "AbstractUserDetailsAuthenticationProvider.badCredentials", "Bad credentials"));
        }
    }

}
