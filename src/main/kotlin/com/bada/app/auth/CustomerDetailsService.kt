package com.bada.app.auth

import com.bada.app.models.Address
import com.bada.app.models.Customer
import com.bada.app.models.RegisterCustomer
import com.bada.app.repos.AddressRepository
import com.bada.app.repos.CompanyRepository
import com.bada.app.repos.CountryRepository
import com.bada.app.repos.CustomerRepository
import org.springframework.context.annotation.Bean
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.stereotype.Service

@Service
class CustomerDetailsService(
    val customerRepository: CustomerRepository,
    val countryRepository: CountryRepository,
    val addressRepository: AddressRepository,
    val companyRepository: CompanyRepository,
) : UserDetailsService {
    override fun loadUserByUsername(username: String?): CustomerUserDetails {
        if (username == null) {
            throw UsernameNotFoundException("Username cannot be null")
        }

        val customer = customerRepository.findByUsername(username).orElseThrow {
            throw UsernameNotFoundException("User does not exist")
        }
        return customer.getUserDetails()
    }

    fun register(registerCustomer: RegisterCustomer){
        val defaultCountry = countryRepository.findByCountryName("Poland").orElseThrow()
        val defaultCompany = companyRepository.findById(1).orElseThrow()

        val address = Address(
            registerCustomer.addressLine1,
            registerCustomer.addressLine2,
            registerCustomer.zipcode,
            registerCustomer.city,
            defaultCountry
        )
        addressRepository.save(address)


        val customer = Customer(registerCustomer, defaultCompany, address)

        val hash = BCryptPasswordEncoder().encode(customer.password)

        customer.password = hash!!

        while(true){//cursed sequence fix
            try {
                Thread.sleep(10)
                customerRepository.saveAndFlush(customer)
                break
            } catch (e: Exception){}
        }
    }
}