import UIKit
import Firebase

var AccessToken = String()

@UIApplicationMain
class AppDelegate: UIResponder,
UIApplicationDelegate, SPTAppRemoteDelegate {
    
    let redirectUri = URL(string: "trackchanges://spotify-login-callback/")!
    let clientIdentifier = "4bebf0c82b774aaa99764eb7c5c58cc4"
    
    // keys
    static let kAccessTokenKey = "access-token-key"
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: AppDelegate.kAccessTokenKey)
            defaults.synchronize()
        }
    }
    
    var connectViewController: ConnectViewController {
        get {
            return self.window?.rootViewController as! ConnectViewController
        }
    }
    
    var window: UIWindow?
    
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    class var sharedInstance: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
            AccessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(error_description)
        }
        return true
    }
    
//    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//
//        return true
//    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        appRemote.disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appRemote.connect()
    }
    
    // MARK: AppRemoteDelegate
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        connectViewController.performSegue(withIdentifier: "GoToFeed", sender: nil)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnectionAttemptWithError")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("didDisconnectWithError")
    }
    
}
