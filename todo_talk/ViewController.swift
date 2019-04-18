//
//  ViewController.swift
//  todo_talk
//
//  Created by 宏輝 on 27/03/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit
import Lottie


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var inputTodoTextFields: UITextField!
    
    @IBOutlet weak var todoTableView: UITableView!
    
    
    @IBOutlet weak var micAnimation: LOTAnimationView!
    
    var deletedAnimationView = LOTAnimationView()
    
    var todoArray = [String]()
    var imageArray = [String]()
    
    //didselectを行った際に、indexPathを取得して、
    //値を渡すときに配列の番号に指定してあげる
    var indexNumber = Int()

    //Screenの高さ
    var screenHeight:CGFloat!
    
    //Screenの幅
    var screenWidth:CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        
        //表示窓のサイズと位置を設定
        scrollView.frame.size = CGSize(width: screenWidth, height: screenHeight)
        
        
        
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
        
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight*2)
        
        scrollView.addSubview(inputTodoTextFields)
        
        //UIScrollViewの大きさを画像サイズに設定
        
        //スクロールの跳ね返り無し
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        
        //ビューに追加
        self.view.addSubview(scrollView)
        
    }
    
    ///////////////////////ここから
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //キーボードイベントの監視開始
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //キーボードイベントの監視解除
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                restoreScrollViewSize()
                
                let convertedKeyboardFrame = scrollView.convert(keyboardFrame, from: nil)
                
                //現在選択中のTextFieldの下部Y座標とキーボードの高さから、スクロール量を決定
                let offsetY: CGFloat = self.inputTodoTextFields!.frame.maxY - convertedKeyboardFrame.minY
                if offsetY < 0 { return }
                updateScrollViewSize(moveSize: offsetY, duration: animationDuration)
            }
        }
    }
    
    //moveSize分Y方向にスクロールさせる
    func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: moveSize, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.contentOffset = CGPoint(x: 0, y: moveSize)
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
        //キーボードが閉じられた時に、スクロールした分を戻す
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    // キーボードが閉じられた時に呼ばれる
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentOffset.y = 0
    }
    
    // TextFieldが選択された時
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //選択されているTextFieldを更新
        inputTodoTextFields = textField
    }
    
    ////////////////ここまで
    
    
    //リターンが押された時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる
        inputTodoTextFields.resignFirstResponder()
        return true
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
    
    
    
//セルをタップした際に、文章編集画面へと画面遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        performSegue(withIdentifier: "toEditTaskView", sender: nil)
        
        
        if inputTodoTextFields.resignFirstResponder() {
            inputTodoTextFields.resignFirstResponder()
            
        }else{
            inputTodoTextFields.becomeFirstResponder()
        }
        
    }
    
    //didselect時に値を渡しながら画面遷移をする
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEditTaskView"{
            let toEditTaskViewVC :toEditTaskViewViewController = segue.destination as! toEditTaskViewViewController
            
            //indexNumber = Int()とすることで
            toEditTaskViewVC.edittaskView = todoArray[indexNumber]
            
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
    

    
    
    
    
//使いやすさを考えて、text入力ボタンを下に移しました。
//inputTodoTextFields(プラスボタン)を押した時に、
//上にスクロールしてキーボドが実装できる機能を搭載したい。
        /*UIViewwを作成し、
        ・inputTodoTextFields
        ・addTodo
        を入れて、
        そこのUIView(heightConstraints)をAutoLayOutで高さ設定し、
        IBOutletで繋ぎ、
     
        下記のコードを書いたら出来そうです。
     
     
        //キーボードが開く時に動くfunc
        heightConstraint.constant = キーボードの高さ
        view.layoutIfNeeded()
     
        //キーボードが閉じる時に動くfunc
        heightConstraint.constant = 元のViewの高さ
        view.layoutIfNeeded()
     
     
 
        */
    
    

}

