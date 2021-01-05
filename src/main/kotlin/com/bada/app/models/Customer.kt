package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "customers")
class Customer (
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    @Column(name = "username", unique = true)
    var username: String,
    var password: String,
    var email: String,
    var firstName: String,
    var lastName: String,
    var nip: String,
    var phoneNumber: String,

    @ManyToOne
    var company: Company,
)