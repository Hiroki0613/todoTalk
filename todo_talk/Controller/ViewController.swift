//
//  ViewController.swift
//  todo_talk
//
//  Created by 宏輝 on 27/03/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit
import Lottie
import Speech


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate,EditTodoDelegate {
    
    //InputVoiceSystemを実態化
    var inputVoiceSystem = InputVoiceSystem()
    
    
    //    var todoTableViewCellTextField = UITextField()
    var checkflag = false
    var checkIndex = Int()
    
    //録音の開始、停止ボタン
    @IBOutlet weak var recordButton: UIButton!
    
    //キーボードのサイズ分、画面が上にスライドさせる
    //スクリーンサイズを取得
    let SCREEN_SIZE = UIScreen.main.bounds.size
    
    //todoTableViewCellの継承のため初期化
    //    var todoTableViewCell = TodoTableViewCell(coder: NSCoder)
    var listItems = [ListItem]()
    
    //TODOをキーボードより入力するテキストフィールド
    @IBOutlet weak var inputTodoTextFields: UITextField!
    var todoTableViewCellTextField = UITextField()
    @IBOutlet var inputTodoTextViewPopOverView: UIView!
    @IBOutlet weak var inputTodoPopOverDone: UIButton!
    @IBOutlet weak var inputTodoPopOverTextView: UITextView!
    let inputTodoPopOverBlurView = UIVisualEffectView()
    
    
    
    
    
    
    
    
    //tableView、背景は透明にする。
    @IBOutlet weak var todoTableView: UITableView!
    
    //＋ボタンを表示しているView(音声入力時にViewを隠すためだけに使用)
    @IBOutlet weak var addTodoView: UIButton!
    
    //ボタンを押した時に、編集画面へ遷移する(音声入力時,文字入力時にViewを隠すためだけに使用)
    @IBOutlet weak var goToEditView: UIButton!
    
    @IBOutlet weak var backGroundImageView: UIImageView!
    
    //マイク入力ボタンのアニメーション
    //録音の開始、停止ボタン
    @IBOutlet weak var micAnimation: LOTAnimationView!
    //マイクのタップ数を検知する
    @IBOutlet var singleTapGesture: UITapGestureRecognizer!
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!
    //最初のシングルタップのときだけ、else(入力無し処理)をパスする
    var beforeFirstSingleTap = false
    //2回目のシングルタップ以降は、レコードストップ、レコードスタートの順で実行させる
    var afterFirstSingleTap = false
    
    
    
    //タスク達成時のLottieアニメーション
    var deletedAnimationView = LOTAnimationView()
    //音声入力中のアニメーション
    var animationAtInputByVoice = LOTAnimationView()
    //音声入力画面、JsonのレーダーをMicボタン中心から発生させます
    //    var circleGrowLottieAnimationView2 = LOTAnimationView()
    //
    @IBOutlet weak var circleGrowLottieAnimationView: LOTAnimationView!
    
    //波紋アニメーションテスト
    var growAnimation = LOTAnimationView()
    
    //音声入力、文字入力時のブラーエフェクト
    //Blur & Vibrancyを使用。
    @IBOutlet weak var todoBlurVibrancyEffect: UIVisualEffectView!
    
    
    var todoArray = [String]()
    var imageArray = [String]()
    
    //didselectを行った際に、indexPathを取得して、
    //値を渡すときに配列の番号に指定してあげる
    var indexNumber = Int()
    //Screenの高さ
    var screenHeight:CGFloat!
    //Screenの幅
    var screenWidth:CGFloat!
    
    
    

    
    
    
    //** 削除予定
    //音声入力結果をUILabelで表示
    var inputVoiceLabel = UILabel()
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        todoTableViewCellTextField.delegate = self
        //波紋を設定
        circleGrowLottieAnimation()
        
        //マイクのアニメーション
        startMicAnimation()
        
        
        //20190708追加
        //tableView内にあるセルを直接編集させる
        todoTableViewCellTextField.addTarget(self, action: "textFieldDidChange", for: .editingChanged)
        
        
        //キーボード入力時に画面を上側にスライドさせる実装コード
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        
        //todoTableViewのデリゲートメソッド宣言
        todoTableView.delegate = self
        todoTableView.dataSource = self
        inputTodoTextFields.delegate = self
        
        
        inputTodoTextFields.attributedPlaceholder = NSAttributedString(string: "文字入力 → ＋ボタンでタスク追加",attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)])
        
        //        inputTodoTextFields.alpha = 0.7
        inputTodoTextFields.tintColor.withAlphaComponent(0.7)
        
        if UserDefaults.standard.object(forKey: "todo") != nil{
            //アプリ再開時にtodoリスト一覧が見られるようにする
            todoArray = UserDefaults.standard.object(forKey: "todo") as! [String]
        }
        
        inputTodoTextFields.isHidden = true
        
        
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "TODOリスト"
        navigationItem.rightBarButtonItem = editButtonItem
        
        // MARK: 音声メモのコードを載せます
        inputVoiceSystem.allowOnsei()
        
        //録音ボタンのZ軸の変更
        recordButton.layer.zPosition = 2
        
        
        //tableviewの線の色を設定
        todoTableView.separatorColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        
        
        //参考URL https://www.youtube.com/watch?v=k6KBEspZxm8
        //        let inputTodoPopOverBlurView = UIVisualEffectView()
        inputTodoPopOverBlurView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        inputTodoPopOverBlurView.layer.zPosition = 5
        view.addSubview(inputTodoPopOverBlurView)
        inputTodoPopOverBlurView.isHidden = true
        
        
        
        inputTodoPopOverTextView.text = "タップし文字を入力。「入力完了」を押すとタスクに追加されます"
        inputTodoPopOverTextView.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.4)
        inputTodoPopOverTextView.font = UIFont.init(name: "HiraMaruProN-W4", size: 18)
        inputTodoPopOverTextView.returnKeyType = .done
        inputTodoPopOverTextView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        //シンプルモードのSwitch判定
        mainSimpleModeChangeSwitch()
        
        //待ち受け画面
        inputVoiceSystem.waitingView()
        
        if UserDefaults.standard.object(forKey: "photo") != nil {
            let selectedImage = UserDefaults.standard.object(forKey: "photo")
            //Data型→Image型に変換
            backGroundImageView.image = UIImage(data: selectedImage as! Data)
        } else {
            //画像が選択されていない場合は、何もしない
        }
    }
    
    
    
    //文字入力画面
    //キーボードが上にスライドして、Mic入力ボタン,追加ボタンを覆います
    //画面背景にブラーをかけて、文字入力モードということをはっきりと示します。
    func inputTextMode(){
        //            circleGrowLottieAnimation()
        //            recordButton.isHidden = true
        //            micAnimation.isHidden = true
        todoBlurVibrancyEffect.isHidden = false
        circleGrowLottieAnimationView.isHidden = true
        goToEditView.isHidden = true
    }
    
    
   
    
    
    

    

    @objc func textFieldDidChange(textField: UITextField) {
        todoTableViewCellTextField.text = textField.text
    }
    
    
    //キーボード入力時に画面を上側にスライドさせる実装コードの続き
    @objc func keyboardWillShow(_ notification:NSNotification){
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.height
        inputTodoTextFields.frame.origin.y = SCREEN_SIZE.height - keyboardHeight - inputTodoTextFields.frame.height
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification){
        inputTodoTextFields.frame.origin.y = SCREEN_SIZE.height - inputTodoTextFields.frame.height
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if inputVoiceSystem.micButtonTouchesOrNot != true{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn
                , animations: {
                    //2019.06.06 近藤疑問　なんでここにinputTextMode()が入っているのか
                    //                self.inputTalkMode()
            }, completion: nil)
            //キーボードを閉じる処理
            view.endEditing(true)
            if !inputTodoTextFields.resignFirstResponder(){
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.view.transform = CGAffineTransform.identity
                    self.inputVoiceSystem.waitingView()
                }, completion: nil)
                
                inputVoiceSystem.micButtonTouchesOrNot = false
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
   
    
    
    
    
    
    
    //リターンが押された時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる
        
        //        //20190707藤井さん追加_田町にて
        //        if checkflag == true{
        //            todoArray.append(todoTableViewCellTextField.text!)
        //            print(todoArray.debugDescription)
        //        }else if checkflag == false{
        ////            todoArray.append(inputTodoTextFields.text!)
        //        }
        if UserDefaults.standard.object(forKey: "todo") != nil{
            todoArray = UserDefaults.standard.object(forKey: "todo") as! [String]
        }
        
        UserDefaults.standard.set(todoArray, forKey: "todo")
        todoTableView.reloadData()
        ////        voiceTalkText.resignFirstResponder()
        //        inputTodoTextFields.resignFirstResponder()
        //
        
        
        
        textField.resignFirstResponder()
        return true
    }
    
    //テキストの直前入力をシェイクでキャンセルさせる
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake
        {
            //ここに直前に入力した文字のキャンセルメソッドを記入する（メソッドが不明・・・）
        }
    }
    
    
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //todoTableViewの数だけセルを用意する
        return todoArray.count
    }
    
    
    //EditTodoDelegateのデリゲートメソッド
    func textFieldDidEndEditing(cell: TodoTableViewCell, value: String) {
        //変更されたセルのインデックスを取得する。
        let index = todoTableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to:todoTableView))
        
        //データを変更する。
        todoArray[index!.row] = value
        print(todoArray)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todoTableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        //        if UserDefaults.standard.object(forKey: "todo") != nil{
        //            todoArray = UserDefaults.standard.object(forKey: "todo") as! [String]
        //        }
        
        //        UserDefaults.standard.set(todoArray, forKey: "todo")
        todoTableViewCellTextField = cell.contentView.viewWithTag(1) as! UITextField
        //        todoTableViewCellTextField.delegate = self
        //        let item = listItems[indexPath.row]
        
        var listItems:ListItem? {
            didSet {
                todoTableViewCellTextField.text = listItems?.text
            }
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        
        
        todoTableViewCellTextField.font = UIFont.init(name: "HiraMaruProN-W4", size: 20)
        todoTableViewCellTextField.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        
        print(todoArray.debugDescription)
        
        todoTableViewCellTextField.text = todoArray[indexPath.row]
        //20190703近藤追加　キーボードを閉じる処理を追加
        //        todoTableViewCellTextField.resignFirstResponder()
        todoTableViewCellTextField.delegate = self
        
        //20190630近藤追加　チェックマークが押される前は、空白のマルを入れる
        if let btnChk = cell.contentView.viewWithTag(2) as? UIButton {
            btnChk.addTarget(self, action: #selector(checkboxClicked(_ :)), for: .touchUpInside)
        }
        return cell
    }
    
    @objc func checkboxClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
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
            //            startCheckOKAnimation()
        }
    }
    
    
    //画面遷移関係はすべて削除予定
    //セルをタップした際に、文章編集画面へと画面遷移
    //画面遷移はされましたが、どのボタンを押しても一番上のセルが選ばれてしまう・・・
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkflag = true
        checkIndex = indexPath.row
    }
    
    
    //  //「追加」　メモなので基本的に短い単語が多いが、長い文章になったときに
    //  //     可能ならばセルの高さを、該当部分だけ広くしてほしい。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //todoに項目を追加、キー値をtodoにする
    //このボタンをプッシュした時に、キーボードが出てくるようにする。
    
    //MARK:- PopUp UITextViewDelegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "タップし文字を入力。「入力完了」を押すとタスクに追加されます" {
            textView.text = ""
            textView.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            textView.font = UIFont.init(name: "HiraMaruProN-W4", size: 16)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "タップし文字を入力。「入力完了」を押すとタスクに追加されます"
            textView.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.4)
            textView.font = UIFont.init(name: "HiraMaruProN-W4", size: 17)
            
        }
    }
    
    
    func realTimeInputTalkIntoTextField() {
        //音声入力時にリアルタイムで文字が入力されているのを確認するため実装
        inputVoiceSystem.voiceTalkText.text = ""
        
        inputVoiceSystem.voiceTalkText.frame = CGRect(x: 20, y: view.frame.size.width/5*4, width: view.frame.size.width - 20, height: view.frame.size.height/4)
        inputVoiceSystem.voiceTalkText.layer.zPosition = 4
        inputVoiceSystem.voiceTalkText.font = UIFont.init(name: "HiraMaruProN-W4", size: 20)
        //   systemFont(ofSize: 28)
        inputVoiceSystem.voiceTalkText.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        inputVoiceSystem.voiceTalkText.backgroundColor = .clear
        inputVoiceSystem.voiceTalkText.textAlignment = .center
        inputVoiceSystem.voiceTalkText.delegate = self
        inputVoiceSystem.voiceTalkText.textAlignment = .left
        //            voiceTalkText.frame = todoBlurVibrancyEffect.contentView.bounds
        inputVoiceSystem.viewController.todoBlurVibrancyEffect.contentView.addSubview(inputVoiceSystem.voiceTalkText)
        
        inputVoiceSystem.voiceTalkText.text = inputVoiceSystem.voiceStr
    }
    
    
    
    @IBAction func addTodo(_ sender: Any) {
        
        inputTodoTextViewPopOverView.center = self.view.center
        inputTodoPopOverDone.tintColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        inputTodoTextViewPopOverView.layer.zPosition = 4
        inputTodoPopOverTextView.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        inputTodoPopOverTextView.font = UIFont.init(name: "HiraMaruProN-W4", size: 16)
        inputTodoPopOverTextView.delegate = self
        inputTodoPopOverTextView.textAlignment = .left
        self.view.addSubview(self.inputTodoTextViewPopOverView)
        inputTodoTextViewPopOverView.isHidden = true
    
        
        UIView.animate(withDuration: 0.1) {
            self.inputTodoPopOverBlurView.isHidden = false
            self.inputTodoTextViewPopOverView.isHidden = false
        }
    }
    
    //TextViewの実装が完了したときに、UserDefaultsへ文字を入力してからdissmissするコード
    @IBAction func inputTodoPopOverDoneButton(_ sender: Any) {
        
        inputTodoPopOverDone.layer.zPosition = 4
        //ここは後ほどTextViewに変更する
        if inputTodoPopOverTextView.text?.isEmpty != true{
            self.todoArray.append(inputTodoPopOverTextView.text!)
            UserDefaults.standard.set(self.todoArray,forKey: "todo")
            self.todoTableView.reloadData()
            inputTodoPopOverTextView.text = ""
            //           todoTableViewCellTextField.becomeFirstResponder()
            
        }else{
            showTextInputAlert()
        }
        UIView.animate(withDuration: 0.1) {
            self.inputTodoPopOverBlurView.isHidden = true
            self.inputTodoTextViewPopOverView.removeFromSuperview()
            
        }
        
    }
    
    
    
    func showTextInputAlert(){
        let alertViewControler = UIAlertController(title: "何も入力されていません。", message: "入力してください。", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
    }
    
    
    //アニメーション
    //lottieにて、micAnimationを動かす
    func startMicAnimation(){
        micAnimation.setAnimation(named: "todoMic")
        micAnimation.layer.zPosition = 3
        micAnimation.loopAnimation = true
        micAnimation.play()
    }
    
    //lottieにて、circleGrowAnimationを動かす
    func circleGrowLottieAnimation(){
        //        circleGrowLottieAnimationView.frame = CGRect(x: 0, y: view.frame.size.height/2.85, width: view.frame.size.width, height: view.frame.size.height)
        //        view.addSubview(circleGrowLottieAnimationView)
        circleGrowLottieAnimationView.setAnimation(named: "734-circle-grow")
        circleGrowLottieAnimationView.loopAnimation = true
        circleGrowLottieAnimationView.layer.zPosition = 0
        circleGrowLottieAnimationView.contentMode = .scaleAspectFit
        //play()が抜けていた・・・
        circleGrowLottieAnimationView.play()
    }
    
    
    
    //lottieにて、タスク完了時にアニメーションを表示する
    func startCheckOKAnimation(){
        deletedAnimationView.isHidden = false
        deletedAnimationView.setAnimation(named: "433-checked-done")
        deletedAnimationView.layer.zPosition = 1
        deletedAnimationView.loopAnimation = false
        //        deletedAnimationView.play { (finished) in
        //        self.deletedAnimationView.isHidden = true
        //        }
    }
    
    
    
    
    
    //    //「追加」　音声入力ボタンが押されたら、音声入力画面に移動する
    //背景に「〇〇というと、次のタスクに移ります。」と薄い文字で入れる。
    //音声入力結果はリアルに表示されており、タスクが確定した時にテーブルにタスクが映る
    
    //録音ボタンが押されたら音声認識をスタートする
    @IBAction func micRecordButton(_ sender: Any) {
        inputVoiceSystem.micRecordButtonConfigure()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //シンプルモードに切り替わったときに使われる文字色、背景色
    func mainSimpleModeChangeSwitch(){
        
        if let bool = UserDefaults.standard.object(forKey: "simpleModeSwitchKey") as? Bool{
            
            if bool == true {
                
                //バックグラウンドの画像とボカシを消す
                backGroundImageView.isHidden = true
                todoBlurVibrancyEffect.isHidden = true
                
                //背景色を＃#0c0b10
                self.view.backgroundColor = UIColor(red: 12/255, green: 11/255, blue: 16/255, alpha: 1)
                
                //ボタンの透明度を0.2にする
                recordButton.alpha = 0.2
                
                
            } else {
                
                //バックグラウンドの画像とボカシを表示する
                backGroundImageView.isHidden = false
                todoBlurVibrancyEffect.isHidden = false
                
                
                
                //背景色を透明にする
                self.view.backgroundColor = .clear
                
                //ボタンの透明度を0.7にする
                recordButton.alpha = 0.7
                
                
            }
        }
    }
    
    
    
    
    
    //ボタンを押した時に、編集画面へ遷移する。
    //ボタンの位置は暫定
    @IBAction func goToEditViewButton(_ sender: Any) {
        performSegue(withIdentifier: "toEditView", sender: nil)
    }
    
    
    
    /* 参考URL
     音声認識(SFSpeechRecognizer)
     https://swiswiswift.com/sfspeechrecognizer/
     
     */
    
}

