package com.bada.app.config

import com.bada.app.auth.CustomerDetailsService
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter

@Configuration
@Order(2)
class CustomerSecurityConfig(
    val customerDetailsService: CustomerDetailsService
) : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity?) {
        http?.run {
            authorizeRequests()
                .antMatchers("/", "/index", "/js/*", "/css/*").permitAll()
                .and()
                .formLogin()
                .loginPage("/login")
                .defaultSuccessUrl("/")
                .permitAll()
                .and()
                .rememberMe()
        }
    }

    override fun configure(auth: AuthenticationManagerBuilder?) {
        auth?.run {
            userDetailsService(customerDetailsService)
        }
    }
}