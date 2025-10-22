import SwiftUI
import FirebaseCore
import FirebaseAuth

// Create a minimal AppDelegate class to handle Firebase init warning
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase Configured in AppDelegate!")
        if Auth.auth().currentUser == nil {
                   Auth.auth().signInAnonymously { authResult, error in
                       if let error = error {
                           print("Error signing in anonymously: \(error.localizedDescription)")
                       } else {
                           print("Successfully signed in anonymously!")
                       }
                   }
               } else {
                   print("User is already signed in.")
               }
        
        return true
    }
}

@main
struct _11_ProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
