package ru.aleshi.requests.data

data class Employee(
    val name: String,
    val position2: Position,
    val accessGroup: Int
) {

    fun getFully() = "$name, ${position2.name}, ${toRoman()} гр."

    fun getNameWithGroup() = "$name ${toRoman()} гр."

    fun getNameWithPosition() = "${position2.name} $name"


    private fun toRoman() =
        when (accessGroup) {
            1 -> "I"
            2 -> "II"
            3 -> "III"
            4 -> "IV"
            5 -> "V"
            else -> accessGroup.toString()
        }

}
