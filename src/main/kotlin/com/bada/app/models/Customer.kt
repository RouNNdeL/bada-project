package com.bada.app.models

import com.bada.app.auth.CustomerUserDetails
import java.io.Serializable
import javax.persistence.*

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
    @JoinColumn(name = "company_id")
    var company: Company,

    @OneToMany(mappedBy = "customer", cascade = [CascadeType.ALL], orphanRemoval = true)
    @OrderBy("id DESC")
    val orders: List<Order>,

    @OneToOne
    @JoinColumn(name = "address_id")
    val address: Address

) : AbstractEntity<Long>(), Serializable {
    constructor(
        registerCustomer: RegisterCustomer,
        company: Company,
        address: Address,
    ) : this(
        registerCustomer.username,
        registerCustomer.password,
        registerCustomer.email,
        registerCustomer.firstName,
        registerCustomer.lastName,
        registerCustomer.nip,
        registerCustomer.phoneNumber,
        company,
        emptyList(),
        address
    )

    fun getUserDetails(): CustomerUserDetails {
        return CustomerUserDetails(username, password, company.id!!)
    }
}

class RegisterCustomer(
    var username: String = "",
    var password: String = "",
    var email: String = "",
    var firstName: String = "",
    var lastName: String = "",
    var nip: String = "",
    var phoneNumber: String = "",
    var addressLine1: String = "",
    var addressLine2: String = "",
    var zipcode: String? = "",
    var city: String? = ""
)


class CustomerDetailsUpdate(
    val email: String = "",
    val firstName: String = "",
    val lastName: String = "",
    val nip: String = "",
    val phone: String = "",
    val addressLine1: String = "",
    val addressLine2: String = "",
    val city: String = "",
    val zipcode: String = ""
)