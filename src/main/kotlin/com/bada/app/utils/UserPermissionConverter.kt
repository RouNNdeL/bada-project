package com.bada.app.utils

import com.bada.app.models.Employee
import javax.persistence.AttributeConverter

class UserPermissionConverter : AttributeConverter<Set<Employee.Permission>, String> {
    companion object {
        const val DELIMITER = ";"
    }

    override fun convertToDatabaseColumn(attribute: Set<Employee.Permission>?): String {
        return attribute?.joinToString(DELIMITER) ?: ""
    }

    override fun convertToEntityAttribute(dbData: String?): Set<Employee.Permission> {
        val permissions = Employee.Permission.values().map { it.toString() }
        return HashSet(dbData?.split(DELIMITER)?.mapNotNull {
            if (permissions.contains(it)) {
                Employee.Permission.valueOf(it)
            } else {
                null
            }
        } ?: emptyList())
    }
}