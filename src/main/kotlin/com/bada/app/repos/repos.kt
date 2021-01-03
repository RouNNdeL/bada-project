package com.bada.app.repos

import com.bada.app.models.Company
import com.bada.app.models.Customer
import com.bada.app.models.Employee
import com.bada.app.models.Order
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
