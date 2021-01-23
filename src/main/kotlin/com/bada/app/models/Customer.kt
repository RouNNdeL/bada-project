package com.bada.app.models

import com.bada.app.auth.CustomerUserDetails
import com.bada.app.repos.CompanyRepository
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
    @JoinColumn(name="company_id")
    var company: Company,

    @OneToMany(mappedBy = "customer", cascade = [CascadeType.ALL], orphanRemoval = true)
    val orders: List<Order>,

    @OneToOne
    @JoinColumn(name="address_id")
    val address: Address

) : AbstractEntityLong(), Serializable {
    constructor(
        registerCustomer: RegisterCustomer,
        companyRepository: CompanyRepository,
        address: Address
    ) : this(
        registerCustomer.username,
        registerCustomer.password,
        registerCustomer.email,
        registerCustomer.firstName,
        registerCustomer.lastName,
        registerCustomer.nip,
        registerCustomer.phoneNumber,
        companyRepository.findById(1).orElseThrow(),
        emptyList(),
        address
    )

    fun getUserDetails(): CustomerUserDetails {
        return CustomerUserDetails(username, password, company.id!!)
    }
}