package com.bada.app.controllers

import com.bada.app.auth.CustomerUserDetails
import com.bada.app.auth.SimpleUserDetails
import com.bada.app.repos.CustomerRepository
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.server.ResponseStatusException

@Controller
class CustomerController(
    val customerRepository: CustomerRepository,
) {
    @GetMapping("/user/login")
    fun customerLogin(): String {
        return "client_login"
    }

    @GetMapping("/user/home")
    fun customerHome(model: Model, authentication: Authentication?): String {
        val user = authentication?.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")

        if (user !is CustomerUserDetails) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val customer = customerRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        model.addAttribute("user", customer)
        return "customer_home"
    }

    @GetMapping("/user/store/checkout")
    fun checkout(model: Model): String {
        return "store_checkout"
    }
}