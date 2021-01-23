package com.bada.app.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.web.servlet.invoke
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder




@Configuration
@EnableWebSecurity
class DefaultSecurityConfig : WebSecurityConfigurerAdapter()  {
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