package ru.aleshi.requests.core

import org.apache.poi.hssf.usermodel.HSSFWorkbook
import org.apache.poi.ss.usermodel.CellType
import ru.aleshi.requests.data.ConnectionPoint
import ru.aleshi.requests.data.CounterInfo
import ru.aleshi.requests.data.RequestItem
import ru.aleshi.requests.data.RequestType
import java.nio.file.Files
import java.nio.file.Path

class RequestParser {

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


    private fun createNewRequest(mainLine: List<String>): RequestItem {
        val requestType = mainLine[4].substringAfter("/").trim()
        val reason = mainLine[5].capitalize().trim()

        return RequestItem(
            accountId = mainLine[1].toInt(),
            name = mainLine[2],
            address = mainLine[3].substringAfter("Керчь").replace(",", "").trim(),
            type = RequestType(
                short = requestType,
                full = requestType,
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
}
