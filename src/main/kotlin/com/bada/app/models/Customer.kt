package com.bada.app.models

import com.bada.app.auth.CustomerUserDetails
import java.io.Serializable
import javax.persistence.*

@Entity
@Table(name = "customers")
class Customer(
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "user_seq")
    @SequenceGenerator(name = "user_seq", sequenceName = "customers_id_seq", allocationSize = 50)
    @Column(updatable = false, nullable = false)
    override val id: Long? = null,

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
    @OrderBy("id DESC")
    val orders: List<Order>,

    @OneToOne
    @JoinColumn(name="address_id")
    val address: Address

) : AbstractEntity<Long>(), Serializable {
    constructor(
        registerCustomer: RegisterCustomer,
        company: Company,
        address: Address,
    ) : this(
        null,
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