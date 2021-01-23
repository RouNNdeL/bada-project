package com.bada.app.controllers

import com.bada.app.auth.CustomerValidator
import com.bada.app.models.Address
import com.bada.app.models.Customer
import com.bada.app.models.RegisterCustomer
import com.bada.app.repos.AddressRepository
import com.bada.app.repos.CompanyRepository
import com.bada.app.repos.CountryRepository
import com.bada.app.repos.CustomerRepository
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.validation.BindingResult
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PostMapping

@Controller
class DefaultController(
    val countryRepository: CountryRepository,
    val companyRepository: CompanyRepository,
    val customerRepository: CustomerRepository,
    val customerValidator: CustomerValidator,
    val addressRepository: AddressRepository
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
        customerValidator.validate(registerCustomer, bindingResult);

        if (bindingResult.hasErrors()) {
            return "register";
        }

        val address = Address(
            registerCustomer.addressLine1,
            registerCustomer.addressLine2,
            registerCustomer.zipcode,
            registerCustomer.city,
            countryRepository
        )
        addressRepository.save(address)

        //TODO insert
        val user = customerRepository.findById(3).get()
        val customer = Customer(registerCustomer, companyRepository, address)

        user.username = customer.username
        customerRepository.saveAndFlush(user)

        return "redirect:/user/login"
    }
}