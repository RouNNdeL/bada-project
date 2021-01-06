package com.bada.app.auth

import com.bada.app.auth.Role
import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.UserDetails

@JsonSerialize
open class SimpleUserDetails(
    private val username: String,
    private val password: String,
    private val role: Role,
) : UserDetails {
    constructor() : this("", "", Role.DEFAULT)

    @JsonIgnore
    override fun getAuthorities(): MutableCollection<out GrantedAuthority> {
        return role.getAuthorities()
    }

    @JsonIgnore
    override fun getPassword(): String {
        return password
    }

    @JsonIgnore
    override fun getUsername(): String {
        return username
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
    constructor(username: String, password: String, role: Role) : super(username, password, role)
}

@JsonSerialize
class CustomerUserDetails : SimpleUserDetails {
    constructor() : super()
    constructor(username: String, password: String, role: Role) : super(username, password, role)
}