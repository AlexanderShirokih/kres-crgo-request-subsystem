package ru.aleshi.requests.data

data class RequestItem(
    val accountId: Int?,
    val name: String,
    val address: String,
    val reqType: String,
    val fullReqType: String,
    val reason: String?,
    var additionalInfo: String = "",
    var counterInfo: String = ""
)