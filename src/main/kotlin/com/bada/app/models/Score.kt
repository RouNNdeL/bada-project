package com.bada.app.models

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Table

@Entity
@Table(name = "scores")
class Score(
    @Column(name = "score_year")
    var year: Int,

    @Column(name = "score_quarter")
    var quarter: Int,

    var score: Double
) : AbstractEntity<Long>()