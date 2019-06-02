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


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,SFSpeechRecognizerDelegate {
    
    //録音の開始、停止ボタン
    @IBOutlet weak var recordButton: UIButton!
    
    //キーボードのサイズ分、画面が上にスライドさせる
    //スクリーンサイズを取得
    let SCREEN_SIZE = UIScreen.main.bounds.size
    
    
    
    //TODOを入力するテキストフィールド
    @IBOutlet weak var inputTodoTextFields: UITextField!
    
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
    //タスク達成時のLottieアニメーション
    var deletedAnimationView = LOTAnimationView()
    //音声入力中のアニメーション
    var animationAtInputByVoice = LOTAnimationView()
    //音声入力画面、JsonのレーダーをMicボタン中心から発生させます
    let circleGrowLottieAnimationView = LOTAnimationView()
    
    
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
    

    
//    //音声関連
    // MARK: Properties
    //localeのidentifierに言語を指定、。日本語はja-JP,英語はen-US
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    //文字音声認識された
    var voiceStr : String! = ""
    
    
//** 削除予定
    //音声入力結果をUILabelで表示
    var inputVoiceLabel = UILabel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//待ち受け画面
        waitingView()
        
//波紋を設定
        circleGrowLottieAnimation()
        
//キーボード入力時に画面を上側にスライドさせる実装コード
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        

// 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
////**削除予定　削除した時にLottieアニメーションが表示される
//        deletedAnimationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        self.view.addSubview(deletedAnimationView)
//        deletedAnimationView.isHidden = true
        
        
        //todoTableViewのデリゲートメソッド宣言
        todoTableView.delegate = self
        todoTableView.dataSource = self
        inputTodoTextFields.delegate = self
        if UserDefaults.standard.object(forKey: "todo") != nil{
            //アプリ再開時にtodoリスト一覧が見られるようにする
            todoArray = UserDefaults.standard.object(forKey: "todo") as! [String]
        }
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "TODO by 音声"
        navigationItem.rightBarButtonItem = editButtonItem
         // MARK: 音声メモのコードを載せます
        
        allowOnsei()
    
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
            circleGrowLottieAnimation()
            recordButton.isHidden = true
            micAnimation.isHidden = true
            todoBlurVibrancyEffect.isHidden = false
            circleGrowLottieAnimationView.isHidden = true
            goToEditView.isHidden = true
        }
        
    
        
    //音声入力画面、JsonのレーダーをMicボタン中心から発生させます。
        //追加ボタンを隠します
        //「シングルタップでタスク追加、ダブルタップで入力終了」と画面背景に表示。
        //画面背景にブラーをかけて、音声入力モードということをはっきりと示します。
