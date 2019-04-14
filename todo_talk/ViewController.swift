//
//  ViewController.swift
//  todo_talk
//
//  Created by 宏輝 on 27/03/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit
import Lottie


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
   
    
    @IBOutlet weak var inputTodoTextFields: UITextField!
    
    @IBOutlet weak var todoTableView: UITableView!
    
    
    @IBOutlet weak var micAnimation: LOTAnimationView!
    
    var deletedAnimationView = LOTAnimationView()
    
    var todoArray = [String]()
    var imageArray = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        deletedAnimationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(deletedAnimationView)
        deletedAnimationView.isHidden = true
        
        //todoTableViewのデリゲートメソッド宣言
        todoTableView.delegate = self
        todoTableView.dataSource = self
        inputTodoTextFields.delegate = self
        
        if UserDefaults.standard.object(forKey: "todo") != nil{
            //アプリ再開時にtodoリスト一覧が見られるようにする
            todoArray = UserDefaults.standard.object(forKey: "todo") as! [String]
        }
        
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "アプリ名"
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //todoTableViewの数だけセルを用意する
        return todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = todoTableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)

        let label = cell.viewWithTag(1) as! UILabel
        
        if UserDefaults.standard.object(forKey: "todo") != nil{
            todoArray = UserDefaults.standard.object(forKey: "todo") as! [String]
        }
        
        label.text = todoArray[indexPath.row]
        
        return cell
        
    }
    
    //スワイプして消去する機能を消す
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        
        if todoTableView.isEditing{
            
            return .delete
            
        }
        
        return .none
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        todoTableView.isEditing = editing
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete{
        
            todoArray.remove(at: indexPath.row)
        
            UserDefaults.standard.set(self.todoArray,forKey: "todo")
        
            todoTableView.deleteRows(at: [indexPath], with: .automatic)
            
            //ここにアニメーション
            startCheckOKAnimation()
            
        }
        
    }
    
    
    
    //平成31年4月7日に追加
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if inputTodoTextFields.resignFirstResponder() {
            inputTodoTextFields.resignFirstResponder()
            
        }else{
            inputTodoTextFields.becomeFirstResponder()
        }
        
    }

    
    
    @IBAction func deleteTodo(_ sender: Any) {
   
        
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if inputTodoTextFields.resignFirstResponder() {
            inputTodoTextFields.resignFirstResponder()
            
        }else{
            inputTodoTextFields.becomeFirstResponder()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    //todoに項目を追加、キー値をtodoにする
    @IBAction func addTodo(_ sender: Any) {
        
        if inputTodoTextFields.text?.isEmpty != true{
        
        self.todoArray.append(inputTodoTextFields.text!)
        UserDefaults.standard.set(self.todoArray,forKey: "todo")
        self.todoTableView.reloadData()
        inputTodoTextFields.text = ""
            
        }else{
            
            showAlert()
            
            
        }

    }
    
    func showAlert(){
        let alertViewControler = UIAlertController(title: "何も入力されていません。", message: "入力してください。", preferredStyle: .alert)
        
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)

    }
    
    
    
    //lottieにて、micAnimationを動かす
    func startMicAnimation(){
        
        micAnimation.setAnimation(named: "3787-jumping-mic")
        micAnimation.layer.zPosition = 1
        micAnimation.loopAnimation = true
        micAnimation.play()
    
    }
    
    func startCheckOKAnimation(){
       
        deletedAnimationView.isHidden = false
        deletedAnimationView.setAnimation(named: "433-checked-done")
        deletedAnimationView.layer.zPosition = 1
        deletedAnimationView.loopAnimation = false
        deletedAnimationView.play { (finished) in
        
        self.deletedAnimationView.isHidden = true
            
        }
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
//
//        textField.resignFirstResponder()
//    }
    

    
    
//    //チェックボックスを押した時にチェックマークが表れる
//    func startCheckOkAnimation(){
//        checkLottieAnimation.setAnimation(named: "433-checked-done")
//        checkLottieAnimation.play()
//    }
    
    //再びチェックボックスを押した時にチェックマークが消える
    //↑コード確認中
    

    

}

