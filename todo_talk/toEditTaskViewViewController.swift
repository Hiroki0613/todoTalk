//
//  toEditTaskViewViewController.swift
//  todo_talk
//
//  Created by 宏輝 on 14/04/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit

class toEditTaskViewViewController: UIViewController {
    
    
    @IBOutlet weak var editTaskView: UITextView!
    
    var edittaskView: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editTaskView.text = edittaskView
        
    }


    @IBAction func taskEditCompleteButton(_ sender: Any) {
        
    //タスク編集前に表示、Userdefaultsから文字を取り出す。
    //      ↓
    //      ↓
    //      ↓
        //Userdefaltsで取り出すことを考えたが、難しそうなので
        //「値を渡しながら画面遷移をするに変更」

            //if UserDefaults.standard.object(forKey: "todo") != nil {
            //editTaskView.text = UserDefaults.standard.object(forKey: "todo") as! String
        
            
            
//        //編集画面が表示されたらすぐにキーボード入力が出来るようにする。
//            touchesBegan(<#T##touches: Set<UITouch>##Set<UITouch>#>, with: <#T##UIEvent?#>)
        
        //タスクの修正後、textview(editTaskView)に文章を表示
            editTaskView.text = edittaskView
            
        //Userdefaultsに文字を埋める。
        //todoArrayに再び埋めようとしたら、出来なかった・・・
//            UserDefaults.standard.set(todoArray, forKey: "todo")
        
        //自動的に、前の画面に遷移する。
        dismiss(animated: true, completion: nil)
                      
    }
    
    //
        
        
}
    
    
    


