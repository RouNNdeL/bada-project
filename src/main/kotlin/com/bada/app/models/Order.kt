package com.bada.app.models

import java.util.*
import javax.persistence.*

@Entity
@Table(name = "orders")
class Order(
    @Column(updatable = false, nullable = false)
    val date: Date = Date(),

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    var status: Status = Status.RECEIVED,

    var shippingCost: Float? = null,

    @ManyToOne
    var assignedEmployee: Employee?,

    @ManyToOne
    @JoinColumn(name = "customer_id")
    var customer: Customer,

    @OneToOne
    @JoinColumn(name = "address_id")
    val address: Address,

    @OneToMany(mappedBy = "order", cascade = [CascadeType.ALL], orphanRemoval = true)
    val items: MutableList<OrderItem> = ArrayList<OrderItem>()
) : AbstractEntity<Long>() {
    enum class Status {
        RECEIVED,
        IN_PROGRESS,
        READY_FOR_SHIPMENT,
        COMPLETED
    }
}

class OrderStatusUpdate(
    val status: Order.Status,
)

class OrderAddress(
    val firstName: String = "",
    val lastName: String = "",
    val addressLine1: String = "",
    val addressLine2: String = "",
    val city: String = "",
    val zip: String = "",
    val acceptedTerms: Boolean = false
) {
    fun createAddress(country: Country) = Address(addressLine1, addressLine2, zip, city, country)
}