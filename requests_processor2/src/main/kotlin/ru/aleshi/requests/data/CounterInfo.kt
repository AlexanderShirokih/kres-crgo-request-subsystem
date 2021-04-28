package ru.aleshi.requests.data

data class CounterInfo(
    val type: String,
    val number: String,
    val quarter: Int?,
    val year: Int?,
) {
    val fullInfo: String
        get() = "№$number $type $checkDate".trim()

    val hasCheckDate get() = quarter != null && year != null

    val romanQuarter
        get() = when (quarter) {
            1 -> "I"
            2 -> "II"
            3 -> "III"
            4 -> "IV"
            else -> "?"
        }

    val checkDate
        get() = if (hasCheckDate) "п. $romanQuarter-$formattedYear" else ""

    val formattedYear
        get() = year?.toString()?.takeLast(2) ?: ""
}