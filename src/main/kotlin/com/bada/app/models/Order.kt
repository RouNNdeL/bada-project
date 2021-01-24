package com.bada.app.models

import java.util.*
import javax.persistence.*

@Entity
@Table(name = "orders")
class Order(
    @Column(updatable = false, nullable = false)
    val date: Date,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    var status: Status,

    var shippingCost: Float?,

    @ManyToOne
    var assignedEmployee: Employee?,

    @ManyToOne
    @JoinColumn(name = "customer_id")
    var customer: Customer,

    @OneToMany(mappedBy = "order", cascade = [CascadeType.ALL], orphanRemoval = true)
    val items: List<OrderItem>
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