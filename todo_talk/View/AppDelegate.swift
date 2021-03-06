//
//  AppDelegate.swift
//  todo_talk
//
//  Created by 宏輝 on 27/03/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        
        // 端末の大きさに合わせて、画面のサイズを変えていく
        let storyboardMultidevice: UIStoryboard = self.grabStoryboard()
        
        if let window = window {
            window.rootViewController = storyboardMultidevice.instantiateInitialViewController() as UIViewController?
        }
        
        self.window?.makeKeyAndVisible()
        
        
        
        
        //使用するStoryBoardのインスタンス化
        //マルチデバイス対応により、こちらのコードを有効にすると、Mainが呼び出されてしまう
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        // UserDefaultsにbool型のKey"launchedBefore"を用意
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if(launchedBefore == true) {
            //動作確認のために1回実行ごとに値をfalseに設定し直す
//            UserDefaults.standard.set(false, forKey: "launchedBefore")
        } else {
            //起動を判定するlaunchedBeforeという論理型のKeyをUserDefaultsに用意
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            //チュートリアル用のViewControllerのインスタンスを用意してwindowに渡す
            //ストーリーボードをマルチデバイスに対応させるため、同じstoryboardMultideviceで定義
            let introductionVC = storyboardMultidevice.instantiateViewController(withIdentifier: "introductionViewController") as! introductionViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = introductionVC
        }
        
        return true
    }
    
    /*
     参考サイト
     iOSアプリ開発メモ No.21 -初回起動時のみ開くView Controller-
     http://sona.hateblo.jp/entry/2018/03/01/210105
     */
    

    // マルチデバイス対応のメソッド
    func grabStoryboard() -> UIStoryboard {
        var storyboard = UIStoryboard()
        let height = UIScreen.main.bounds.size.height
        // iPhone6,6S,7,8
        if height == 667 {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        // iPhone3G,3GS,4,4S
        } else if height == 480 {
            storyboard = UIStoryboard(name: "iPhone4S", bundle: nil)
        // iPhone5,5C,5S,SE
        } else if height == 568 {
            storyboard = UIStoryboard(name: "iPhoneSE", bundle: nil)
        // iPhone6Plus,6SPlus,7Plus,8Plus
        } else if height == 736 {
            storyboard = UIStoryboard(name: "iPhone8Plus", bundle: nil)
        // iPhoneX,XS
        } else if height == 812 {
            storyboard = UIStoryboard(name: "iPhoneXS", bundle: nil)
        // iPhoneXR,XSMAX
        } else if height == 896 {
            storyboard = UIStoryboard(name: "iPhoneXSMAX", bundle: nil)
        }
        print(storyboard)
        return storyboard
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

