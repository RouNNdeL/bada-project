package com.bada.app.controllers

import com.bada.app.auth.EmployeeUserDetails
import com.bada.app.auth.Permission
import com.bada.app.auth.Role
import com.bada.app.auth.SimpleUserDetails
import com.bada.app.models.*
import com.bada.app.repos.*
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.transaction.annotation.Transactional
import org.springframework.ui.Model
import org.springframework.validation.BindingResult
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@Controller
class ManagementController(
    val employeeRepository: EmployeeRepository,
    val orderRepository: OrderRepository,
    val itemRepository: ItemRepository,
    val warehousesRepository: WarehousesRepository,
    val priceRangeRepository: PriceRangeRepository,
    val warehouseItemRepository: WarehouseItemRepository,
    val orderItemRepository: OrderItemRepository
) {

    @GetMapping("/management/login")
    fun managementLogin(authentication: Authentication?): String {
        if (authentication != null) {
            return "redirect:/management/home"
        }
        return "management_login"
    }

    @PostMapping(
        "/management/orders/{id}/update_status",
        consumes = [MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_FORM_URLENCODED_VALUE],
        produces = [MediaType.APPLICATION_JSON_VALUE, MediaType.TEXT_PLAIN_VALUE]
    )
    @PreAuthorize("hasAuthority('HANDLE_ORDER')")
    @ResponseBody
    fun updateOrder(
        @RequestBody orderStatusUpdate: OrderStatusUpdate,
        @PathVariable id: Long,
        authentication: Authentication
    ): ResponseEntity<String> {
        val user = authentication.principal
        if (user !is EmployeeUserDetails) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val orderO = orderRepository.findById(id)
        if (orderO.isEmpty) {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }
        val order = orderO.get()

        val employee = employeeRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        if (order.assignedEmployee?.id != employee.id) {
            throw ResponseStatusException(HttpStatus.FORBIDDEN)
        }

        order.status = orderStatusUpdate.status
        orderRepository.save(order)

        return ResponseEntity.ok().body("Success")
    }

    @GetMapping("/management/home")
    fun home(model: Model, authentication: Authentication?): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val user = authentication.principal
        if (user !is EmployeeUserDetails) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val employee = employeeRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }
        model.addAttribute("path", "/management")
        return employeeHome(model, employee)
    }

    @GetMapping("/management/store/item/{id}")
    fun item(@PathVariable id: Long, model: Model, authentication: Authentication?): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val user = authentication.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")
        val item = itemRepository.findById(id).orElseThrow {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }

        if (user is EmployeeUserDetails) {
            val employee = employeeRepository.findByUsername(user.username).orElseThrow {
                throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
            }

            if (user.hasPermission(Permission.CHANGE_STOCK)) {
                model.addAttribute("warehouseIdEdit", employee.warehouse?.id)
            }
        }

        val canSave = user.hasPermission(Permission.CHANGE_STOCK) || user.hasPermission(Permission.CHANGE_STOCK_ALL) ||
                user.hasPermission(Permission.CHANGE_PRICE)
        val canDelete = user.hasPermission(Permission.DELETE_ITEM)

        model.addAttribute("user", user)

        val warehouses = warehousesRepository.findAllByCompanyId(user.companyId)

        model.addAttribute("item", item)
        model.addAttribute("stock", item.getMergedStock(warehouses.toList()))
        model.addAttribute("canSave", canSave)
        model.addAttribute("canDelete", canDelete)

        itemRepository.save(item)

        model.addAttribute("path", "/management")

        return "store_item"
    }

    @PostMapping(
        "/management/store/item/{id}/update",
        consumes = [MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_FORM_URLENCODED_VALUE],
        produces = [MediaType.APPLICATION_JSON_VALUE, MediaType.TEXT_PLAIN_VALUE]
    )
    fun updateItem(
        @PathVariable id: Long,
        @RequestBody itemUpdate: ItemUpdate,
        authentication: Authentication?
    ): ResponseEntity<String> {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val user = authentication.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")
        val item = itemRepository.findById(id).orElseThrow {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }

        if (user !is EmployeeUserDetails) {
            throw ResponseStatusException(HttpStatus.FORBIDDEN)
        }

        val employee = employeeRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        if (user.hasPermission(Permission.CHANGE_PRICE)) {
            priceRangeRepository.deleteAll(item.priceRanges)
            itemUpdate.priceRanges.forEach {
                priceRangeRepository.save(PriceRange(it.minQuantity, it.price, item))
            }
        } else if (itemUpdate.priceRanges.isNotEmpty()) {
            throw ResponseStatusException(HttpStatus.FORBIDDEN)
        }

        itemUpdate.stock.forEach {
            if (user.hasPermission(Permission.CHANGE_STOCK_ALL) ||
                (user.hasPermission(Permission.CHANGE_STOCK) && employee.warehouse?.id == it.warehouse)
            ) {
                warehouseItemRepository.save(
                    WarehouseItem(warehousesRepository.getOne(it.warehouse), item, it.quantity)
                )
            } else {
                throw ResponseStatusException(HttpStatus.FORBIDDEN)
            }
        }

        return ResponseEntity.ok().body("Success")
    }

    @Transactional
    @PostMapping("/management/store/item/{id}/delete")
    fun deleteItem(@PathVariable id: Long, authentication: Authentication?): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val user = authentication.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")
        val item = itemRepository.findById(id).orElseThrow {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }

        if (user !is EmployeeUserDetails) {
            throw ResponseStatusException(HttpStatus.FORBIDDEN)
        }

        val employee = employeeRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        if (user.hasPermission(Permission.DELETE_ITEM)) {
            orderItemRepository.deleteAllByItemId(id)
            priceRangeRepository.deleteAll(item.priceRanges)
            itemRepository.deleteById(id)
        } else {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        return "redirect:/management/store"
    }

    @GetMapping("/management/store")
    fun store(model: Model): String {
        val items = itemRepository.findAll()
        model.addAttribute("items", items)
        model.addAttribute("cart", false)
        model.addAttribute("canAdd", true)
        model.addAttribute("path", "/management")
        model.addAttribute("newItem", NewItem())
        return "store"
    }

    @PostMapping("/management/store/item/add")
    fun addItem(
        model: Model,
        @ModelAttribute("newItem") newItem: NewItem,
        bindingResult: BindingResult
    ): String {
        if (bindingResult.hasErrors()) {
            return "redirect:/management/store"
        }

        if (newItem.basePrice <= 0){
            throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        }

        val item = itemRepository.save(Item(name = newItem.name, description = newItem.description))
        priceRangeRepository.save(PriceRange(newItem.baseQuantity, newItem.basePrice, item))

        return "redirect:/management/store"
    }

    private fun employeeHome(model: Model, employee: Employee): String {
        return when (employee.role) {
            Role.WAREHOUSE_EMPLOYEE -> {
                model.addAttribute("orders", employee.handledOrders)
                "warehouse_employee_home"
            }
            Role.WAREHOUSE_MANAGER -> {
                model.addAttribute("warehouses", employee.managedWarehouses)
                "warehouse_manager_home"
            }
            else -> throw IllegalArgumentException("Invalid role for employee ${employee.role}")
        }
    }
}
