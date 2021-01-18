package com.bada.app.config

import com.bada.app.auth.EmployeeDetailsService
import com.bada.app.auth.Role
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.web.servlet.invoke


@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
@Order(1)
class EmployeeSecurityConfig(
    val employeeDetailsService: EmployeeDetailsService
) : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity?) {
        http {
            securityMatcher("/management/**")
            authorizeRequests {
                authorize("/management/**", hasAnyRole(Role.WAREHOUSE_MANAGER.name, Role.WAREHOUSE_EMPLOYEE.name))
            }
            formLogin {
                loginPage = "/management/login"
                defaultSuccessUrl("/management/home", false)
                permitAll()
            }
            logout {
                logoutUrl = "/management/logout"
            }
            csrf {
                disable()
            }
        }

    }

    override fun configure(auth: AuthenticationManagerBuilder?) {
        auth?.userDetailsService(employeeDetailsService)
    }
}

