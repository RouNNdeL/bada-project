package com.bada.app.repos

import com.bada.app.models.PlatformUser
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository

@Repository
interface PlatformUserRepository : CrudRepository<PlatformUser, Long> {
    fun findOneById(id: Long): PlatformUser
}