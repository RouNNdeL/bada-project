package com.bada.app.auth

import com.bada.app.models.Customer
import com.bada.app.models.RegisterCustomer
import com.bada.app.repos.CustomerRepository
import org.springframework.validation.ValidationUtils

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component
import org.springframework.validation.Errors
import org.springframework.validation.Validator


@Component
class CustomerValidator(
    val customerRepository: CustomerRepository,
) : Validator {
    override fun supports(aClass: Class<*>): Boolean {
        return RegisterCustomer::class.java == aClass
    }

    override fun validate(o: Any, errors: Errors) {
        val user: RegisterCustomer = o as RegisterCustomer
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "username", "NotEmpty")
        if (customerRepository.findByUsername(user.username).isPresent) {
            errors.rejectValue("username", "Duplicate.userForm.username")
        }
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "password", "NotEmpty")
    }
}