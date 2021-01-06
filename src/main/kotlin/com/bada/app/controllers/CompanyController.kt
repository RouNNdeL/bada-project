package com.bada.app.controllers

import com.bada.app.auth.EmployeeUserDetails
import com.bada.app.auth.Role
import com.bada.app.models.Employee
import com.bada.app.models.OrderStatusUpdate
import com.bada.app.repos.EmployeeRepository
import com.bada.app.repos.OrderRepository
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@Controller
class CompanyController(
    val employeeRepository: EmployeeRepository,
    val orderRepository: OrderRepository
) {
    @GetMapping("/companies/{id}/employees")
    fun getEmployees(@PathVariable("id") id: String, model: Model) : String {
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

    @PostMapping(
        "/orders/{id}/update_status",
        consumes = [MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_FORM_URLENCODED_VALUE],
        produces = [MediaType.APPLICATION_JSON_VALUE, MediaType.TEXT_PLAIN_VALUE]
    )
    @PreAuthorize("hasAuthority('HANDLE_ORDER')")
    @ResponseBody
    fun updateOrder(
        @RequestBody orderStatusUpdate: OrderStatusUpdate,
        @PathVariable id: Long,
        authentication: Authentication
    ): ResponseEntity<String> {
        val user = authentication.principal
        if (user !is EmployeeUserDetails) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val orderO = orderRepository.findById(id)
        if (orderO.isEmpty) {
            return ResponseEntity.notFound().build()
        }
        val order = orderO.get()

        val employee = employeeRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        if (order.assignedEmployee?.id != employee.id) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        order.status = orderStatusUpdate.status
        orderRepository.save(order)

        return ResponseEntity.ok().body("Success")
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
