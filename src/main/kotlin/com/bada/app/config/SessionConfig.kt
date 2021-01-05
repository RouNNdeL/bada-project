package com.bada.app.config

import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.beans.factory.BeanClassLoaderAware
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer
import org.springframework.data.redis.serializer.RedisSerializer
import org.springframework.security.jackson2.SecurityJackson2Modules


@Configuration
class SessionConfig : BeanClassLoaderAware {
    private var loader: ClassLoader? = null
    @Bean
    fun springSessionDefaultRedisSerializer(): RedisSerializer<Any> {
        return GenericJackson2JsonRedisSerializer(objectMapper())
    }

    /**
     * Customized {@link ObjectMapper} to add mix-in for class that doesn't have default
     * constructors
     * @return the {@link ObjectMapper} to use
     */
    private fun objectMapper(): ObjectMapper {
        val mapper = ObjectMapper()
        mapper.registerModules(SecurityJackson2Modules.getModules(loader))
        return mapper
    }

    /*
	 * (non-Javadoc)
	 *
	 * @see
	 * org.springframework.beans.factory.BeanClassLoaderAware#setBeanClassLoader(java.lang
	 * .ClassLoader)
	 */
    override fun setBeanClassLoader(classLoader: ClassLoader) {
        loader = classLoader
    }
}