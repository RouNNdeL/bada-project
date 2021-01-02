package com.bada.app

import com.bada.app.repos.PlatformUserRepository
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable


@Controller
class PlatformUserController(val repository: PlatformUserRepository) {
    @GetMapping("/user/{id}")
    fun userInfo(@PathVariable(value = "id") id: String, model: Model): String? {
        val user = repository.findByIdOrNull(id.toLong())
        if (user != null) {
            model.addAttribute("user", user)
            return "user"
        }

        return "not-found"
    }
}