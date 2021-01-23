package com.bada.app.repos

import com.bada.app.models.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.support.JpaEntityInformation
import org.springframework.data.jpa.repository.support.SimpleJpaRepository
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
interface OrderRepository : JpaRepository<Order, Long>

@Repository
interface CustomerRepository : JpaRepository<Customer, Long> {
    fun findByUsername(username: String): Optional<Customer>
}

@Repository
interface CompanyRepository : JpaRepository<Company, Long>

@Repository
interface EmployeeRepository : JpaRepository<Employee, Long> {
    fun findAllByCompanyId(companyId: Long): Set<Employee>
    fun findByUsername(username: String): Optional<Employee>
}

@Repository
interface AddressRepository : JpaRepository<Address, Long> {
    fun findAddressById(addressId: Long): Address
}

@Repository
interface WarehousesRepository : JpaRepository<Warehouse, Long> {
    fun findAllByCompanyId(companyId: Long): Iterable<Warehouse>
}

@Repository
interface WarehouseItemRepository : JpaRepository<WarehouseItem, Long>

@Repository
interface ItemRepository : JpaRepository<Item, Long>

@Repository
interface PriceRangeRepository : JpaRepository<PriceRange, Long>

@Repository
interface CountryRepository: JpaRepository<Country, Long>{
    fun findByCountryName(countryName: String): Optional<Country>
}
