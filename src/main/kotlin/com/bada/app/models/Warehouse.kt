package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "warehouses")
class Warehouse(
    var name: String,

    var capacity: Double,

    @Column(name = "number_of_loading_bays")
    var bayCount: Int,

    var isRetail: Boolean,

    @ManyToOne
    var company: Company,

    @ManyToOne
    var manager: Employee,

    @OneToMany(mappedBy = "warehouse")
    val employees: Set<Employee>,

    @OneToMany(mappedBy = "warehouse", cascade = [CascadeType.ALL], orphanRemoval = true)
    val items: List<WarehouseItem>,

    @OneToOne
    val address: Address
) : AbstractEntityLong()