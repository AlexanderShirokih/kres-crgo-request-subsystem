package ru.aleshi.requests.data

import java.text.SimpleDateFormat
import java.time.Instant
import java.util.*

data class Worksheet
    (
    val name: String,
    val mainEmployee: Employee,
    val chiefEmployee: Employee,
    val membersEmployee: List<Employee>,
    val requests: List<RequestItem>,
    val workTypes: List<String>,
    val date: Long
) {

    private val dateTime: Date
        get() = Date.from(Instant.ofEpochMilli(date))

    val day: String
        get() = SimpleDateFormat("dd").format(dateTime)

    val month: String
        get() = SimpleDateFormat("MM").format(dateTime)

    val year: String
        get() = SimpleDateFormat("yyyy г.").format(dateTime)

    val fullDate: String
        get() = SimpleDateFormat("dd.MM.yyyy").format(dateTime)
}
