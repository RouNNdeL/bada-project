package com.bada.app.auth

import com.bada.app.repos.CustomerRepository
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service

@Service
class CustomerDetailsService(
    val customerRepository: CustomerRepository
) : UserDetailsService {
    override fun loadUserByUsername(username: String?): CustomerUserDetails {
        if (username == null) {
            throw UsernameNotFoundException("Username cannot be null")
        }

        val customer = customerRepository.findByUsername(username).orElseThrow {
            throw UsernameNotFoundException("User does not exist")
        }
        return customer.getUserDetails()
    }
}