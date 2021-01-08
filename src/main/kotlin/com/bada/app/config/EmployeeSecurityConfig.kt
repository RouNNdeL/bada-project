package com.bada.app.config

import com.bada.app.auth.EmployeeDetailsService
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
@Order(1)
class EmployeeSecurityConfig(
    val employeeDetailsService: EmployeeDetailsService
) : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity?) {
        http?.run {
            authorizeRequests()
                .antMatchers("/", "/index", "/static/**").permitAll()
                .and()
                .formLogin()
                .loginProcessingUrl("/management/login")
                .loginPage("/management/login")
                .usernameParameter("username")
                .passwordParameter("password")
                .defaultSuccessUrl("/")
                .permitAll()
                .and()
                .rememberMe()
                .and()
                .csrf().disable()
        }
    }

    override fun configure(auth: AuthenticationManagerBuilder?) {
        auth?.run {
            userDetailsService(employeeDetailsService)
        }
    }
}