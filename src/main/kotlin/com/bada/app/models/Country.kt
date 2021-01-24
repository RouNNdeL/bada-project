package com.bada.app.models

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Table

@Entity
@Table(name = "countries")
class Country(
    var countryName: String,

    @Column(name = "iso_3166_1")
    var isoCode: String,

    var phonePrefix: String
) : AbstractEntity<Long>()