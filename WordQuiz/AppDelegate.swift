//
//  AppDelegate.swift
//  WordQuiz
//
//  Created by Takeru Ono on 09.06.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        // スプラッシュ画面を表示
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        
        // 一定時間後にFirstViewControllerに切り替え
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstViewController")
            self.window?.rootViewController = firstVC
        }

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
