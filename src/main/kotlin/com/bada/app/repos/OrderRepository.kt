package com.bada.app.repos

import com.bada.app.models.Order
import org.springframework.data.repository.CrudRepository

interface OrderRepository : CrudRepository<Order, Long>