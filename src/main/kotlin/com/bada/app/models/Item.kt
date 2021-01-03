package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "items")
class Item(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    val name: String,
    val description: String,

    @ManyToMany(mappedBy = "items")
    val warehouses: List<Warehouse>,

    @OneToMany
    val priceRanges: List<PriceRange>
)