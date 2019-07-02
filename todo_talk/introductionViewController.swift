//
//  introductionViewController.swift
//  todo_talk
//
//  Created by 宏輝 on 30/06/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit

class introductionViewController: UIViewController {
    
    
    @IBOutlet weak var goToMainView: UIButton!
    
    
    @IBOutlet weak var introductionScrollView: UIScrollView!

    //文面は中央に設置する。
   var introductionTitleArray =  ["アプリをインストールしていただき。\nありがとうございます。\nこれからどのように使用するのかの\nチュートリアルを表示します。\n画面をスワイプしてください","このアプリの特徴は音声入力で\nTODOタスクを追加できることです","マイクボタンをタップすることで、\n音声が入力できます","再びタップすることで\nTODOへ追加することができます","音声入力を間違えても大丈夫です。\n直接タスクをタップすることで編集ができます","もちろん、手入力も可能です。\nただし、使い勝手が少し悪いです(汗)","先に文字を入力してから\n右下のプラスボタンを押してください","これで説明を終わります。"]
    
    //実際の操作画面をスクリーンショットで撮影し、introduction画像として使用する
    var introductionImageArray = ["introduction0","introduction1","introduction2","introduction3","introduction4","introduction5","introduction6","introduction7"]

    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //「さあ、使ってみよう」ボタンを隠す
        goToMainView.isHidden = true

        introductionScrollView.isPagingEnabled = true
        
        setUpScroll()
        
        for i in 0...7 {
            
            let introductionView = UIImageView()
            introductionView.frame = CGRect(x: CGFloat(i) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            introductionView.contentMode = .scaleAspectFit
            introductionScrollView.addSubview(introductionView)
        }
    }
    
    
    func setUpScroll() {
        
        //スクロールビューを貼り付ける
        
        introductionScrollView.contentSize = CGSize(width: view.frame.size.width * 8, height: view.frame.size.height)
        
        
        for i in 0...7 {
            
            let introductionLabel = UILabel(frame: CGRect(x: CGFloat(i) * view.frame.size.width, y: view.frame.size.height/3, width: introductionScrollView.frame.size.width, height: introductionScrollView.frame.size.height))
            
            introductionLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
            introductionLabel.font = UIFont.init(name: "HiraMaruProN-W4", size: 20)
            introductionLabel.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            introductionLabel.textAlignment = .center
            introductionLabel.text = introductionTitleArray[i]
            introductionScrollView.addSubview(introductionLabel)

            //ページの最後(8ページ目)のみ「さあ、使ってみよう！」ボタンを表示
            if i == 7 {
                goToMainView.isHidden = false
            } else {
                //念の為、1から7ページ目はボタンを隠すようにする
                goToMainView.isHidden = true
            }
        }
    }
    
    
    @IBAction func introductionSkipButton(_ sender: Any) {
        
        performSegue(withIdentifier: "introductionEnd", sender: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
