package com.ivehement.saf.api.utils

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

internal class SafUtil(private val context: Context) {
    private fun getRootPath(): String {
        val externalFilesDir: String = context.getExternalFilesDir(null)!!.path
        var rootPath = externalFilesDir.split("Android")[0]
        return rootPath
    }

    private fun fileExists(filePath: String): Boolean {
        val file: File = File(filePath)
        return file.exists()
    }

    private fun getPathFromExtSD(pathData: List<String>,): String {
        val type: String = pathData[0]
        val relativePath: String = "/" + pathData[1]
        var fullPath: String

        // on my Nokia devices (4.4.4 & 5.1.1), `type` is a dynamic string
        // something like "71F8-2C0A", some kind of unique id per storage
        // don't know any API that can get the root path of that storage based on its id.
        //
        // so no "primary" type, but let the check here for other devices
        if ("primary".equals(type, ignoreCase = true)) {
            fullPath = getRootPath() + relativePath
            if (fileExists(fullPath)) {
                return fullPath
            }
        }

        // Environment.isExternalStorageRemovable() is `true` for external and internal storage
        // so we cannot relay on it.
        //
        // instead, for each possible path, check if file exists
        // we'll start with secondary storage as this could be our (physically) removable sd card
        fullPath = System.getenv("SECONDARY_STORAGE")!! + relativePath
        if (fileExists(fullPath)) {
            return fullPath
        }

        fullPath = System.getenv("EXTERNAL_STORAGE")!! + relativePath
        if (fileExists(fullPath)) {
            return fullPath
        }

        return fullPath
    }

    public fun getExternalFilesDirPath(): String {
        val externalFilesDirPath: String = context.getExternalFilesDir(null)!!.path
        return externalFilesDirPath
    }

    public fun clearCachedFiles(dirName: String): Boolean {
        try {
            var dir: File = File(context.getExternalFilesDir(null).toString() + "/" + dirName)
            dir.deleteRecursively()
            return true
        }
        catch(e: Exception) {
            return false;
        }
    }

    public fun syncCopyFileToExternalStorage(sourceUri: Uri, cacheDirectoryName: String, fileName: String): String? {
        var output: File
        if (!cacheDirectoryName.equals("")) {
            var dir: File = File(context.getExternalFilesDir(null).toString() + "/" + cacheDirectoryName)
            if (!dir.exists()) {
                dir.mkdir()
            }
            output = File(context.getExternalFilesDir(null).toString() + "/" + cacheDirectoryName + "/" + fileName)
        } else {
            return null
        }
        // If already exist return
        if (output.exists()) {
            Log.i("SYNC:", "Already exists: " + fileName)
            return output.path
        }
        try {
            var inputStream: InputStream = context.contentResolver.openInputStream(sourceUri)!!
            var outputStream: FileOutputStream = FileOutputStream(output)
            var read: Int
            var bufferSize: Int = 1024
            val buffers = ByteArray(bufferSize)
            read = inputStream.read(buffers)
            while (read != -1) {
                outputStream.write(buffers, 0, read)
                read = inputStream.read(buffers)
            }
            inputStream.close()
            outputStream.close()
        } catch (e: Exception) {
            Log.e("SYNC_COPY_EXCEPTION", e.message!!)
            return null
        }
        return output.getPath()
    }

    public fun isWhatsAppFile(uri: Uri): Boolean {
        return "com.whatsapp.provider.media".equals(uri.getAuthority())
    }

    private fun isExternalStorageDocument(uri: Uri): Boolean {
        return "com.android.externalstorage.documents".equals(uri.getAuthority())
    }

    public fun getPath(uri: Uri): String {
        try {
            // check here to KITKAT or new version
            val isKitKat: Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT

            if (isKitKat) {
                if (isExternalStorageDocument(uri)) {
                    val docId: String = DocumentsContract.getDocumentId(uri)
                    val split: List<String> = docId.split(":")
                    //val type: String = split[0]
                    var fullPath: String = getPathFromExtSD(split)
                    if (fullPath != "") {
                        return fullPath
                    } else {
                        return ""
                    }
                }

                if ("content".equals(uri.getScheme(), ignoreCase = true)) {
                    var projection: String = MediaStore.Images.Media._ID
                    var cursor: Cursor
                    try {
                        cursor =
                                context.contentResolver.query(
                                        uri,
                                        arrayOf(projection),
                                        null,
                                        null,
                                        null
                                )!!
                        var column_index: Int =
                                cursor.getColumnIndex(MediaStore.Images.Media._ID)
                        if (cursor.moveToFirst()) {
                            return cursor.getString(column_index)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("qGET_PATH_EXCEPTION", e.message.toString())
        }
        return ""
    }
}
