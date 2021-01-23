package com.bada.app.models

import com.bada.app.repos.CountryRepository
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
    var country: Country,


    ) : AbstractEntityLong(), Serializable {
    constructor(
        addressLine1: String,
        addressLine2: String,
        zipcode: String?,
        city: String?,
        countryRepository: CountryRepository
    ) : this(
        addressLine1,
        addressLine2,
        zipcode,
        city,
        countryRepository.findByCountryName("Poland").orElseThrow()
    )

    override fun toString(): String {
        return "$addressLine1\n$addressLine2\n$zipcode $city\n${country.countryName}"
    }
}