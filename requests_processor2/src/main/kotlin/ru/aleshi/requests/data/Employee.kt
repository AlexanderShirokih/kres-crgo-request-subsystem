package ru.aleshi.requests.data

data class Employee(
    val name: String,
    val position: String,
    val accessGroup: Int
) {

    fun getFully() = "$name, $position, ${toRoman()} гр."

    fun getNameWithGroup() = "$name ${toRoman()} гр."

    fun getNameWithPosition() = "$position $name"


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
