package com.bada.app.repos

import com.bada.app.models.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.support.JpaEntityInformation
import org.springframework.data.jpa.repository.support.SimpleJpaRepository
import org.springframework.data.repository.CrudRepository
import org.springframework.data.repository.NoRepositoryBean
import org.springframework.stereotype.Repository
import java.io.Serializable
import java.util.*
import javax.persistence.EntityManager
import javax.transaction.Transactional


@NoRepositoryBean
interface RefreshRepository<T, ID : Serializable?> : JpaRepository<T, ID> {
    fun refresh(entity: T)
}

class RefreshRepositoryImpl<T, ID : Serializable?>(
    @Suppress("SpringJavaInjectionPointsAutowiringInspection")
    entityInformation: JpaEntityInformation<T, *>,

    private val entityManager: EntityManager
) :
    SimpleJpaRepository<T, ID>(entityInformation, entityManager), RefreshRepository<T, ID> {
    @Transactional
    override fun refresh(entity: T) {
        this.entityManager.refresh(entity)
    }
}

@Repository
interface OrderRepository : CrudRepository<Order, Long>

@Repository
interface CustomerRepository : CrudRepository<Customer, Long> {
    fun findByUsername(username: String): Customer
}

@Repository
interface CompanyRepository : CrudRepository<Company, Long>

@Repository
interface EmployeeRepository : CrudRepository<Employee, Long> {
    fun findEmployeesByCompanyId(companyId: Long) : Set<Employee>
    fun findEmployeeByUsername(username: String): Optional<Employee>
}

@Repository
interface AddressRepository : CrudRepository<Address, Long> {
    fun findAddressById(addressId: Long): Address
}

@Repository
interface WarehousesRepository : CrudRepository<Warehouse, Long>
