package ru.aleshi.requests.data

data class RequestItem(
    val accountId: Int?,
    val name: String,
    val address: String,
    var phone: String?,
    var connectionPoint: ConnectionPoint?,
    val type: RequestType,
    val reason: String?,
    var counter: CounterInfo?,
    var additionalInfo: String = "",

    ) {

    val counterInfo: String
        get() = counter?.fullInfo ?: "ПУ отсутств."

    val fullAdditional: String
        get() =
            listOfNotNull(connectionPoint?.formatted, phone, additionalInfo)
                .map { it.trim() }
                .filter { it.isNotBlank() }
                .joinToString(separator = " | ")
}