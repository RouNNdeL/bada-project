package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "addresses")
class Address(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    @Column(name = "address_line_1")
    var addressLine1: String,

    @Column(name = "address_line_2")
    var addressLine2: String,

    var zipcode: String,
    var state: String,

    @ManyToOne
    var country: Country


) {
    override fun toString(): String {
        return "$addressLine1\n$addressLine2\n$zipcode $state\n$country"
    }
}