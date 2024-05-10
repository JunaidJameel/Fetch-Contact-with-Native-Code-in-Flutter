package com.example.bloc

import android.content.ContentResolver
import android.content.Context
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "contact_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "fetchContacts") {
                fetchContacts(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun fetchContacts(result: MethodChannel.Result) {
        val contactsList = mutableListOf<Map<String, String>>()
        val contentResolver: ContentResolver = applicationContext.contentResolver
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
        val contentResolver: ContentResolver = applicationContext.contentResolver
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
