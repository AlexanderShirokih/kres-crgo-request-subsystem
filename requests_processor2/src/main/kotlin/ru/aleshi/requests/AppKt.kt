package ru.aleshi.requests

import com.google.gson.GsonBuilder
import org.apache.commons.lang3.exception.ExceptionUtils
import ru.aleshi.requests.core.PdfExporter
import ru.aleshi.requests.core.RequestParser
import ru.aleshi.requests.data.ProcessResult
import java.lang.IllegalArgumentException
import java.nio.file.Paths

object AppKt {
    @JvmStatic
    fun main(args: Array<String>) {
        loadResult {
            if (args.isNotEmpty()) {
                when (args[0]) {
                    "-pdf" -> PdfExporter(sourcePath = args[1], destinationPath = args[2]).export()
                    "-parse" -> RequestParser.parse(Paths.get(args[1]))
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
}
