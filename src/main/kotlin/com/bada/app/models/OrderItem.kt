package com.bada.app.models

import java.io.Serializable
import javax.persistence.*

@Entity
@Table(name = "orders_items")
class OrderItem(
    @ManyToOne
    @MapsId("orderId")
    @JoinColumn(name = "order_id")
    val order: Order,

    @ManyToOne
    @MapsId("itemId")
    @JoinColumn(name = "item_id")
    val item: Item,

    @EmbeddedId
    val id: OrderItemId = OrderItemId(order.id, item.id),


    @Column(name = "ordered_item_quantity")
    val quantity: Int
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as OrderItem

        if (order != other.order) return false
        if (item != other.item) return false

        return true
    }

    override fun hashCode(): Int {
        var result = order.hashCode()
        result = 31 * result + item.hashCode()
        return result
    }
}

@Embeddable
data class OrderItemId(
    @Column(name = "item_id")
    var itemId: Long,
    @Column(name = "order_id")
    var orderId: Long
) : Serializable