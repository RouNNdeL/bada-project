package com.bada.app.controllers

import com.bada.app.repos.EmployeeRepository
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.server.ResponseStatusException

@Controller
class EmployeeController(val employeeRepository: EmployeeRepository) {
    @GetMapping("/employees")
    fun showAllEmployees(model: Model): String {
        model.addAttribute("employees", employeeRepository.findAll())
        return "employees"
    }

    @GetMapping("/employees/{id}")
    fun showEmployee(@PathVariable id: Long, model: Model): String {
        val employee = employeeRepository.findById(id)
        if (employee.isEmpty) {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }
        model.addAttribute("employee", employee.get())

        return "employee"
    }
}