package com.bada.app.models

import com.bada.app.auth.EmployeeUserDetails
import com.bada.app.auth.Role
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "employees")
class Employee(
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
    val handledOrders: List<Order>,

    @OneToMany
    val salaries: List<Salary>,

    @OneToMany
    val scores: List<Score>

) : AbstractEntityLong() {

    fun getUserDetails(): EmployeeUserDetails {
        return EmployeeUserDetails(username, password, role, company.id)
    }

    fun getDisplayName(): String {
        return "$firstName $lastName"
    }

    fun showPermissions(): String {
        return role.permissions.joinToString(", ")
    }
}