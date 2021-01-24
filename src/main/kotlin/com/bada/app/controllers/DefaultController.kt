package com.bada.app.controllers

import com.bada.app.auth.*
import com.bada.app.models.RegisterCustomer
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.validation.BindingResult
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PostMapping

@Controller
class DefaultController(
    val customerValidator: CustomerValidator,
    val customerDetailsService: CustomerDetailsService,
) {
    @GetMapping("/")
    fun home(): String {
        return "home"
    }


    @GetMapping("/register")
    fun register(model: Model): String {
        model.addAttribute("customerForm", RegisterCustomer())
        return "register"
    }

    @PostMapping("/register")
    fun registerUser(
        model: Model,
        @ModelAttribute("customerForm") registerCustomer: RegisterCustomer,
        bindingResult: BindingResult
    ): String {
        customerValidator.validate(registerCustomer, bindingResult)

        if (bindingResult.hasErrors()) {
            return "register"
        }

        customerDetailsService.register(registerCustomer)

        return "redirect:/user/login"
    }
}