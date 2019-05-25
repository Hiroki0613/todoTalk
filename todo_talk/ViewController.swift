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
    

    
    //キーボードを押した時に、上にスライドさせる
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inputTodoTextFields: UITextField!
    
    //tableView、背景は透明にする。
    @IBOutlet weak var todoTableView: UITableView!
    
    
    
    
    //マイク入力ボタンのアニメーション
    //録音の開始、停止ボタン
    @IBOutlet weak var micAnimation: LOTAnimationView!
    //タスク達成時のLottieアニメーション
    var deletedAnimationView = LOTAnimationView()
    //音声入力中のアニメーション
    var animationAtInputByVoice = LOTAnimationView()
    
    
    
    
    
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
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
//    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: Properties
    //localeのidentifierに言語を指定、。日本語はja-JP,英語はen-US
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    //文字音声認識された
    var voiceStr : String! = ""
    
    
    //近藤追加20190430  音声入力結果をUILabelで表示
    var inputVoiceLabel = UILabel()
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        //表示窓のサイズと位置を設定
        scrollView.frame.size = CGSize(width: screenWidth, height: screenHeight)
          //「追記」　削除した時にLottieアニメーションが表示される
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
        // MARK: 音声メモのコードを載せます
        
        allowOnsei()
    
    
        
        
        
        
        
/////////////////////////////////////////////
    //2019.05.25近藤追加
    //ここからが実装の画面になります。
    
        
    //待ち受け画面
        //Micボタンを設置,中央に設置したい
        let talkInputButton = UIButton()
        talkInputButton.frame = CGRect(x: view.frame.width/2, y: view.frame.height/8*7-20, width: view.frame.width/8*3, height: view.frame.height/10)
        talkInputButton.setImage(UIImage(named: "todoTalk_TalkInputButton"), for: .normal)
        talkInputButton.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(talkInputButton)
        
        //MicがジャンプするアニメーションをtalkInputButtonに重ねる
        let micLottieAnimationView = LOTAnimationView()
        let micLottieAnimation = Animation.named("todoMic2")
        micLottieAnimationView.frame = CGRect(x: view.frame.width/2, y: view.frame.height/8*7-20, width: view.frame.width/8*3, height: view.frame.height/10)
        view.addSubview(micLottieAnimationView)
        
        //音声入力モードのときの734-circle-growの波が、talkInputButtonの中心点から発生しているようにする。そして、一旦非表示にする。
        let circleGrowLottieAnimationView = LOTAnimationView()
        let circleGrowLottieAnimation = Animation.named("734-circle-grow")
        circleGrowLottieAnimationView.frame = CGRect(x: view.frame.width/2, y: view.frame.height/8*7-20, width: view.frame.width/8*3, height: view.frame.height/10)
        view.addSubview(circleGrowLottieAnimationView)
        circleGrowLottieAnimationView.isHidden = true
        
        
        
        // ブラーエフェクトを追加し、ブラーを非表示にする
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        visualEffectView.isHidden = true
    

        
        
    //文字入力画面
        //キーボードが上にスライドして、Mic入力ボタン,追加ボタンを覆います
        //画面背景にブラーをかけて、文字入力モードということをはっきりと示します。
        func inputTextMode(){
            talkInputButton.isHidden = true
            micLottieAnimationView.isHidden = true
            visualEffectView.isHidden = false
            circleGrowLottieAnimationView.isHidden = true
            
        }
        
    //音声入力画面、JsonのレーダーをMicボタン中心から発生させます。
        //追加ボタンを隠します
        //「シングルタップでタスク追加、ダブルタップで入力終了」と画面背景に表示。
        //画面背景にブラーをかけて、音声入力モードということをはっきりと示します。
        func inputTalkMode(){
            addTodo.isHidden = true
            visualEffectView.isHidden = false
            circleGrowLottieAnimationView.isHidden = false
        }
        
    //ここまでが実装の画面です。
/////////////////////////////////////////
    
    
    }
    
    
    
    
    
    
    
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
        
                //藤井追加20190429
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
        
    
    
    
    
    
    
    
    
    
    
    //ここから　ここまで　のコードでtextFieldをクリックした時に上にスライドされるアニメーションが追加される
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
//  //「追加」2019年4月20日時点では、なぜか画面遷移が出来ていない・・・
    //2019年4月30日時点で、画面遷移はされましたが、どのボタンを押しても一番上のセルが選ばれてしまう・・・
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


    
//  //「追記」  こちらはストーリーボードに紐づいていないので、削除対象
    @IBAction func deleteTodo(_ sender: Any) {

    }

    
    
//  //「追加」　inputTodoTextFieldsをクリックした時にキーボード画面が出てくる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if inputTodoTextFields.resignFirstResponder() {
            inputTodoTextFields.resignFirstResponder()
        }else{
            inputTodoTextFields.becomeFirstResponder()
        }
    }
    
//  //「追加」　メモなので基本的に短い単語が多いが、長い文章になったときに
//  //     可能ならばセルの高さを、該当部分だけ広くしてほしい。
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
    
    
    
//  //「追加」　lottieにて、タスク完了時にアニメーションを表示する
    func startCheckOKAnimation(){
       
        deletedAnimationView.isHidden = false
        deletedAnimationView.setAnimation(named: "433-checked-done")
        deletedAnimationView.layer.zPosition = 1
        deletedAnimationView.loopAnimation = false
        deletedAnimationView.play { (finished) in
        
        self.deletedAnimationView.isHidden = true
            
        }
        
    }
    
//    //「追加」　音声入力ボタンが押されたら、音声入力画面に移動する
        //背景に「〇〇というと、次のタスクに移ります。」と薄い文字で入れる。
        //音声入力結果はリアルに表示されており、タスクが確定した時にテーブルにタスクが映る

    
    
    
    //録音ボタンが押されたら音声認識をツタートする
    @IBAction func micRecordButton(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
            //録音が停止した！
            print("録音停止")
            
            //藤井追加20190429
            //近藤追加20190429
            if voiceStr.isEmpty != true {
                //入力された文字列の入った文字列を表示
                //近藤追加20190430  入力された文字がリアルタイムで表示されない・・・
                inputVoiceLabel.frame = CGRect(x: 0, y: view.frame.size.width / 3, width: view.frame.size.width, height: view.frame.size.height)
                inputVoiceLabel.textAlignment = NSTextAlignment.center
                inputVoiceLabel.font = UIFont.systemFont(ofSize: 30)
                inputVoiceLabel.text = voiceStr
                view.addSubview(inputVoiceLabel)
            
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
    
    
    
    
    
//    //「追加」　背景を黒い画面に変更できるオプションを追加
    

    
    
    /* 参考URL
    音声認識(SFSpeechRecognizer)
    https://swiswiswift.com/sfspeechrecognizer/
 
    */
    
}

