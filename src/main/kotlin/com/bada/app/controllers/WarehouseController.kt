package com.bada.app.controllers

import com.bada.app.repos.EmployeeRepository
import com.bada.app.repos.WarehousesRepository
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.server.ResponseStatusException

@Controller
class WarehouseController(val warehousesRepository: WarehousesRepository) {
    @GetMapping("/warehouses")
    fun showAllEmployees(model: Model): String {
        model.addAttribute("warehouses", warehousesRepository.findAll())
        return "warehouses"
    }

    @GetMapping("/warehouses/{id}")
    fun showEmployee(@PathVariable id: Long, model: Model): String {
        val warehouse = warehousesRepository.findById(id)
        if (warehouse.isEmpty) {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }
        model.addAttribute("warehouse", warehouse.get())

        return "warehouse"
    }
}