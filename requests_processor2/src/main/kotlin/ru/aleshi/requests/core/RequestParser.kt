package ru.aleshi.requests.core

import org.apache.poi.hssf.usermodel.HSSFWorkbook
import org.apache.poi.ss.usermodel.CellType
import ru.aleshi.requests.data.RequestItem
import java.nio.file.Files
import java.nio.file.Path

object RequestParser {
    private val defaultReqTypeReplacements =
        listOf(
            WorkReplacementTemplate(
                "\u0437\u0430\u043c\u0435\u043d\u0430 \u0441\u0447\u0435\u0442\u0447\u0438\u043a\u0430",
                "\u0437\u0430\u043c\u0435\u043d\u0430",
                "\u0417\u0430\u043c\u0435\u043d\u0430 \u041f\u0423"
            ),
            WorkReplacementTemplate(
                "\u0437\u0430\u043c\u0435\u043d\u0430 \u0441\u0447\u0435\u0442\u0447\u0438\u043a\u0430 (\u043f\u043e \u0437\u0430\u044f\u0432\u043b\u0435\u043d\u0438\u044e)",
                "\u043f\u043e \u0441\u0440\u043e\u043a\u0443",
                "\u0417\u0430\u043c\u0435\u043d\u0430 \u041f\u0423"
            ),
            WorkReplacementTemplate(
                "\u0442\u0435\u0445\u043d\u0438\u0447\u0435\u0441\u043a\u0438\u0435 \u0440\u0435\u043a\u043e\u043c\u0435\u043d\u0434\u0430\u0446\u0438\u0438",
                "\u0432\u044b\u0432\u043e\u0434",
                "\u0420\u0430\u0441\u043f\u043b\u043e\u043c\u0431\u0438\u0440\u043e\u0432\u043a\u0430"
            ),
            WorkReplacementTemplate(
                "\u043e\u043f\u043b\u043e\u043c\u0431\u0438\u0440\u043e\u0432\u043a\u0430",
                "\u043e\u043f\u043b\u043e\u043c\u0431.",
                " \u041e\u043f\u043b\u043e\u043c\u0431\u0438\u0440\u043e\u0432\u043a\u0430"
            ),
            WorkReplacementTemplate(
                "\u0440\u0430\u0441\u043f\u043b\u043e\u043c\u0431\u0438\u0440\u043e\u0432\u043a\u0430",
                "\u0440\u0430\u0441\u043f\u043b\u043e\u043c\u0431.",
                "\u0420\u0430\u0441\u043f\u043b\u043e\u043c\u0431\u0438\u0440\u043e\u0432\u043a\u0430"
            ),
            WorkReplacementTemplate(
                "\u0442\u0435\u0445\u043d\u0438\u0447\u0435\u0441\u043a\u0430\u044f \u043f\u0440\u043e\u0432\u0435\u0440\u043a\u0430",
                "\u0442\u0435\u0445. \u043f\u0440\u043e\u0432.",
                "\u0422\u0435\u0445. \u041f\u0440\u043e\u0432\u0435\u0440\u043a\u0430"
            ),
            WorkReplacementTemplate(
                "\u043f\u043e\u0434\u043a\u043b\u044e\u0447\u0435\u043d\u0438\u0435 (\u043f\u043e \u0437\u0430\u044f\u0432\u043b\u0435\u043d\u0438\u044e)",
                "\u043f\u043e\u0434\u043a\u043b.",
                "\u041f\u043e\u0434\u043a\u043b\u044e\u0447\u0435\u043d\u0438\u0435"
            )
        )

    fun parse(filePath: Path): List<RequestItem> {
        val requests = mutableListOf<RequestItem>()

        HSSFWorkbook(Files.newInputStream(filePath)).use { workbook ->
            workbook.getSheetAt(0)
                .rowIterator()
                .asSequence()
                .forEach { row ->
                    val line = row.cellIterator().asSequence()
                        .filter { it.cellType == CellType.STRING }
                        .map { it.stringCellValue }
                        .filter(String::isNotBlank)
                        .toList()

                    when {
                        row.firstCellNum == 0.toShort() &&
                                row.getCell(0).stringCellValue.toIntOrNull() != null -> {
                            // Found a new request
                            requests.add(createNewRequest(line))
                        }
                        line.isNotEmpty() && line.first().startsWith("Т.учета") -> {
                            attachCounterInfo(requests.last(), line)
                        }
                        line.isNotEmpty() && (line.first().contains("ТП:") || line.first().contains("тел.:")) -> {
                            attachAdditionalInfo(requests.last(), line)
                        }
                    }
                }
        }

        return requests.map {
            if (it.counterInfo.isBlank())
                it.copy(counterInfo = "ПУ отсутств.")
            else it
        }
    }


    private fun createNewRequest(
        mainLine: List<String>
    ): RequestItem {
        val requestType = translateRequestType(mainLine[4].substringAfter("/").trim())

        return RequestItem(
            accountId = mainLine[1].toInt(),
            name = mainLine[2],
            address = mainLine[3].substringAfter("Керчь").trim(),
            reqType = requestType.shortName,
            fullReqType = requestType.fullName,
            reason = capitalize(mainLine[5].trim())
        )
    }

    private fun attachCounterInfo(requestItem: RequestItem, line: List<String>) {
        val counterInfo = line[0].substringAfter("Счетчик:").substringBefore(" p.").trim()
        val gp = translateCheckDate(line[0].substringAfter("госп: ", "").substringBefore(" место"))

        requestItem.counterInfo = if (counterInfo == "нет") "ПУ отсутств." else counterInfo
            .substringBefore("госп:")
            .dropLast(1)
            .trim() + gp
    }

    private fun attachAdditionalInfo(requestItem: RequestItem, line: List<String>) {
        requestItem.additionalInfo = sanitizeAdditionalInfo(line[0])
    }

    private fun translateCheckDate(rawCD: String): String {
        return if (rawCD.isEmpty()) ""
        else {
            try {
                buildString {
                    val (_, m, y) = rawCD.split(".")

                    append("| п. ")
                    append(
                        when (m.toInt()) {
                            in 1..3 -> "I"
                            in 4..6 -> "II"
                            in 7..9 -> "III"
                            in 10..12 -> "VI"
                            else -> "???"
                        }
                    )
                    append('-')
                    append(y.takeLast(2))
                }
            } catch (_: IndexOutOfBoundsException) {
                ""
            }
        }
    }

    private fun translateRequestType(requestType: String): WorkReplacementTemplate =
        defaultReqTypeReplacements.firstOrNull { it.pattern == requestType } ?: WorkReplacementTemplate(
            requestType
        )


    private fun sanitizeAdditionalInfo(additional: String): String {
        return additional
            .replace(Regex("\\([\\dR-]+\\)"), "")
            .replace(Regex("Мощность: (2,2[\\d]+|3,5|0)"), "")
            .replace("Мощность:", "М:")
            .replace("тел.: ", "")
            .replace("+", "")
            .dropLastWhile { it == ' ' || it == '|' }
    }

    private fun capitalize(line: String) = line.take(1).toUpperCase() + line.drop(1)
}