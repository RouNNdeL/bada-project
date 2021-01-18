package com.bada.app.models

import java.io.Serializable
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.ManyToOne
import javax.persistence.Table

@Entity
@Table(name = "addresses")
class Address(
    @Column(name = "address_line_1")
    var addressLine1: String,

    @Column(name = "address_line_2")
    var addressLine2: String,

    var zipcode: String?,
    var city: String?,

    @ManyToOne
    var country: Country


) : AbstractEntityLong(), Serializable {
    override fun toString(): String {
        return "$addressLine1\n$addressLine2\n$zipcode $city\n${country.countryName}"
    }
}