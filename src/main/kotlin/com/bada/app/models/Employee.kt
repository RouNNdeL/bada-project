package com.bada.app.models

import com.bada.app.auth.Role
import com.bada.app.util.SimpleUserDetails
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "employees")
class Employee(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,
    @Column(unique = true)
    var username: String,
    private var password: String,
    var email: String,
    var firstName: String,
    var lastName: String,
    var pesel: String,

    var employmentDate: Date,
    var phoneNumber: String,

    @Enumerated(EnumType.STRING)
    var role: Role,

    @OneToOne(fetch = FetchType.LAZY)
    var address: Address,

    @ManyToOne
    var company: Company,

    @ManyToOne
    var warehouse: Warehouse?,

    @OneToMany(mappedBy = "manager")
    val managedWarehouses: Set<Warehouse>,

    @OneToMany(mappedBy = "assignedEmployee")
    val handledOrders: Set<Order>,

    @OneToMany
    val salaries: List<Salary>,

    @OneToMany
    val scores: List<Score>

) {

    fun getUserDetails(): SimpleUserDetails {
        return SimpleUserDetails(username, password, role)
    }

    fun getDisplayName(): String {
        return "$firstName $lastName"
    }

    fun showPermissions(): String {
        return role.permissions.joinToString(", ")
    }
}