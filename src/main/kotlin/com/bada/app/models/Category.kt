package com.bada.app.models

import javax.persistence.Entity
import javax.persistence.Table

@Entity
@Table(name = "categories")
class Category(
    var name: String,
    var description: String
) : AbstractEntityLong()