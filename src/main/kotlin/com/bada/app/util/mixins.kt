package com.bada.app.util

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import com.fasterxml.jackson.annotation.JsonTypeInfo


@JsonTypeInfo(use = JsonTypeInfo.Id.CLASS, include = JsonTypeInfo.As.PROPERTY)
@JsonIgnoreProperties(ignoreUnknown = true, value = ["cause", "stackTrace"])
internal class InternalAuthenticationServiceExceptionMixin
@JsonCreator constructor(@JsonProperty("message") message: String?)

@JsonTypeInfo(use = JsonTypeInfo.Id.CLASS, include = JsonTypeInfo.As.PROPERTY)
@JsonIgnoreProperties(ignoreUnknown = true, value = ["cause", "stackTrace"])
internal class InvalidDataAccessApiUsageExceptionMixin
@JsonCreator constructor(@JsonProperty("message") message: String?)

@JsonTypeInfo(use = JsonTypeInfo.Id.CLASS, include = JsonTypeInfo.As.PROPERTY)
@JsonIgnoreProperties(ignoreUnknown = true, value = ["cause", "stackTrace"])
internal class IllegalArgumentExceptionMixin
@JsonCreator constructor(@JsonProperty("message") message: String?)