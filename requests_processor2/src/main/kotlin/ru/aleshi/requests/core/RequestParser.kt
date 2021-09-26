package ru.aleshi.requests.core

import org.apache.poi.hssf.usermodel.HSSFWorkbook
import org.apache.poi.ss.usermodel.CellType
import ru.aleshi.requests.data.ConnectionPoint
import ru.aleshi.requests.data.CounterInfo
import ru.aleshi.requests.data.RequestItem
import ru.aleshi.requests.data.RequestType
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
                it.copy(counter = null)
            else it
        }
    }


    private fun createNewRequest(
        mainLine: List<String>
    ): RequestItem {
        val requestType = translateRequestType(mainLine[4].substringAfter("/").trim())
        val reason = mainLine[5].capitalize().trim()

        return RequestItem(
            accountId = mainLine[1].toInt(),
            name = mainLine[2],
            address = mainLine[3].substringAfter("Керчь").replace(",", "").trim(),
            type = RequestType(
                short = requestType.shortName,
                full = requestType.fullName,
            ),
            reason = reason.substringBefore("/").trim(),
            additionalInfo = reason.substringAfter("/").trim(),
            phone = "",
            connectionPoint = null,
            counter = null,
        )
    }

    private fun attachCounterInfo(requestItem: RequestItem, line: List<String>) {
        Regex("№ (\\d+) (.+) ([\\d] p\\.)(.*) госп: ([\\d]{2}\\.[\\d]{2}.[\\d]{4})")
            .find(line[0])
            ?.let { counterMatch ->
                val (number, type, _, _, checkDate) = counterMatch.groups.drop(1).map { it!!.value }
                val (_, month, year) = checkDate.split(".")

                val counter = CounterInfo(
                    number = number,
                    type = type,
                    quarter = month.toInt() / 4 + 1,
                    year = year.toInt()
                )
                requestItem.counter = counter
            }
    }

    private fun attachAdditionalInfo(requestItem: RequestItem, line: List<String>) {
        val tpMatch = Regex("ТП: ([ТРП\\w]+)").find(line[0])
        val lineMatch = Regex("Ф\\. (\\d+)").find(line[0])
        val pillarMatch = Regex("оп\\. ([\\w/]+)").find(line[0])

        ConnectionPoint(
            tp = tpMatch?.groups?.get(1)?.value,
            line = lineMatch?.groups?.get(1)?.value,
            pillar = pillarMatch?.groups?.get(1)?.value,
        )
            .takeIf { !it.isEmpty }
            ?.run { requestItem.connectionPoint = this }

        Regex("тел\\.: \\+?(\\d{5,12})").find(line[0])?.run {
            requestItem.phone = groups[1]!!.value
        }

        Regex("Мощность: (\\d{1,3},?\\d?)").find(line[0])?.run {
            val power = groups[1]!!.value
            if (power != "0") {
                requestItem.addAdditionalInfo("М: $power")
            }
        }
    }

    private fun translateRequestType(requestType: String): WorkReplacementTemplate =
        defaultReqTypeReplacements.firstOrNull { it.pattern == requestType } ?: WorkReplacementTemplate(
            requestType
        )
}
