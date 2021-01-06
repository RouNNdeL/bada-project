package com.bada.app.config

import com.bada.app.auth.CustomerDetailsService
import com.bada.app.auth.EmployeeDetailsService
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter

@Configuration
@EnableWebSecurity
class EmployeeSecurityConfig(
    val employeeDetailsService: EmployeeDetailsService,
    val customerDetailsService: CustomerDetailsService
) : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity?) {
        http?.run {
            authorizeRequests()
                .antMatchers("/", "/index", "/js/*", "/css/*").permitAll()
                .and()
                .formLogin()
                .loginPage("/management/login")
                .and()
                .formLogin()
                .loginPage("/login")
                .permitAll()
                .and()
                .rememberMe()
        }
    }

    override fun configure(auth: AuthenticationManagerBuilder?) {
        auth?.run {
            userDetailsService(employeeDetailsService)
                .and()
                .userDetailsService(customerDetailsService)

        }
    }
}