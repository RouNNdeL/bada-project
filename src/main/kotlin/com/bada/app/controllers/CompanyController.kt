package com.bada.app.controllers

import com.bada.app.auth.EmployeeUserDetails
import com.bada.app.auth.Role
import com.bada.app.models.Employee
import com.bada.app.repos.EmployeeRepository
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.server.ResponseStatusException

@Controller
class CompanyController(
    val employeeRepository: EmployeeRepository
) {
    @GetMapping("/companies/{id}/employees")
    fun getEmployees(@PathVariable("id") id: String, model: Model): String {
        model.addAttribute("employees", employeeRepository.findEmployeesByCompanyId(id.toLong()))
        return "employees"
    }

    @GetMapping("/login")
    fun customerLogin(): String {
        return "customer-login"
    }

    @GetMapping("/management/login")
    fun managementLogin(): String {
        return "management-login"
    }

    @GetMapping("/")
    fun home(model: Model, authentication: Authentication?): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        when (val user = authentication.principal) {
            is EmployeeUserDetails -> {
                val employee = employeeRepository.findByUsername(user.username).orElseThrow {
                    throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
                }
                return employeeHome(model, employee)
            }
        }

        return "home_default"
    }

    private fun employeeHome(model: Model, employee: Employee): String {
        return when (employee.role) {
            Role.WAREHOUSE_EMPLOYEE -> {
                model.addAttribute("orders", employee.handledOrders)
                "warehouse_employee_home"
            }
            Role.WAREHOUSE_MANAGER -> {
                "warehouse_manager_home"
            }
            else -> throw IllegalArgumentException("Invalid role for employee ${employee.role}")
        }
    }
}
