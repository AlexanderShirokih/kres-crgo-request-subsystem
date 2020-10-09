package ru.aleshi.requests.core

import com.google.gson.Gson
import org.apache.commons.lang3.text.WordUtils
import org.apache.pdfbox.pdmodel.PDDocument
import org.apache.pdfbox.pdmodel.PDPage
import org.apache.pdfbox.pdmodel.PDPageContentStream
import org.apache.pdfbox.pdmodel.font.PDFont
import org.apache.pdfbox.pdmodel.font.PDType0Font
import ru.aleshi.requests.data.RequestItem
import ru.aleshi.requests.data.Worksheet
import java.awt.Color
import java.nio.file.Files
import java.nio.file.Paths


class PdfExporter(
    private val destinationPath: String,
    private val sourcePath: String
) {

    private val loader = PdfExporter::class.java.classLoader

    fun export() {
        val worksheets = loadWorksheets()
        val target = PDDocument()
        val font = PDType0Font.load(
            target,
            loader.getResourceAsStream("fonts/Roboto-Regular.ttf"), false
        )

        writeOrders(target, worksheets, font)
        writeLists(target, worksheets, font)

        target.save(destinationPath)
        target.close()
    }

    private fun writeOrders(target: PDDocument, worksheets: Array<Worksheet>, font: PDFont) {
        val orderTemplate = PDDocument.load(loader.getResourceAsStream("templates/order.pdf"))

        for (worksheet in worksheets) {
            writeFirstPage(target, target.importPage(orderTemplate.getPage(0)), font, worksheet)
            writeSecondPage(target, target.importPage(orderTemplate.getPage(1)), font, worksheet);
        }
    }

    private fun writeFirstPage(target: PDDocument, page: PDPage, font: PDFont, worksheet: Worksheet) {
        PDPageContentStream(target, page, PDPageContentStream.AppendMode.APPEND, false).use { content ->
            writeHeading(content, worksheet, font)
            writeFirstPageRequests(content, worksheet.requests, font)
        }
    }

    private fun writeSecondPage(target: PDDocument, page: PDPage, font: PDFont, worksheet: Worksheet) {
        PDPageContentStream(target, page, PDPageContentStream.AppendMode.APPEND, false).use { content ->
            writeSecondPageRequests(content, worksheet.requests, font)
            writeTail(content, worksheet, font)
        }
    }


    private fun writeHeading(content: PDPageContentStream, worksheet: Worksheet, font: PDFont) {
        content.writeTextAt(174.0f, 435.0f, worksheet.mainEmployee.getNameWithGroup(), font)
        content.writeTextAt(164.0f, 409.0f, worksheet.membersEmployee.joinToString { it.name }, font)
        content.writeMultiline(
            baseX = 278.0f,
            baseY = 383.0f,
            newLineX = 60.0f,
            newLineY = 370.0f,
            text = worksheet.workTypes.joinToString() + " согласно бланка распоряжения номер № ",
            font = font,
            lineWidth = 84
        )

        content.writeTextAt(392.0f, 316.0f, worksheet.day, font)
        content.writeTextAt(455.0f, 316.0f, worksheet.month, font)
        content.writeTextAt(488.0f, 316.0f, worksheet.year, font)
        content.writeTextAt(166.0f, 302.0f, worksheet.fullDate, font)
        content.writeTextAt(466.0f, 302.0f, worksheet.chiefEmployee.getNameWithGroup(), font)
        content.writeTextAt(320.0f, 276.0f, worksheet.chiefEmployee.getNameWithGroup(), font)
        content.writeTextAt(675.0f, 276.0f, worksheet.mainEmployee.getNameWithGroup(), font)

    }

    private fun writeTail(content: PDPageContentStream, worksheet: Worksheet, font: PDFont) {
        content.writeTextAt(140.0f, 88.0f, worksheet.chiefEmployee.getNameWithPosition(), font)
        content.writeTextAt(392.0f, 88.0f, worksheet.day, font)
        content.writeTextAt(465.0f, 88.0f, worksheet.month, font)
        content.writeTextAt(508.0f, 88.0f, worksheet.year, font)
    }

    private fun writeFirstPageRequests(content: PDPageContentStream, requests: List<RequestItem>, font: PDFont) =
        writeRequests(content, 159.0f, requests.take(4), 1, 30.2f, font)

    private fun writeSecondPageRequests(content: PDPageContentStream, requests: List<RequestItem>, font: PDFont) =
        writeRequests(content, 537.0f, requests.drop(4).take(14), 5, 29.55f, font)

    private fun writeRequests(
        content: PDPageContentStream,
        baseY: Float,
        requests: List<RequestItem>,
        startPosition: Int,
        lineSpacing: Float,
        font: PDFont
    ) {
        requests.forEachIndexed { i, request ->
            writeSingleRequest(
                content = content,
                baseX = 60f,
                baseY = baseY - i * lineSpacing,
                font = font,
                position = i + 1,
                address = request.address
            )
        }
    }

    private fun writeSingleRequest(
        content: PDPageContentStream,
        baseX: Float,
        baseY: Float,
        font: PDFont,
        position: Int,
        address: String
    ) {
        content.writeTextAt(baseX, baseY, "$position", font, 8.0f)
        content.writeMultiline(baseX + 21f, baseY, baseX + 21f, baseY - 14f, 32, address, font, 7.0f, 0.0f)
        val techActions =
            """
                1) Отключить нагрузку; 2) Проверить фазировку;
                3) Отключить электроустановку; 4) Проверить 
                отсутствие напряжения; 5) Применить 
                основные и дополнительные средства защиты
            """.trimIndent()
        content.writeMultiline(
            baseX = baseX + 140f,
            baseY = baseY + 5f,
            newLineX = baseX + 140f,
            newLineY = baseY - 2f,
            lineWidth = 300,
            text = techActions,
            font = font,
            fontSize = 6.0f,
            lineSpacing = 7.0f
        );
    }

    private fun writeLists(target: PDDocument, worksheets: Array<Worksheet>, font: PDFont) {
        val listTemplate = PDDocument.load(loader.getResourceAsStream("templates/list.pdf"))

        for (worksheet in worksheets) {
            val page = target.importPage(listTemplate.getPage(0))
            PDPageContentStream(target, page, PDPageContentStream.AppendMode.APPEND, false).use { content ->
                writeListHeading(content, worksheet, font)
                writeListContent(content, worksheet, font)
            }
        }
    }

    private fun writeListHeading(content: PDPageContentStream, worksheet: Worksheet, font: PDFont) {
        content.apply {
            writeTextAt(
                30.0f,
                795.0f,
                "Приложение к распоряжению № ____________ от ${worksheet.fullDate}",
                font,
                12.0f
            )
            writeTextAt(
                34.0f,
                775.0f,
                "Призводитель работ: ${worksheet.mainEmployee.name}",
                font,
                10.0f
            );

            val members =
                if (worksheet.membersEmployee.isEmpty()) "--" else worksheet.membersEmployee
                    .joinToString { it.name }

            writeTextAt(
                34.0f,
                760.0f,
                if (worksheet.membersEmployee.size > 1) "Члены бригады: $members" else "Член бригады: $members",
                font,
                10.0f
            )
        }
    }

    private fun writeListContent(content: PDPageContentStream, worksheet: Worksheet, font: PDFont) {
        worksheet.requests.take(20).forEachIndexed { index, request ->
            writeSingleListLine(
                request = request,
                yOffset = index * 33.2f,
                position = index + 1,
                font = font,
                content = content
            )
        }
    }

    private fun writeSingleListLine(
        request: RequestItem,
        yOffset: Float,
        position: Int,
        font: PDFont,
        content: PDPageContentStream
    ) = content.apply {
        writeTextAt(if (position < 10) 58.0f else 55.0f, 723.0f - yOffset, position.toString(), font, 10.0f)
        writeTextAt(76.0f, 730.0f - yOffset, request.accountId.toString().padStart(6, '0'), font, 10.0f)
        writeTextAt(120.0f, 730.0f - yOffset, request.name.take(31), font, 9.0f)
        writeTextAt(280.0f, 730.0f - yOffset, request.address, font, 9.0f)
        writeTextAt(480.0f, 731.0f - yOffset, request.reqType, font, 10.0f)
        writeTextAt(76.0f, 714.0f - yOffset, request.counterInfo.take(36), font, 10.0f)
        writeTextAt(280.0f, 714.0f - yOffset, request.additionalInfo.take(56), font, 9.0f)
    }

    private fun PDPageContentStream.writeMultiline(
        baseX: Float,
        baseY: Float,
        newLineX: Float,
        newLineY: Float,
        lineWidth: Int,
        text: String,
        font: PDFont,
        fontSize: Float = 12f,
        lineSpacing: Float = 14f
    ) {
        WordUtils.wrap(text, lineWidth)
            .splitToSequence("\n")
            .forEachIndexed { i, txt ->
                if (i == 0)
                    writeTextAt(baseX, baseY, txt, font, fontSize)
                else
                    writeTextAt(newLineX, newLineY - (i - 1) * lineSpacing, txt, font, fontSize)
            }
    }

    private fun PDPageContentStream.writeTextAt(
        x: Float,
        y: Float,
        text: String,
        font: PDFont,
        fontSize: Float = 12.0f
    ) {
        beginText()
        setNonStrokingColor(Color.BLACK)
        setFont(font, fontSize)
        newLineAtOffset(x, y)
        showText(text)
        endText()
    }

    private fun loadWorksheets(): Array<Worksheet> {
        val reader = Files.newBufferedReader(Paths.get(sourcePath))
        return Gson().fromJson(reader, Array<Worksheet>::class.java)
    }

}