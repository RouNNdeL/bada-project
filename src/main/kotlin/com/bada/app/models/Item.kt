package com.bada.app.models

import javax.persistence.CascadeType
import javax.persistence.Entity
import javax.persistence.OneToMany
import javax.persistence.Table

@Entity
@Table(name = "items")
class Item(
    val name: String,
    val description: String,

    @OneToMany(mappedBy = "item", cascade = [CascadeType.ALL], orphanRemoval = true)
    val warehouseItems: List<WarehouseItem>,

    @OneToMany(mappedBy = "item")
    val priceRanges: List<PriceRange>
) : AbstractEntityLong() {
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

        return warehouseItems + missing
    }
}