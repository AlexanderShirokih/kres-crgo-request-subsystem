package ru.aleshi.requests.core

import org.apache.poi.ss.usermodel.CellType
import org.apache.poi.xssf.usermodel.XSSFRow
import org.apache.poi.xssf.usermodel.XSSFSheet
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import ru.aleshi.requests.data.RequestItem
import ru.aleshi.requests.data.Worksheet
import java.nio.file.Files
import java.nio.file.Paths


class XlsxExporter(private val worksheets: Array<Worksheet>) {

    fun export(destinationPath: String) {
        XSSFWorkbook().use { workbook ->

            for (worksheet in worksheets) {
                writeWorksheet(worksheet, workbook.createSheet(worksheet.name))
            }

            workbook.write(Files.newOutputStream(Paths.get(destinationPath)))
        }

    }

    private fun writeWorksheet(worksheet: Worksheet, sheet: XSSFSheet) {
        val members =
            if (worksheet.membersEmployee.isEmpty()) "--" else worksheet.membersEmployee
                .joinToString { it.name }

        sheet.createRow(0).createCell(0, CellType.STRING)
            .setCellValue("Призводитель работ: ${worksheet.mainEmployee.name}")
        sheet.createRow(1).createCell(0, CellType.STRING)
            .setCellValue(if (worksheet.membersEmployee.size > 1) "Члены бригады: $members" else "Член бригады: $members")

        writeRequestsHeader(sheet.createRow(2))
        worksheet.requests.forEachIndexed { index, request ->
            writeRequest(request, index + 1, sheet.createRow(index + 3))
        }
    }

    private fun writeRequestsHeader(row: XSSFRow) {
        row.createStringCell(0, "№")
        row.createStringCell(1, "Л/С")
        row.createStringCell(2, "Потребитель")
        row.createStringCell(3, "Адрес")
        row.createStringCell(4, "ПУ")
        row.createStringCell(5, "Тип заявки")
        row.createStringCell(6, "Дополнительно")
    }

    private fun writeRequest(request: RequestItem, position: Int, row: XSSFRow) {
        row.createStringCell(0, position.toString())
        row.createStringCell(1, request.accountId?.toString() ?: "--")
        row.createStringCell(2, request.name)
        row.createStringCell(3, request.address)
        row.createStringCell(4, request.counterInfo)
        row.createStringCell(5, request.reqType)
        row.createStringCell(6, request.additionalInfo)
    }

    private fun XSSFRow.createStringCell(column: Int, value: String) =
        createCell(column, CellType.STRING).setCellValue(value)

}