package com.bada.app.auth

import com.bada.app.repos.EmployeeRepository
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service

@Service
class EmployeeDetailsService(
    val employeeRepository: EmployeeRepository
) : UserDetailsService {
    override fun loadUserByUsername(username: String?): EmployeeUserDetails {
        if (username == null) {
            throw UsernameNotFoundException("Username cannot be null")
        }

        val employee = employeeRepository.findByUsername(username).orElseThrow {
            throw UsernameNotFoundException("User does not exist")
        }
        return employee.getUserDetails()
    }
}