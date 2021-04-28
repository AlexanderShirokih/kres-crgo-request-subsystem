package ru.aleshi.requests.data

data class ConnectionPoint(
    val tp: String?,
    val line: String?,
    val pillar: String?
) {

    val isEmpty: Boolean
        get() = line.isNullOrBlank() && tp.isNullOrBlank() && pillar.isNullOrBlank()

    val formatted: String
        get() {
            val buffer = StringBuilder()

            if (tp != null) {
                buffer.append("TП: $tp ")
            }

            if (line != null) {
                buffer.append("Ф: $line ")
            }

            if (pillar != null) {
                buffer.append("оп: $line")
            }

            return buffer.trim().toString()
        }
}