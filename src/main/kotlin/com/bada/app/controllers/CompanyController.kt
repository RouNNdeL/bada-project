package com.bada.app.controllers

import com.bada.app.auth.*
import com.bada.app.models.*
import com.bada.app.repos.*
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@Controller
class CompanyController(
    val employeeRepository: EmployeeRepository,
    val customerRepository: CustomerRepository,
    val orderRepository: OrderRepository,
    val itemRepository: ItemRepository,
    val warehousesRepository: WarehousesRepository,
    val priceRangeRepository: PriceRangeRepository,
    val warehouseItemRepository: WarehouseItemRepository
) {
    @GetMapping("/companies/{id}/employees")
    fun getEmployees(@PathVariable("id") id: String, model: Model): String {
        model.addAttribute("employees", employeeRepository.findEmployeesByCompanyId(id.toLong()))
        return "employees"
    }

    @GetMapping("/user/login")
    fun customerLogin(): String {
        return "client_login"
    }

    @GetMapping("/user/home")
    fun customerHome(model: Model, authentication: Authentication?): String {
        val user = authentication?.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")

        if (user !is CustomerUserDetails) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val customer = customerRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        model.addAttribute("user", customer)
        return "customer_home"
    }

    @GetMapping("/management/login")
    fun managementLogin(): String {
        return "management_login"
    }

    @PostMapping(
        "/orders/{id}/update_status",
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

    @GetMapping("/")
    fun home(model: Model, authentication: Authentication?): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        when (val user = authentication.principal) {
            is EmployeeUserDetails -> {
                val employee = employeeRepository.findByUsername(user.username).orElseThrow {
                    throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
                }
                return employeeHome(model, employee)
            }
        }

        return "home_default"
    }

    @GetMapping("/store/item/{id}")
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

        model.addAttribute("user", user)

        val warehouses = warehousesRepository.findAllByCompanyId(user.companyId)

        model.addAttribute("item", item)
        model.addAttribute("stock", item.getMergedStock(warehouses.toList()))
        model.addAttribute("canSave", canSave)

        itemRepository.save(item)

        return "store_item"
    }

    @PostMapping(
        "/store/item/{id}/update",
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

    @GetMapping("/store")
    fun store(model: Model) : String {
        val items = itemRepository.findAll()
        model.addAttribute("items", items)
        return "store"
    }

    @GetMapping("/store/checkout")
    fun checkout(model: Model) : String{
        return "store_checkout"
    }

    private fun employeeHome(model: Model, employee: Employee): String {
        return when (employee.role) {
            Role.WAREHOUSE_EMPLOYEE -> {
                model.addAttribute("orders", employee.handledOrders)
                "warehouse_employee_home"
            }
            Role.WAREHOUSE_MANAGER -> {
                "warehouse_manager_home"
            }
            else -> throw IllegalArgumentException("Invalid role for employee ${employee.role}")
        }
    }
}
