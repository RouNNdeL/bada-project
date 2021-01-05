package com.bada.app.controllers

import com.bada.app.models.Employee
import com.bada.app.repos.EmployeeRepository
import com.bada.app.repos.OrderRepository
import org.springframework.http.HttpStatus
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.server.ResponseStatusException

@Controller
class OrderController(
    val orderRepository: OrderRepository,
    val employeeRepository: EmployeeRepository
) {

    @GetMapping("/orders")
    fun orders(model: Model, authentication: Authentication?): String {
        if (authentication?.isAuthenticated != true) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }


        when (val user = authentication.principal) {
            is Employee -> {
                val employee = employeeRepository.findById(user.id).orElseThrow {
                    throw ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR)
                }
                model.addAttribute("orders", employee.handledOrders)
                return "assigned_orders"
            }
            else -> throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }
    }
}