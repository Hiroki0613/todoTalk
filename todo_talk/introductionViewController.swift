//
//  introductionViewController.swift
//  todo_talk
//
//  Created by 宏輝 on 30/06/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit

class introductionViewController: UIViewController,UIScrollViewDelegate {
    
    
    @IBOutlet weak var goToMainView: UIButton!
    @IBOutlet weak var introductionScrollView: UIScrollView!
    @IBOutlet weak var introductionPageControl: UIPageControl!
    
    //文面は中央に設置する。
   var introductionTitleArray =  ["チュートリアルを表示します。\n画面を左へスワイプしてください","このアプリは音声入力で\nタスクを追加できます","マイクをタップすることで、\n音声入力できます","再びタップすることで\nタスクへ追加します","入力したタスクは直接タップ\nすることで編集ができます","もちろん、手入力も可能です。\nただし、使い勝手が少し悪いです(汗)","先に文字を入力してから\n右下のプラスボタンを押してください","タスクの消去は右上のEditを押して","赤文字のDeleteを押したら削除出来ます","これで説明を終わります。"]
    
    //実際の操作画面をスクリーンショットで撮影し、introduction画像として使用する
    var introductionImageArray = ["introduction0","introduction1","introduction2","introduction3","introduction4","introduction5","introduction6","introduction7","introduction7","introduction7"]

    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        introductionScrollView.delegate = self
        //「さあ、使ってみよう」ボタンを隠す
        goToMainView.isHidden = true
        
        introductionScrollView.isPagingEnabled = true
        
        setUpScroll()
        
        for i in 0...9 {
            
            let introductionImageView = UIImageView()
            introductionImageView.frame = CGRect(x: CGFloat(i) * self.view.frame.size.width, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/4*3)
            introductionImageView.image = UIImage(named: "\(introductionImageArray[i]).jpg")
            introductionImageView.contentMode = .scaleAspectFit
            introductionImageView.layer.zPosition = -1
            introductionScrollView.addSubview(introductionImageView)
        }
    }
    
    
    func setUpScroll() {
        
        //スクロールビューを貼り付ける
        
        introductionScrollView.contentSize = CGSize(width: self.view.frame.size.width * 10, height: self.view.frame.size.height)
        
        
        for i in 0...9 {
            
            let introductionLabel = UILabel(frame: CGRect(x: CGFloat(i) * view.frame.size.width, y: view.frame.size.height/3, width: introductionScrollView.frame.size.width, height: introductionScrollView.frame.size.height))
            
            introductionLabel.numberOfLines = 2
            introductionLabel.font = UIFont.init(name: "HiraMaruProN-W4", size: 16)
            introductionLabel.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            introductionLabel.textAlignment = .center
            introductionLabel.text = introductionTitleArray[i]
            introductionScrollView.addSubview(introductionLabel)

            //ページの最後(8ページ目)のみ「さあ、使ってみよう！」ボタンを表示
//            if i == 7 {
//                goToMainView.isHidden = false
//            } else {
//                //念の為、1から7ページ目はボタンを隠すようにする
//                goToMainView.isHidden = true
//            }
        }
    }
    
    func scrollViewDidScroll(_ introductionScrollView: UIScrollView) {
        
        introductionPageControl.currentPage = Int(introductionScrollView.contentOffset.x / introductionScrollView.frame.size.width)
        
        if introductionPageControl.currentPage == 9 {
            goToMainView.isHidden = false
        }
    }
    
    
    
    @IBAction func introductionSkipButton(_ sender: Any) {
        
        performSegue(withIdentifier: "introductionEnd", sender: nil)
    }
    

    @IBAction func goToMainViewButton(_ sender: Any) {
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
