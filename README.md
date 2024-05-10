# Fetch Contact with Native Code in Flutter.

# Android:

1) Add permisson handling dependency for permisson of contact

2) Add these permission in you AndroidManifest.xml file:

    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />

3) Now we have to write some Native code in Kotlin and then make a channel for communicate it with Flutter Code. So we'll have to do following Steps:

  Here's an example of the directory structure where you might place the Kotlin file:

  flutter_project/
  android/
    app/
      src/
        main/
          kotlin/
            com/
              example/
                flutterproject/
                  ContactFetcher.kt

    When you create ContactFetcher.kt class then write this Kotlin code to Fetch Contact :

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

then in your MainActivity.kt file which is just below contactFetcher.kt file and this file will be there from flutter you don't need to create. paste the following code in that class

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


your done with android portion . now all the UI portion and logic i have written in Flutter check out that and once you hot restart the add it will ask for permission and then it'll fetch all your phone numbers without dependency.

For IOS Portion it denaying permisson i'll work on IOS Later.

If you love it then. Please give the repo a star and follow for future update
