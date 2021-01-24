package com.bada.app.config

import com.bada.app.auth.CustomerDetailsService
import com.bada.app.auth.EmployeeDetailsService
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.web.servlet.invoke




@Configuration
@EnableWebSecurity
class DefaultSecurityConfig (
    val employeeDetailsService: EmployeeDetailsService,
    val customerDetailsService: CustomerDetailsService
        ) : WebSecurityConfigurerAdapter()  {
    override fun configure(http: HttpSecurity?) {
        http {
            securityMatcher("/")
            authorizeRequests {
                authorize("/", permitAll)
                authorize("/register", permitAll)
            }
            csrf {
                disable()
            }
        }
    }
}