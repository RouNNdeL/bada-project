package com.bada.app.auth

import org.springframework.security.core.authority.SimpleGrantedAuthority

enum class Permission {
    READ_STOCK,
    READ_SELF,
    CREATE_ORDER,
    CHANGE_STOCK,
    CHANGE_STOCK_ALL,
    CHANGE_PRICE,
    HANDLE_ORDER,
    ASSIGN_ORDERS,
    READ_EMPLOYEES,
    WRITE_EMPLOYEES,
    DELETE_ITEM,
    ADD_ITEM
}

enum class Role(permissions: MutableList<Permission>) {
    DEFAULT(arrayListOf()),
    CUSTOMER(arrayListOf(Permission.READ_STOCK, Permission.CREATE_ORDER)),
    WAREHOUSE_EMPLOYEE(arrayListOf(Permission.READ_STOCK, Permission.CHANGE_STOCK, Permission.HANDLE_ORDER)),
    WAREHOUSE_MANAGER(
        arrayListOf(
            Permission.READ_STOCK,
            Permission.CHANGE_STOCK,
            Permission.ASSIGN_ORDERS,
            Permission.CHANGE_PRICE,
            Permission.DELETE_ITEM,
            Permission.ADD_ITEM
        )
    );

    val permissions: List<String>

    init {
        val permissionList = permissions.mapTo(ArrayList()) { it.name }
        permissionList.add("ROLE_$name")
        this.permissions = permissionList
    }

    fun hasPermission(permission: Permission): Boolean {
        return hasPermission(permission.name)
    }

    fun hasPermission(permission: String): Boolean {
        return permissions.contains(permission)
    }

    fun getAuthorities() = permissions.map { SimpleGrantedAuthority(it) }.toMutableList()
}