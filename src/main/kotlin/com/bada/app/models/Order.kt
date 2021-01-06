package com.bada.app.models

import java.util.*
import javax.persistence.*

@Entity
@Table(name = "orders")
class Order(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    @Column(updatable = false, nullable = false)
    val date: Date,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    var status: Status,

    var shippingCost: Float?,

    @ManyToOne
    var assignedEmployee: Employee?,

    @OneToMany(mappedBy = "order", cascade = [CascadeType.ALL], orphanRemoval = true)
    val items: List<OrderItem>
) {
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