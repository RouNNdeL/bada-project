package com.bada.app.controllers

import com.bada.app.auth.CustomerUserDetails
import com.bada.app.auth.EmployeeUserDetails
import org.springframework.boot.web.servlet.error.ErrorController
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.servlet.ModelAndView
import javax.servlet.http.HttpServletRequest


@Controller
class ErrorHandler : ErrorController {

    @RequestMapping("/error")
    fun error(authentication: Authentication?, request: HttpServletRequest): ModelAndView {
        val model = ModelAndView("error")

        if (authentication == null) {
            model.addObject("loggedIn", false)
        } else {
            model.addObject("loggedIn", true)
            model.addObject(
                "path", when (authentication.principal) {
                    is CustomerUserDetails -> "/user"
                    is EmployeeUserDetails -> "/management"
                    else -> throw RuntimeException("Invalid pricipal")
                }
            )
        }

        model.addObject("error", "HTTP ${getErrorCode(request)}")

        return model
    }

    private fun getErrorCode(httpRequest: HttpServletRequest): Int {
        return httpRequest
            .getAttribute("javax.servlet.error.status_code") as Int
    }

    override fun getErrorPath(): String {
        return "/error"
    }
}