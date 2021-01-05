package com.bada.app.models

import com.bada.app.auth.Role
import com.bada.app.util.SimpleUserDetails
import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.springframework.security.core.GrantedAuthority
import java.util.*
import javax.persistence.*
import kotlin.jvm.Transient

@JsonSerialize
@Entity
@Table(name = "employees")
class Employee(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,
    @Column(unique = true)
    private var username: String,
    private var password: String,
    var email: String,
    var firstName: String,
    var lastName: String,
    var pesel: String,

    @JsonIgnore
    var employmentDate: Date,
    var phoneNumber: String,

    @Enumerated(EnumType.STRING)
    var role: Role,

    @JsonIgnore
    @OneToOne(fetch = FetchType.LAZY)
    var address: Address,

    @JsonIgnore
    @ManyToOne
    var company: Company,

    @JsonIgnore
    @ManyToOne
    var warehouse: Warehouse?,

    @JsonIgnore
    @OneToMany(mappedBy = "manager")
    val managedWarehouses: Set<Warehouse>,

    @JsonIgnore
    @OneToMany
    val salaries: List<Salary>,

    @JsonIgnore
    @OneToMany
    val scores: List<Score>

) : SimpleUserDetails {

    // Slightly funky overrides due to the way Kotlin generates getters
    override fun getUsername() = username
    override fun getPassword() = password

    @JsonIgnore
    override fun getAuthorities(): MutableCollection<out GrantedAuthority> {
        return role.getAuthorities()
    }

    fun setUsername(username: String) {
        this.username = username
    }

    fun setPassword(password: String) {
        this.password = password
    }

    @JsonIgnore
    fun getDisplayName(): String {
        return "$firstName $lastName"
    }

    fun showPermissions(): String {
        return role.permissions.joinToString(", ")
    }
}