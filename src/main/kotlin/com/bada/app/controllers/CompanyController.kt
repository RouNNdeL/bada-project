package com.bada.app.controllers

import com.bada.app.repos.EmployeeRepository
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable

@Controller
class CompanyController(
    val employeeRepository: EmployeeRepository
) {
    @GetMapping("/companies")
    fun getAllCompanies(model: Model) : String {
        return "comapies"
    }

    @GetMapping("/companies/{id}/employees")
    fun getEmployees(@PathVariable("id") id: String, model: Model) : String {
        model.addAttribute("employees", employeeRepository.findEmployeesByCompanyId(id.toLong()))
        return "employees"
    }

    @GetMapping("/login")
    fun login() : String {
        return "login"
    }

    @GetMapping("/management/login")
    fun login2() : String {
        return "login2"
    }
}
