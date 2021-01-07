package com.bada.app.auth

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.UserDetails

@JsonSerialize
open class SimpleUserDetails(
    private var username: String,
    private var password: String,
    var role: Role,
    var companyId: Long
) : UserDetails {
    constructor() : this("", "", Role.DEFAULT, -1)

    @JsonIgnore
    override fun getAuthorities(): MutableCollection<out GrantedAuthority> {
        return role.getAuthorities()
    }

    @JsonIgnore
    fun hasPermission(permission: Permission): Boolean {
        return role.hasPermission(permission)
    }

    override fun getPassword(): String {
        return password
    }

    override fun getUsername(): String {
        return username
    }

    fun setUsername(username: String) {
        this.username = username
    }

    fun setPassword(password: String) {
        this.password = password
    }

    @JsonIgnore
    override fun isAccountNonExpired() = true

    @JsonIgnore
    override fun isAccountNonLocked() = true

    @JsonIgnore
    override fun isCredentialsNonExpired() = true

    @JsonIgnore
    override fun isEnabled() = true
}

@JsonSerialize
class EmployeeUserDetails : SimpleUserDetails {
    constructor() : super()
    constructor(username: String, password: String, role: Role, companyId: Long) :
            super(username, password, role, companyId)
}

@JsonSerialize
class CustomerUserDetails : SimpleUserDetails {
    constructor() : super()
    constructor(username: String, password: String, companyId: Long) :
            super(username, password, Role.CUSTOMER, companyId)
}