package com.bada.app.controllers

import com.bada.app.auth.CustomerUserDetails
import com.bada.app.auth.SimpleUserDetails
import com.bada.app.models.CartItem
import com.bada.app.models.Order
import com.bada.app.models.OrderAddress
import com.bada.app.models.OrderItem
import com.bada.app.repos.*
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.server.ResponseStatusException
import javax.servlet.http.HttpSession


@Controller
class CustomerController(
    val customerRepository: CustomerRepository,
    val employeeRepository: EmployeeRepository,
    val orderRepository: OrderRepository,
    val itemRepository: ItemRepository,
    val addressRepository: AddressRepository,
    val countryRepository: CountryRepository
) {
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

    @Suppress("UNCHECKED_CAST")
    @GetMapping("/user/store")
    fun store(model: Model, session: HttpSession): String {
        val items = itemRepository.findAll()
        model.addAttribute("items", items)
        model.addAttribute("cart", true)

        val cartItems = session.getAttribute("cartItems") as? ArrayList<CartItem> ?: ArrayList()
        val mapped = cartItems.mapNotNullTo(ArrayList(), { it.load(itemRepository) })
        val cartTotalCost = mapped.sumByDouble { it.quantity * (it.item.getPrice(it.quantity) ?: 0.0) }

        model.addAttribute("cartItems", mapped)
        model.addAttribute("cartTotalCost", cartTotalCost)

        return "store"
    }

    @Suppress("DuplicatedCode")
    @GetMapping("/user/store/checkout")
    fun checkout(model: Model, session: HttpSession): String {
        val cartItems = session.getAttribute("cartItems") as? ArrayList<CartItem> ?: ArrayList()
        val mapped = cartItems.mapNotNullTo(ArrayList(), { it.load(itemRepository) })
        val cartTotalCost = mapped.sumByDouble { it.quantity * (it.item.getPrice(it.quantity) ?: 0.0) }

        model.addAttribute("cartItems", mapped)
        model.addAttribute("cartTotalCost", cartTotalCost)

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

        val cartItems = session.getAttribute("cartItems") as? ArrayList<CartItem> ?: ArrayList()
        val mapped = cartItems.mapNotNullTo(ArrayList(), { it.load(itemRepository) })

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


        // TODO: Replace with order confirm view
        return "store_checkout"
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
        if (cartItem.quantity <= 0) {
            throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        }

        val cartItems = session.getAttribute("cartItems") as? ArrayList<CartItem> ?: ArrayList()
        cartItems.add(cartItem)
        session.setAttribute("cartItems", cartItems)

        return ResponseEntity.ok().body("Success")
    }

    @Suppress("UNCHECKED_CAST")
    @DeleteMapping("/user/store/cart")
    fun cartClear(session: HttpSession): ResponseEntity<String> {
        session.removeAttribute("cartItems")

        return ResponseEntity.ok().body("Success")
    }
}