package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "warehouses")
class Warehouse(
    @Id
    @GeneratedValue
    @Column(updatable = false, nullable = false)
    val id: Long,

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

    @ManyToMany
    @JoinTable(
        name = "warehouses_items",
        joinColumns = [JoinColumn(name = "warehouse_id")],
        inverseJoinColumns = [JoinColumn(name = "item_id")])
    val items: Set<Item>,
)