//Vibrancyの実装が出来ていない・・・
//コードで実装した場合、ストーリーボードのような階層を作る方法がわからない・・・
        func inputTalkMode(){
            circleGrowLottieAnimation()
            addTodoView.isHidden = true
            todoBlurVibrancyEffect.isHidden = false
            circleGrowLottieAnimationView.isHidden = false
            inputTodoTextFields.isHidden = true
            goToEditView.isHidden = true
            
            
            

            
            let voiceTalkSupport = UILabel()
            voiceTalkSupport.layer.zPosition = 1
            voiceTalkSupport.text = "シングルタップでタスク追加\n\nダブルタップで音声入力終了"
            voiceTalkSupport.font = UIFont.systemFont(ofSize: 28)
            voiceTalkSupport.textColor = .white
            voiceTalkSupport.textAlignment = .center
            voiceTalkSupport.numberOfLines = 0
            voiceTalkSupport.frame = todoBlurVibrancyEffect.contentView.bounds
            todoBlurVibrancyEffect.contentView.addSubview(voiceTalkSupport)
            
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
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn
            , animations: {
                self.inputTextMode()
        }, completion: nil)
        //キーボードを閉じる処理
        view.endEditing(true)
        if !inputTodoTextFields.resignFirstResponder(){
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.view.transform = CGAffineTransform.identity
                self.waitingView()
            }, completion: nil)
        }
    }
    
    
    
    
    
    
    
    //音声入力の許可をユーザーに求める
    func allowOnsei(){
        
        //デリゲートの設定
        speechRecognizer.delegate = self
        
        //ユーザーに音声認識の許可を求める
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    //ユーザが音声認識の許可を出した時
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    //ユーザが音声認識を拒否した時
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    //端末が音声認識に対応していない場合
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    //ユーザが音声認識をまだ認証していない時
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    
    //渡された文字列が入ったアラートを表示する
    
    func showStrAlert(str: String) {
        
        // UIAlertControllerを作成する.
        let myAlert: UIAlertController = UIAlertController(title: "音声認識結果", message: "", preferredStyle: .alert)
        
        
        // OKのアクションを作成する.
        let myOkAction = UIAlertAction(title: "OK", style: .default) { action in
            print("Action OK!!")
        
                self.todoArray.append(self.voiceStr)
                UserDefaults.standard.set(self.todoArray, forKey: "todo")
                self.todoTableView.reloadData()
                self.voiceStr = ""
            }

        // OKのアクションを作成する.
        myAlert.addAction(myOkAction)
        
        // UIAlertを発動する.
        present(myAlert, animated: true, completion:  nil)

        }
        
    
  
    
    //リターンが押された時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる
        inputTodoTextFields.resignFirstResponder()
        return true
    }
    
    //テキストの直前入力をシェイクでキャンセルさせる
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake
        {
            //ここに直前に入力した文字のキャンセルメソッドを記入する（メソッドが不明・・・）
        }
    }

    
    
    
    
    //tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //todoTableViewの数だけセルを用意する
        return todoArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todoTableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
     
        //チェックマックが押される前は、空白のマルを入れる
        let checkedBeforeImage = cell.viewWithTag(1) as! UIButton
        
        //セレクターを使って、UIButtonをプッシュした時に、Lottieアニメーションを出すように設定したが、実現できず・・・。
        checkedBeforeImage.addTarget(self, action: "toCheckedDoneLottieAction", for: .touchUpInside)
        
     
        let label = cell.viewWithTag(3) as! UILabel
        if UserDefaults.standard.object(forKey: "todo") != nil{
            todoArray = UserDefaults.standard.object(forKey: "todo") as! [String]
        }
        label.text = todoArray[indexPath.row]
        return cell
    }
    
    @objc func toCheckedDoneLottieAction(_ sender:UIButton){
        //チェックマークを押すと、Lottieがアニメーションする
//        let checkedDone = cell.viewWithTag(2) as! LOTAnimationView
//        startCheckOKAnimation()
//        checkedDone.isHidden = false
//        checkedDone.setAnimation(named: "433-checked-done")
//        checkedDone.layer.zPosition = 1
//        checkedDone.loopAnimation = false

        //参考URL
        //https://qiita.com/nmisawa/items/6ffbe6b3c7f2c474c74f
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
        
//        performSegue(withIdentifier: "toEditTaskView", sender: nil)
//
//        if inputTodoTextFields.resignFirstResponder() {
//            inputTodoTextFields.resignFirstResponder()
//
//        }else{
//            inputTodoTextFields.becomeFirstResponder()
//        }
        
    }
    
//
//    //didselect時に値を渡しながら画面遷移をする
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "toEditTaskView"{
//            let toEditTaskViewVC :toEditTaskViewViewController = segue.destination as! toEditTaskViewViewController
//
//            //indexNumber = Int()とすることで
//            toEditTaskViewVC.edittaskView = todoArray[indexNumber]
//        }
//    }

    
//  //「追加」　メモなので基本的に短い単語が多いが、長い文章になったときに
//  //     可能ならばセルの高さを、該当部分だけ広くしてほしい。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //todoに項目を追加、キー値をtodoにする
    //このボタンをプッシュした時に、キーボードが出てくるようにする。
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
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
    }
    
    
