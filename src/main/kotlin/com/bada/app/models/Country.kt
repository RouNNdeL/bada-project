package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "countries")
class Country(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    var countryName: String,

    @Column(name = "iso_3166_1")
    var isoCode: String,

    var phonePrefix: String
)