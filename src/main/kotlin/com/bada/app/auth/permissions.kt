package com.bada.app.auth

import org.springframework.security.core.authority.SimpleGrantedAuthority

enum class Permissions {
    READ_STOCK,
    READ_SELF,
    CREATE_ORDER,
    WRITE_STOCK,
    HANDLE_ORDER,
    ASSIGN_ORDERS,
    READ_EMPLOYEES,
    WRITE_EMPLOYEES
}

enum class Role(permissions: MutableList<Permissions>) {
    CUSTOMER(arrayListOf(Permissions.READ_STOCK, Permissions.CREATE_ORDER)),
    WAREHOUSE_EMPLOYEE(arrayListOf(Permissions.READ_STOCK, Permissions.WRITE_STOCK, Permissions.HANDLE_ORDER));

    val permissions: List<String>
    init {
        val permissionList = permissions.mapTo(ArrayList()) { it.name }
        permissionList.add("ROLE_$name")
        this.permissions = permissionList
    }

    fun getAuthorities() = permissions.map { SimpleGrantedAuthority(it) }.toMutableList()
}