package com.bada.app.models

import com.bada.app.utils.UserPermissionConverter
import javax.persistence.*

// TODO: Merge PlatformUser properties into both Customer and Employee
@Entity
@Table(name = "platform_users")
@Inheritance(strategy = InheritanceType.JOINED)
open class PlatformUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id", updatable = false)
    open val userId: Long = -1
    open lateinit var username: String
    open lateinit var password: String
    open lateinit var email: String

    @Convert(converter = UserPermissionConverter::class)
    open lateinit var permissions: Set<Permission>

    enum class Permission {
        USER,
        EMPLOYEE,
        ADMIN
    }
}