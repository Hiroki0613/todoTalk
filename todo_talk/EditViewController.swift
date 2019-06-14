//
//  EditViewController.swift
//  todo_talk
//
//  Created by 宏輝 on 25/05/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit
import Photos

class EditViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    @IBOutlet weak var editBackGroundImageView: UIImageView!
    
    
    @IBOutlet weak var simpleModeSwitch: UISwitch!
    
    
    //シンプルモードに切り替え時にフォント色を変更するためにoutletで結びつけた
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var simpleModeLabel: UILabel!
    @IBOutlet weak var details1Label: UILabel!
    @IBOutlet weak var backgroundImageLabel: UILabel!
    @IBOutlet weak var details2Label: UILabel!
    @IBOutlet weak var backgroundBlurView: UIVisualEffectView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //シンプルモードのスイッチをデフォルトではOFFにしておく
        simpleModeSwitch.isOn = false
        
        // Do any additional setup after loading the view.
        //フォトライブラリの使用許可

        PHPhotoLibrary.requestAuthorization { (status) in
            switch(status) {
            case .authorized: break
            case .denied: break
            case .notDetermined: break
            case .restricted: break
            //defaultが必要無し？
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "photo") != nil {
            let selectedImage = UserDefaults.standard.object(forKey: "photo")
            //Data型→Image型に変換
            editBackGroundImageView.image = UIImage(data: selectedImage as! Data)
        } else {
            //画像が選択されていない場合は、何もしない
        }
        
        
        //シンプルモードのSwitch判定
        if let bool = UserDefaults.standard.object(forKey: "simpleModeSwitchKey") as? Bool{
            
            simpleModeSwitch.isOn = bool
            
            simpleModeChangeSwitch()
        }
        
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //選択画面では、正方形に切り取られている・・・。
        //ここを長方形にしたい
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        //フォトライブラリー選択画像を"photo" ユーザーデフォルトに保存
            let defaults = UserDefaults.standard
            //画像をデータ型に変換(compressionQuality: 圧縮度合い)
            let selectedImageData = selectedImage.jpegData(compressionQuality: 0.5)
            defaults.set(selectedImageData, forKey: "photo")
            defaults.synchronize()
            
            //selectedImageViewに表示
            //背景を黒にして、正方形の画像が選ばれた場合に黒の背景を出すようにする
            //selectedImageViewはiPhoneの機種ごとにタテヨコ比が違うので、それぞれで設定する必要がある・・・。
//            selectedImageView.layer.borderColor = UIColor.black.cgColor
//            selectedImageView.layer.borderWidth = 10
            selectedImageView.backgroundColor = .black
            selectedImageView.image = selectedImage

            picker.delegate = self
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //フォトライブラリーから選択ボタンの動作
    
    @IBAction func libraryBackBroundButton(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = false
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    
    //スイッチ操作により、背景を真っ黒のシンプル色にする
    //背景は黒#0c0b10,文字色は#d3d3d3とする
    //この設定をテーブルビューなどに持っていきたい
    @IBAction func toSimpleModeChangeSwitch(_ sender: Any) {
        
        simpleModeChangeSwitch()
    }
    
    
 //   simpleModeへの変更時に使う背景色
    //参考URL https://teratail.com/questions/121498
    func simpleModeChangeSwitch(){
        
        if simpleModeSwitch.isOn == true {
            
            let defaults = UserDefaults.standard
            defaults.set(simpleModeSwitch.isOn, forKey: "simpleModeSwitchKey")
            
            //バックグラウンドの画像とボカシを消す
            backgroundBlurView.isHidden = true
            editBackGroundImageView.isHidden = true
            
            //背景色を＃#0c0b10
            self.view.backgroundColor = UIColor(red: 12/255, green: 11/255, blue: 16/255, alpha: 1)
            
            //文字色を#d3d3d3
            editLabel.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            simpleModeLabel.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            details1Label.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            backgroundImageLabel.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            //photoLivraryButtonのテキストカラーも変更したい
            photoLibraryButton.isEnabled = false
            details2Label.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            //理想はナビゲーションバーの色も変更したい
            
        } else {
            
            let defaults = UserDefaults.standard
            defaults.set(simpleModeSwitch.isOn, forKey: "simpleModeSwitchKey")
            
            //バックグラウンドの画像とボカシを表示する
            backgroundBlurView.isHidden = false
            editBackGroundImageView.isHidden = false
            
            editLabel.textColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 0.7)
            simpleModeLabel.textColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 0.7)
            details1Label.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            backgroundImageLabel.textColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 0.7)
            
            photoLibraryButton.isEnabled = true
            details2Label.textColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            
        }
        
        
    }
    
    
    
//    let defaults = UserDefaults.standard
//    let selectedImage = UIImage(named: "catphoto")
//    // 画像をデータ型に変換
//    let selectedImageData = selectedImage!.jpegData(compressionQuality: 0.5)
//    defaults.set(selectedImageData, forKey: "photo")
//    defaults.synchronize()
//    // selectedImageViewに表示
//    selectedImageView.image = selectedImage
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
