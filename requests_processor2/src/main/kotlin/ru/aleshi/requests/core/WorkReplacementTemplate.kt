package ru.aleshi.requests.core

class WorkReplacementTemplate(
    val pattern: String,
    val shortName: String,
    val fullName: String
) {
    constructor(default: String) : this(default, default, default)
}