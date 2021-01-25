package com.bada.app.controllers

import com.bada.app.auth.CustomerUserDetails
import com.bada.app.auth.SimpleUserDetails
import com.bada.app.models.*
import com.bada.app.repos.*
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException
import javax.servlet.http.HttpSession


@Controller
class CustomerController(
    val customerRepository: CustomerRepository,
    val itemRepository: ItemRepository,
    val warehousesRepository: WarehousesRepository,
    val employeeRepository: EmployeeRepository,
    val orderRepository: OrderRepository,
    val addressRepository: AddressRepository,
    val countryRepository: CountryRepository,
) {
    @GetMapping("/user/login")
    fun customerLogin(authentication: Authentication?): String {
        if (authentication != null){
            return "redirect:/user/home"
        }

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
        model.addAttribute("path", "/user")
        return "customer_home"
    }

    @Suppress("UNCHECKED_CAST")
    @GetMapping("/user/store")
    fun store(model: Model, session: HttpSession): String {
        val items = itemRepository.findAll()
        model.addAttribute("items", items)
        model.addAttribute("cart", true)

        val cartItems = session.getAttribute("cartItems") as? CartItems ?: CartItems()
        val mapped = cartItems.toMapped(itemRepository)
        val cartTotalCost = mapped.sumByDouble { it.quantity * (it.item.getPrice(it.quantity) ?: 0.0) }

        model.addAttribute("cartItems", mapped)
        model.addAttribute("cartTotalCost", cartTotalCost)
        model.addAttribute("canAdd", false)
        model.addAttribute("path", "/user")

        return "store"
    }

    @Suppress("DuplicatedCode")
    @GetMapping("/user/store/checkout")
    fun checkout(model: Model, session: HttpSession): String {
        val cartItems = session.getAttribute("cartItems") as? CartItems ?: CartItems()
        val mapped = cartItems.toMapped(itemRepository)
        val cartTotalCost = mapped.sumByDouble { it.quantity * (it.item.getPrice(it.quantity) ?: 0.0) }

        model.addAttribute("cartItems", mapped)
        model.addAttribute("cartTotalCost", cartTotalCost)
        model.addAttribute("path", "/user")

        return "store_checkout"
    }

    @Suppress("DuplicatedCode")
    @PostMapping(
        "/user/store/checkout",
        consumes = [MediaType.APPLICATION_FORM_URLENCODED_VALUE]
    )
    fun checkoutProcess(
        orderAddress: OrderAddress,
        model: Model,
        session: HttpSession,
        authentication: Authentication?
    ): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val user = authentication.principal as? CustomerUserDetails ?: throw RuntimeException("Invalid user principal")
        val customer = customerRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val cartItems = session.getAttribute("cartItems") as? CartItems ?: CartItems()
        val mapped = cartItems.toMapped(itemRepository)

        if (mapped.isEmpty()) {
            throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        }

        // TODO: Select an employee with the least orders, or other business logic
        val employee = employeeRepository.findByUsername("user1").orElseThrow()

        val country = countryRepository.findByCountryName("Poland").orElseThrow()
        var address = orderAddress.createAddress(country)
        address = addressRepository.save(address)

        var order = Order(
            customer = customer,
            assignedEmployee = employee,
            address = address
        )

        order = orderRepository.save(order)
        order.items.addAll(mapped.map { OrderItem(order, it.item, it.quantity) })
        order = orderRepository.save(order)

        session.removeAttribute("cartItems")


        model.addAttribute("path", "/user")
        model.addAttribute("id", order.id)
        return "order_confirmation"
    }

    @Suppress("UNCHECKED_CAST")
    @PostMapping(
        "/user/store/cart",
        consumes = [MediaType.APPLICATION_JSON_VALUE],
        produces = [MediaType.APPLICATION_JSON_VALUE]
    )
    fun cartAddItem(
        @RequestBody cartItem: CartItem,
        session: HttpSession
    ): ResponseEntity<String> {
        if (cartItem.quantity <= 0 || cartItem.itemId == null) {
            throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        }

        val cartItems = session.getAttribute("cartItems") as? CartItems ?: CartItems()
        cartItems.merge(cartItem.itemId, cartItem.quantity, Int::plus)
        session.setAttribute("cartItems", cartItems)

        return ResponseEntity.ok().body("Success")
    }

    @Suppress("UNCHECKED_CAST")
    @DeleteMapping("/user/store/cart")
    fun cartClear(session: HttpSession): ResponseEntity<String> {
        session.removeAttribute("cartItems")

        return ResponseEntity.ok().body("Success")
    }

    @GetMapping("/user/store/item/{id}")
    fun item(@PathVariable id: Long, model: Model, authentication: Authentication?): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val user = authentication.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")
        val item = itemRepository.findById(id).orElseThrow {
            throw ResponseStatusException(HttpStatus.NOT_FOUND)
        }

        model.addAttribute("user", user)

        val warehouses = warehousesRepository.findAllByCompanyId(user.companyId)

        model.addAttribute("item", item)
        model.addAttribute("stock", item.getMergedStock(warehouses.toList()))
        model.addAttribute("canSave", false)
        model.addAttribute("canDelete", false)

        itemRepository.save(item)

        model.addAttribute("path", "/user")

        return "store_item"
    }

    @PostMapping(
        "/user/home",
        consumes = [MediaType.APPLICATION_FORM_URLENCODED_VALUE]
    )
    fun updateDetails(model: Model, details: CustomerDetailsUpdate, authentication: Authentication?): String {
        val user = authentication?.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")

        if (user !is CustomerUserDetails) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        var customer = customerRepository.findByUsername(user.username).orElseThrow {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        customer.address.addressLine1 = details.addressLine1
        customer.address.addressLine2 = details.addressLine2
        customer.address.zipcode = details.zipcode
        customer.address.city = details.city
        customer.email = details.email
        customer.phoneNumber = details.phone
        customer.firstName = details.firstName
        customer.lastName = details.lastName
        customer.nip = details.nip

        customer = customerRepository.save(customer)

        model.addAttribute("user", customer)
        return "customer_home"
    }

    @PostMapping("/user/delete")
    fun deleteUser(authentication: Authentication?): String {
        if (authentication == null) {
            throw ResponseStatusException(HttpStatus.UNAUTHORIZED)
        }

        val user = authentication.principal as? SimpleUserDetails ?: throw RuntimeException("Invalid user principal")

        val customer = customerRepository.findByUsername(user.username).get()

        customerRepository.deleteById(customer.id!!)
        return "redirect:/user/logout"
    }
}