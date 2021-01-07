package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "price_ranges")
class PriceRange(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    var minQuantity: Int,
    var price: Double,

    @ManyToOne
    var item: Item
)