package com.bada.app.models

import com.bada.app.utils.UserPermissionConverter
import javax.persistence.*

@Entity
class PlatformUser(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    val id: Long
) {
    lateinit var username: String
    lateinit var password: String
    lateinit var email: String

    @Convert(converter = UserPermissionConverter::class)
    lateinit var permissions: Set<String>

}