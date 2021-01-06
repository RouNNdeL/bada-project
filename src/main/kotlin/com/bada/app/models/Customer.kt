package com.bada.app.models

import com.bada.app.auth.CustomerUserDetails
import com.bada.app.auth.Role
import javax.persistence.*

@Entity
@Table(name = "customers")
class Customer(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    @Column(name = "username", unique = true)
    var username: String,
    var password: String,
    var email: String,
    var firstName: String,
    var lastName: String,
    var nip: String,
    var phoneNumber: String,


    @Enumerated(EnumType.STRING)
    val role: Role = Role.CUSTOMER,

    @ManyToOne
    var company: Company,
) {
    fun getUserDetails(): CustomerUserDetails {
        return CustomerUserDetails(username, password, role)
    }
}