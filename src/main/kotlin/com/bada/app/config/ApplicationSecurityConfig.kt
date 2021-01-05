package com.bada.app.config

import com.bada.app.auth.EmployeeDetailsService
import com.bada.app.auth.Permissions
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter

@Configuration
@EnableWebSecurity
class ApplicationSecurityConfig(
    val employeeDetailsService: EmployeeDetailsService
) : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity?) {
        http?.run {
            authorizeRequests()
                .antMatchers("/", "/index", "/js/*", "/css/*").permitAll()
                .and()
                .formLogin()
                .and()
                .rememberMe()
        }
    }

    override fun configure(auth: AuthenticationManagerBuilder?) {
        auth?.run {
            userDetailsService(employeeDetailsService)

        }
    }
}