package com.bada.app.models

import com.bada.app.auth.CustomerUserDetails
import com.bada.app.repos.CompanyRepository
import com.bada.app.repos.CountryRepository
import javax.persistence.*

class RegisterCustomer(
    var username: String,
    var password: String,
    var email: String,
    var firstName: String,
    var lastName: String,
    var nip: String,
    var phoneNumber: String,
    var addressLine1: String,
    var addressLine2: String,
    var zipcode: String?,
    var city: String?,

    ) {
    constructor() : this(
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
    )
}