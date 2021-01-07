package com.bada.app.models

import com.bada.app.auth.CustomerUserDetails
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.ManyToOne
import javax.persistence.Table

@Entity
@Table(name = "customers")
class Customer(
    @Column(name = "username", unique = true)
    var username: String,
    var password: String,
    var email: String,
    var firstName: String,
    var lastName: String,
    var nip: String,
    var phoneNumber: String,

    @ManyToOne
    var company: Company,
) : AbstractEntityLong() {
    fun getUserDetails(): CustomerUserDetails {
        return CustomerUserDetails(username, password, company.id)
    }
}