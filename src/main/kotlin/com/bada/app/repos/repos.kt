package com.bada.app.repos

import com.bada.app.models.*
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository

@Repository
interface OrderRepository : CrudRepository<Order, Long>

@Repository
interface CustomerRepository : CrudRepository<Customer, Long> {
    fun findByUsername(username: String) : Customer
}

@Repository
interface CompanyRepository : CrudRepository<Company, Long>

@Repository
interface EmployeeRepository : CrudRepository<Employee, Long> {
    fun findEmployeesByCompanyId(companyId: Long) : Set<Employee>
}

@Repository
interface AddressRepository : CrudRepository<Address, Long> {
    fun findAddressById(addressId: Long) : Address
}
