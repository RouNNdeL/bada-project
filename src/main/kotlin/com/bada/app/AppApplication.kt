package com.bada.app

import com.bada.app.repos.RefreshRepositoryImpl
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.data.jpa.repository.config.EnableJpaRepositories

@SpringBootApplication
@EnableJpaRepositories(repositoryBaseClass = RefreshRepositoryImpl::class)
class AppApplication

fun main(args: Array<String>) {
    runApplication<AppApplication>(*args)
}
