package com.bada.app.models

import javax.persistence.*

@Entity
@Table(name = "scores")
class Score(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(updatable = false, nullable = false)
    val id: Long,

    @Column(name = "score_year")
    var year: Int,

    @Column(name = "score_quarter")
    var quarter: Int,

    var score: Double
)