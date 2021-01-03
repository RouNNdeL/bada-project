package com.bada.app.models

import java.util.*
import javax.persistence.*

@Entity
@Table(name = "orders")
class Order(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_id", updatable = false, nullable = false)
    val id: Long,

    @Column(updatable = false, nullable = false)
    val date: Date,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    var status: Status,

    var shippingCost: Float?,

    @OneToMany(mappedBy = "order", cascade = [CascadeType.ALL], orphanRemoval = true)
    val items: Set<OrderItem>
) {


    enum class Status {
        RECEIVED,
        IN_PROGRESS,
        READY_FOR_SHIPMENT,
        COMPLETED
    }
}