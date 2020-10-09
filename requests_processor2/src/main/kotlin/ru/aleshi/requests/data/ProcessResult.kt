package ru.aleshi.requests.data

data class ProcessResult<T>(
    val data: T?,
    val error: String = "",
    val stackTrace: String = ""
)

