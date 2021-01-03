package com.bada.app.models

import java.util.*
import javax.persistence.*

@Entity
@Table(name = "salaries")
class Salary(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    @Column(name = "salary_date")
    val date: Date,

    val salary: Double
)