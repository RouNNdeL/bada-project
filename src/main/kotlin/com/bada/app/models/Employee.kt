package com.bada.app.models

import java.util.*
import javax.persistence.*

@Entity
@Table(name = "employees")
class Employee (
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,
    @Column(unique = true)
    var username: String,
    var password: String,
    var email: String,
    var firstName: String,
    var lastName: String,
    var pesel: String,
    var employmentDate: Date,
    var phoneNumber: String,

    @OneToOne
    var address: Address,

    @ManyToOne
    var company: Company,

    @ManyToOne
    var warehouse: Warehouse?,

    @OneToMany(mappedBy = "manager")
    val managedWarehouses: Set<Warehouse>,

    @OneToMany
    val salaries: List<Salary>,

    @OneToMany
    val scores: List<Score>,

) {
    fun getDisplayName() : String {
        return "$firstName $lastName"
    }
    enum class Permission {
        ASSIGN_ORDER,
        MODIFY_STOCK,
        MODIFY_PRICE,
        ALL
    }
}