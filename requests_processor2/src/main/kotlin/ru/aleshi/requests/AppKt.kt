package ru.aleshi.requests

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import org.apache.commons.lang3.exception.ExceptionUtils
import ru.aleshi.requests.core.PdfExporter
import ru.aleshi.requests.core.RequestParser
import ru.aleshi.requests.core.XlsxExporter
import ru.aleshi.requests.data.Document
import ru.aleshi.requests.data.ProcessResult
import java.nio.file.Files
import java.nio.file.Paths
import javax.print.PrintServiceLookup
import javax.print.attribute.HashPrintRequestAttributeSet
import javax.print.attribute.standard.Sides

object AppKt {
    @JvmStatic
    fun main(args: Array<String>) {
        loadResult {
            if (args.isNotEmpty()) {
                when (args[0]) {
                    "-export-pdf" -> PdfExporter(loadDocument(args[1])).export(args[2])
                    "-export-xlsx" -> XlsxExporter(loadDocument(args[1])).export(args[2])
                    "-parse" -> RequestParser().parse(filePath = Paths.get(args[1]))
                    "-list-printers" -> getAvailablePrinters()
                    "-print" -> printDocument(
                        document = loadDocument(args[1]),
                        printerName = args[2],
                        noLists = args.size > 3 && args[3] == "-no-lists"
                    )
                    else -> throw IllegalArgumentException("Unknown parameter: ${args[0]}")
                }
            } else {
                throw IllegalArgumentException("No args was received!")
            }
        }
    }

    private fun <T> loadResult(dataConsumer: () -> T) {
        val result = try {
            ProcessResult(data = dataConsumer())
        } catch (e: Exception) {
            ProcessResult<RequestParser>(
                data = null,
                error = e.toString(),
                stackTrace = ExceptionUtils.getStackTrace(e)
            )
        }

        println(GsonBuilder().setPrettyPrinting().create().toJson(result))
    }

    private fun loadDocument(sourcePath: String): Document {
        val reader = Files.newBufferedReader(Paths.get(sourcePath))
        val document = Gson().fromJson(reader, Document::class.java)
        if (document.version < 2) {
            throw RuntimeException("Document version at least '2' required!")
        }
        return document
    }

    private fun getAvailablePrinters(): List<String> {
        val attrSet = HashPrintRequestAttributeSet().apply {
            add(Sides.TWO_SIDED_SHORT_EDGE)
        }

        return PrintServiceLookup
            .lookupPrintServices(null, attrSet)
            .map { it.name }
    }

    private fun printDocument(document: Document, printerName: String, noLists: Boolean): Boolean {
        val printer = PrintServiceLookup
            .lookupPrintServices(null, null)
            .first { it.name == printerName }

        PdfExporter(document).print(printer, noLists)
        return true
    }
}
