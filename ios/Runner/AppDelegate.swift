import UIKit
import Flutter
import Contacts

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "contact_service", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "fetchContacts") {
                self.fetchContacts(result: result)
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func fetchContacts(result: @escaping FlutterResult) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                // Permission granted, fetch contacts
                var contacts: [[String: String]] = []
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                do {
                    try store.enumerateContacts(with: request) { (contact, stop) in
                        var contactInfo: [String: String] = [:]
                        contactInfo["name"] = "\(contact.givenName) \(contact.familyName)"
                        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                            contactInfo["phoneNumber"] = phoneNumber
                        }
                        contacts.append(contactInfo)
                    }
                    result(contacts)
                } catch {
                    result(FlutterError(code: "Error", message: "Failed to fetch contacts", details: nil))
                }
            } else {
                // Permission denied
                result(FlutterError(code: "Permission Denied", message: "User denied permission to access contacts", details: nil))
            }
        }
    }
}
