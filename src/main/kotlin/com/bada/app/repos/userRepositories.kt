package com.bada.app.repos

import com.bada.app.models.Customer
import com.bada.app.models.PlatformUser
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository

@Repository
interface PlatformUserRepository : CrudRepository<PlatformUser, Long>

@Repository
interface CustomerRepository : CrudRepository<Customer, Long> {
    fun findByUsername(username: String) : Customer
}
