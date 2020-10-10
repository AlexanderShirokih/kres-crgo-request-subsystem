package ru.aleshi.requests

import com.google.gson.GsonBuilder
import org.apache.commons.lang3.exception.ExceptionUtils
import ru.aleshi.requests.core.PdfExporter
import ru.aleshi.requests.core.RequestParser
import ru.aleshi.requests.data.ProcessResult
import java.lang.IllegalArgumentException
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
                    "-pdf" -> PdfExporter(sourcePath = args[1]).export(args[2])
                    "-parse" -> RequestParser.parse(filePath = Paths.get(args[1]))
                    "-list-printers" -> getAvailablePrinters()
                    "-print" -> printDocument(
                        sourcePath = args[1],
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

    private fun getAvailablePrinters(): List<String> {
        val attrSet = HashPrintRequestAttributeSet().apply {
            add(Sides.TWO_SIDED_SHORT_EDGE)
        }

        return PrintServiceLookup
            .lookupPrintServices(null, attrSet)
            .map { it.name }
    }

    private fun printDocument(sourcePath: String, printerName: String, noLists: Boolean): Boolean {
        val printer = PrintServiceLookup
            .lookupPrintServices(null, null)
            .first { it.name == printerName }

        PdfExporter(sourcePath = sourcePath).print(printer, noLists)
        return true
    }
}
