package com.bada.app.models

import javax.persistence.*

// TODO: Merge PlatformUser properties into both Customer and Employee
@Entity
@Table(name = "customers")
@PrimaryKeyJoinColumn(name = "user_id")
class Customer (
    @Column(name = "customer_id", updatable = false, nullable = false)
    val customerId: Long,

    var firstName: String,
    var lastName: String,
    var nip: String,
    var phoneNumber: String,


) : PlatformUser()