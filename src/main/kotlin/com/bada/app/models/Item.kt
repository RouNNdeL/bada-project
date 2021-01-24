package com.bada.app.models

import com.bada.app.repos.ItemRepository
import com.fasterxml.jackson.annotation.JsonTypeInfo
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import javax.persistence.*

@Entity
@Table(name = "items")
class Item(
    val name: String,
    val description: String,

    @OneToMany(mappedBy = "item", cascade = [CascadeType.ALL], orphanRemoval = true)
    @OrderBy("warehouse_id")
    val warehouseItems: List<WarehouseItem>,

    @OneToMany(mappedBy = "item")
    @OrderBy("min_quantity ASC")
    val priceRanges: List<PriceRange>
) : AbstractEntity<Long>() {
    fun getMergedStock(warehouses: List<Warehouse>, forceCompanyCheck: Boolean = true): List<WarehouseItem> {
        if (warehouses.isEmpty()) {
            return emptyList()
        }

        val companyId = warehouses.first().company.id

        val present = warehouseItems
            .map { w -> w.warehouse }
            .filter { !forceCompanyCheck || it.company.id == companyId }

        val missing = warehouses
            .filter { !present.contains(it) && (!forceCompanyCheck || it.company.id == companyId) }
            .map { WarehouseItem(it, this, 0) }

        return (warehouseItems + missing).sortedBy { it.warehouse.id }
    }

    fun getPrice(quantity: Int): Double? {
        var range: PriceRange? = null
        for (r in priceRanges) {
            if (quantity >= r.minQuantity) {
                range = r
            }
        }

        return range?.price
    }

    fun getPriceRangeJson(): String {
        val objectMapper = ObjectMapper()
        return objectMapper.writeValueAsString(priceRanges)
    }
}

class ItemUpdate(
    val priceRanges: List<Range>,
    val stock: List<Stock>
) {
    class Range(
        val minQuantity: Int,
        val price: Double
    )

    class Stock(
        val warehouse: Long,
        val quantity: Int
    )
}

class CartItem(
    val itemId: Long? = null,
    var quantity: Int = 0
)

@JsonSerialize
@JsonTypeInfo(use = JsonTypeInfo.Id.CLASS)
class CartItems : HashMap<Long, Int>() {
    fun toMapped(itemRepository: ItemRepository) =
        mapNotNullTo(ArrayList(), { CartItemMapped(itemRepository.findById(it.key).orElseGet { null }, it.value) })
}

class CartItemMapped(
    val item: Item,
    val quantity: Int
) {
    val price = item.getPrice(quantity) ?: 0.0
    val totalPrice = price * quantity
}