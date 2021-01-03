package com.bada.app.utils

import com.bada.app.models.PlatformUser
import javax.persistence.AttributeConverter

class UserPermissionConverter : AttributeConverter<Set<PlatformUser.Permission>, String> {
    companion object {
        const val DELIMITER = ";"
    }

    override fun convertToDatabaseColumn(attribute: Set<PlatformUser.Permission>?): String {
        return attribute?.joinToString(DELIMITER) ?: ""
    }

    override fun convertToEntityAttribute(dbData: String?): Set<PlatformUser.Permission> {
        val permissions = PlatformUser.Permission.values().map { it.toString() }
        return HashSet(dbData?.split(DELIMITER)?.mapNotNull {
            if (permissions.contains(it)) {
                PlatformUser.Permission.valueOf(it)
            } else {
                null
            }
        } ?: emptyList())
    }
}