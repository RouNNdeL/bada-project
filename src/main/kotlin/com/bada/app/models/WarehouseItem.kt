package com.bada.app.models

import java.io.Serializable
import javax.persistence.*

@Entity
@Table(name = "warehouses_items")
class WarehouseItem(
    @ManyToOne
    @MapsId("warehouseId")
    val warehouse: Warehouse,

    @ManyToOne
    @MapsId("itemId")
    val item: Item,

    @EmbeddedId
    val id: WarehouseItemId = WarehouseItemId(warehouse.id, item.id),


    @Column(name = "item_quantity")
    val quantity: Int
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as WarehouseItem

        if (warehouse != other.warehouse) return false
        if (item != other.item) return false

        return true
    }

    override fun hashCode(): Int {
        var result = warehouse.hashCode()
        result = 31 * result + item.hashCode()
        return result
    }
}

@Embeddable
data class WarehouseItemId(
    @Column(name = "item_id")
    var itemId: Long,
    @Column(name = "warehouse_id")
    var warehouseId: Long
) : Serializable