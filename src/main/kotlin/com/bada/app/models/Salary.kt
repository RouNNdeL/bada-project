package com.bada.app.models

import java.util.*
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Table

@Entity
@Table(name = "salaries")
class Salary(
    @Column(name = "salary_date")
    val date: Date,

    val salary: Double
) : AbstractEntity<Long>()