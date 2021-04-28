package ru.aleshi.requests.data

data class Document(
    val version: Int,
    val worksheets: List<Worksheet>,
)