package com.bada.app.models

import java.util.*
import javax.persistence.Entity
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.persistence.Table

@Entity
@Table(name = "companies")
class Company(
    var name: String,
    var nip: String,
    var establishmentDate: Date,
    var krs: String,

    @OneToMany(mappedBy = "parentCompany")
    var subsidiaries: Set<Company>,

    @ManyToOne
    var parentCompany: Company?,
    @OneToMany(mappedBy = "company")
    val employees: Set<Employee>,

    @OneToMany(mappedBy = "company")
    val warehouses: Set<Warehouse>,

    @OneToMany(mappedBy = "company")
    val customers: Set<Customer>,
) : AbstractEntityLong()