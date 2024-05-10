package com.example.bloc
import androidx.annotation.NonNull

import android.content.ContentResolver
import android.content.Context
import android.provider.ContactsContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ContactFetcher(private val context: Context) {
    fun fetchContacts(result: MethodChannel.Result) {
        val contactsList = mutableListOf<Map<String, String>>()
        val contentResolver: ContentResolver = context.contentResolver
        val cursor = contentResolver.query(
            ContactsContract.Contacts.CONTENT_URI,
            null,
            null,
            null,
            null
        )

        cursor?.use { cursor ->
            if (cursor.moveToFirst()) {
                do {
                    val contactId =
                        cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID))
                    val contactName =
                        cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME))
                    val contactPhoneNumber = fetchContactPhoneNumber(contactId)
                    val contactMap = mapOf(
                        "name" to contactName,
                        "phoneNumber" to contactPhoneNumber
                    )
                    contactsList.add(contactMap)
                } while (cursor.moveToNext())
            }
        }

        result.success(contactsList)
    }

    private fun fetchContactPhoneNumber(contactId: String): String {
        var phoneNumber = ""
        val contentResolver: ContentResolver = context.contentResolver
        val cursor = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            null,
            ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
            arrayOf(contactId),
            null
        )

        cursor?.use { cursor ->
            if (cursor.moveToFirst()) {
                phoneNumber = cursor.getString(
                    cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                )
            }
        }

        return phoneNumber
    }
}

class MyPlugin : FlutterPlugin {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "contact_service")
        channel.setMethodCallHandler { call, result ->
            if (call.method == "fetchContacts") {
                ContactFetcher(flutterPluginBinding.applicationContext).fetchContacts(result)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up resources if needed
    }
}
