package com.bada.app.utils

import com.cesarferreira.pluralize.pluralize
import org.hibernate.boot.model.naming.Identifier
import org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
import org.hibernate.engine.jdbc.env.spi.JdbcEnvironment

/**
 * Modified by RouNdeL to also pluralize
 *
 * Maps the JPA camelCase properties to snake_case database identifiers.
 *
 *
 * For more details about how to use it, check out [this article](https://vladmihalcea.com/map-camel-case-properties-snake-case-column-names-hibernate/) on [vladmihalcea.com](https://vladmihalcea.com/).
 *
 * @author Vlad Mihalcea
 */
class NamingStrategy : PhysicalNamingStrategyStandardImpl() {

    override fun toPhysicalCatalogName(name: Identifier?, context: JdbcEnvironment?): Identifier? {
        return formatIdentifier(super.toPhysicalCatalogName(name, context))
    }

    override fun toPhysicalSchemaName(name: Identifier?, context: JdbcEnvironment): Identifier? {
        return formatIdentifier(super.toPhysicalSchemaName(name, context))
    }

    override fun toPhysicalTableName(name: Identifier?, context: JdbcEnvironment): Identifier? {
        return formatWithPlural(super.toPhysicalTableName(name, context))
    }

    override fun toPhysicalSequenceName(name: Identifier?, context: JdbcEnvironment): Identifier? {
        return formatIdentifier(super.toPhysicalSequenceName(name, context))
    }

    override fun toPhysicalColumnName(name: Identifier?, context: JdbcEnvironment): Identifier? {
        return formatIdentifier(super.toPhysicalColumnName(name, context))
    }

    private fun formatWithPlural(identifier: Identifier?): Identifier? {
        val newIdentifier = formatIdentifier(identifier)
        return if (newIdentifier != null) {
            val name = newIdentifier.text
            val words = ArrayList(name.split("_"))
            words[words.lastIndex] = words.last().pluralize()
            return Identifier.toIdentifier(words.joinToString("_"))
        } else {
            null
        }
    }

    private fun formatIdentifier(identifier: Identifier?): Identifier? {
        return if (identifier != null) {
            val name = identifier.text
            val formattedName = name.replace(CAMEL_CASE_REGEX.toRegex(), SNAKE_CASE_PATTERN).toLowerCase()
            if (formattedName != name) Identifier.toIdentifier(formattedName, identifier.isQuoted) else identifier
        } else {
            null
        }
    }

    companion object {
        val INSTANCE = NamingStrategy()
        const val CAMEL_CASE_REGEX = "([a-z]+)([A-Z]+)"
        const val SNAKE_CASE_PATTERN = "$1\\_$2"
    }
}