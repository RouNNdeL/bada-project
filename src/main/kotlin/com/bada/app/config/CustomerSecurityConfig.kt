package com.bada.app.config

import com.bada.app.auth.CustomerDetailsService
import com.bada.app.auth.Role
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.web.servlet.invoke

@Configuration
@Order(2)
class CustomerSecurityConfig(
    val customerDetailsService: CustomerDetailsService
) : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity?) {
        http {
            securityMatcher("/user/**")
            authorizeRequests {
                authorize("/user/**", hasAnyRole(Role.CUSTOMER.name))
            }
            formLogin {
                loginPage = "/user/login"
                defaultSuccessUrl("/", true)
                permitAll()
            }
            logout {
                logoutUrl = "/user/logout"
            }
            csrf {
                disable()
            }
        }
    }

    override fun configure(auth: AuthenticationManagerBuilder?) {
        auth?.userDetailsService(customerDetailsService)
    }
}