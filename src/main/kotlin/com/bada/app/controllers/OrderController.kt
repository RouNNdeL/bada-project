package com.bada.app.controllers

import com.bada.app.repos.OrderRepository
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping

@Controller
class OrderController(val repository: OrderRepository) {

    @GetMapping("/orders")
    fun test(model: Model) : String {
        model.addAttribute("orders", repository.findAll())
        return "orders"
    }
}