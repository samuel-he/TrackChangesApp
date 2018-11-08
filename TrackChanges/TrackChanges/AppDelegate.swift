import UIKit

@UIApplicationMain
class AppDelegate: UIResponder,
UIApplicationDelegate, SPTAppRemoteDelegate {
    
    fileprivate let redirectUri = URL(string: "trackchanges://spotify-login-callback/")!
    fileprivate let clientIdentifier = "4bebf0c82b774aaa99764eb7c5c58cc4"
    fileprivate let name = "Now Playing View"
    
    // keys
    static fileprivate let kAccessTokenKey = "access-token-key"
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: AppDelegate.kAccessTokenKey)
            defaults.synchronize()
        }
    }
    
    
    var playerViewController: ConnectViewController {
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
//            playerViewController.showError(error_description);
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
//        playerViewController.appRemoteDisconnect()
        appRemote.disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.connect();
    }
    
    func connect() {
//        playerViewController.appRemoteConnecting()
        appRemote.connect()
    }
    
    // MARK: AppRemoteDelegate
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
//        playerViewController.appRemoteConnected()
        playerViewController.performSegue(withIdentifier: "GoToFeed", sender: ConnectViewController())
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnectionAttemptWithError")
//        playerViewController.appRemoteDisconnect()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("didDisconnectWithError")
//        playerViewController.appRemoteDisconnect()
    }
    
}
