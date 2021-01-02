package com.bada.app.utils

import javax.persistence.AttributeConverter
import kotlin.reflect.KClass

class UserPermissionConverter : AttributeConverter<Set<String>, String> {
    companion object {
        const val DELIMITER = ";"
    }

    override fun convertToDatabaseColumn(attribute: Set<String>?): String {
        return attribute?.joinToString(DELIMITER) ?: ""
    }

    override fun convertToEntityAttribute(dbData: String?): Set<String> {
        return HashSet(dbData?.split(DELIMITER) ?: emptyList())
    }
}