//アニメーション
    //lottieにて、micAnimationを動かす
    func startMicAnimation(){
        micAnimation.setAnimation(named: "todoMic")
        micAnimation.layer.zPosition = 2
        micAnimation.loopAnimation = true
        micAnimation.play()
    }
    
    //lottieにて、circleGrowAnimationを動かす
    func circleGrowLottieAnimation(){
        circleGrowLottieAnimationView.frame = CGRect(x: 0, y: view.frame.size.height/2.85, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(circleGrowLottieAnimationView)
        circleGrowLottieAnimationView.setAnimation(named: "734-circle-grow")
        circleGrowLottieAnimationView.loopAnimation = true
        circleGrowLottieAnimationView.layer.zPosition = 0
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
    
    //lottieにて、talkInputButtonの中心点から発生しているようにする。
//問題あり！。音声入力NG時or編集時に右上のDoneを押すとボタンが消えてしまう。
    func waitingView(){
        circleGrowLottieAnimation()
        circleGrowLottieAnimationView.isHidden = true
        startMicAnimation()
        addTodoView.isHidden = false
        inputTodoTextFields.isHidden = false
        goToEditView.isHidden = false
        todoBlurVibrancyEffect.isHidden = true
    }
    
    
    
    
//    //「追加」　音声入力ボタンが押されたら、音声入力画面に移動する
        //背景に「〇〇というと、次のタスクに移ります。」と薄い文字で入れる。
        //音声入力結果はリアルに表示されており、タスクが確定した時にテーブルにタスクが映る

    
    
    
    
    
    //録音ボタンが押されたら音声認識をスタートする
    @IBAction func micRecordButton(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.inputTalkMode()
        }, completion: nil)
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
            //録音が停止した！
            print("録音停止")
            
            
            if voiceStr.isEmpty != true {
                //入力された文字列の入った文字列を表示
                //入力された文字がリアルタイムで表示されない・・・
                //希望はテーブルビューに直接文字を書き込みたい
                inputVoiceLabel.frame = CGRect(x: 0, y: view.frame.size.width / 3, width: view.frame.size.width, height: view.frame.size.height)
                inputVoiceLabel.textAlignment = NSTextAlignment.center
                inputVoiceLabel.font = UIFont.systemFont(ofSize: 30)
                inputVoiceLabel.text = voiceStr
                view.addSubview(inputVoiceLabel)
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.waitingView()
                }, completion: nil)
            
                showStrAlert(str: self.voiceStr)
            }else {
                //空の場合
//                showStrAlert(str: self.voiceStr)
                showVoiceInputAlert()
            }

        } else {
            try! startRecording()
            recordButton.setTitle("Stop recording", for: [])
            
        }
        
        print("voiceStr")
        
    }
    
    
    
    
    
    
    
    
    

    func showVoiceInputAlert(){
        let alertViewControler = UIAlertController(title: "何も音声が入力されていません。", message: "もう一度、発声してください", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        
    }


    //録音を開始する
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
//        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }

        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                
                //音声認識の区切りの良いところで実行される。
                self.voiceStr = result.bestTranscription.formattedString
                print(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    // MARK: SFSpeechRecognizerDelegate
    //speechRecognizerが使用可能かどうかでボタンのisEnabledを変更する
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
            
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    //ボタンを押した時に、編集画面へ遷移する。
    //ボタンの位置は暫定
    @IBAction func goToEditViewButton(_ sender: Any) {
        performSegue(withIdentifier: "toEditView", sender: nil)
    }
    
    
    
//    //「追加」　背景を黒い画面に変更できるオプションを追加
    

    
    
    /* 参考URL
    音声認識(SFSpeechRecognizer)
    https://swiswiswift.com/sfspeechrecognizer/
 
    */
    
}

