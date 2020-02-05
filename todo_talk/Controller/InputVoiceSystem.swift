//
//  InputVoiceSystem.swift
//  todo_talk
//
//  Created by 近藤宏輝 on 2020/01/31.
//  Copyright © 2020 Hiroki Kondo. All rights reserved.
//

import UIKit
import Speech

class InputVoiceSystem:NSObject, SFSpeechRecognizerDelegate {
    
    
    //    //音声関連
    // MARK: Properties
    //localeのidentifierに言語を指定、。日本語はja-JP,英語はen-US
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    //音声入力時に、別枠でTextFieldを表すために実装
    //    let voiceTalkText = UITextField()
    let voiceTalkText = UITextView()
    //音声入力をリアルタイムで反映させるための処置。1回目のみUITextFieldを作成する。
    //二回目以降は1回目のUITextFieldに上書きをする。
    var notFirstTimeInputRealTimeText = false
    
    
    //文字音声認識された
    var voiceStr : String! = ""
    
    
    //マイクボタンをタッチしたときに、touchesbeganを無効にする
    var micButtonTouchesOrNot = false
    
    
    
    //音声入力の許可をユーザーに求める
    func allowOnsei(){
        
        //デリゲートの設定
        speechRecognizer.delegate = self
        
        //ユーザーに音声認識の許可を求める
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation(recordButton: UIButton) -> Void {
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
    
    
    func realTimeInputTalkIntoTextField() {
        //音声入力時にリアルタイムで文字が入力されているのを確認するため実装
        voiceTalkText.text = ""
        
        voiceTalkText.frame = CGRect(x: 20, y: view.frame.size.width/5*4, width: view.frame.size.width - 20, height: view.frame.size.height/4)
        voiceTalkText.layer.zPosition = 4
        voiceTalkText.font = UIFont.init(name: "HiraMaruProN-W4", size: 20)
        //   systemFont(ofSize: 28)
        voiceTalkText.textColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
        voiceTalkText.backgroundColor = .clear
        voiceTalkText.textAlignment = .center
        voiceTalkText.delegate = self
        voiceTalkText.textAlignment = .left
        //            voiceTalkText.frame = todoBlurVibrancyEffect.contentView.bounds
        todoBlurVibrancyEffect.contentView.addSubview(voiceTalkText)
        
        voiceTalkText.text = voiceStr
    }
    
    //渡された文字列が入ったアラートを表示する
    
    func showStrAlert(str: String) {
        
        // UIAlertControllerを作成する.
        let myAlert: UIAlertController = UIAlertController(title: "音声認識結果", message: "", preferredStyle: .alert)
        
        
        // OKのアクションを作成する.
        let myOkAction = UIAlertAction(title: "OK", style: .default) { action in
            print("Action OK!!")
        }
        
        // OKのアクションを作成する.
        myAlert.addAction(myOkAction)
        
        // UIAlertを発動する.
        present(myAlert, animated: true, completion:  nil)
        
    }
    
    
    
    
    //藤井さん記載ののコード追加20190609_2
    private func startRecording() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                
                //近藤追加20190609
                self.voiceStr = result.bestTranscription.formattedString
                self.realTimeInputTalkIntoTextField()
                self.voiceTalkText.text = ""
                self.voiceTalkText.text = self.voiceStr
                
    
                print(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        voiceTalkText.text = voiceStr
    }
    
    @objc func changeText(_ textField: UITextField)  {
        //20190630近藤追加　本当はTableViewでダイレクトに入力されて欲しかったが、出来なかったので別枠で表示にした
        voiceTalkText.text = textField.text
        todoTableViewCellTextField.text = textField.text
    }

    

    func micRecordButtonConfigure(){
        
        micButtonTouchesOrNot = true
        //20190630近藤追加　ブラー、マイクの波紋が出るようにした。
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.inputTalkMode()
        }, completion: nil)
        
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
            //            録音が停止した！
            print("録音停止")
            notFirstTimeInputRealTimeText = false
            
            
            if voiceStr.isEmpty != true {
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.waitingView()
                }, completion: nil)
                
                self.todoArray.append(self.voiceStr)
                UserDefaults.standard.set(self.todoArray, forKey: "todo")
                self.todoTableView.reloadData()
                self.voiceStr = ""
                self.recordButton.isEnabled = true
                
            }else {
                //空の場合
                showVoiceInputAlert()
            }
        } else {
            try! startRecording()
            recordButton.setTitle("Stop recording", for: [])
        }
        print("voiceStr")
        
        
        
        
    }
    
    
    
    
    
    func showVoiceInputAlert(){
        print(recordButton.isEnabled)
        let alertViewControler = UIAlertController(title: "何も音声が入力されていません。", message: "もう一度、発声してください", preferredStyle: .alert)
        
        //        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (alert) in
            try! self.startRecording()
        }
        
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        self.recordButton.isEnabled = true
        print(recordButton.isEnabled)
    }
    
    
    
    //lottieにて、talkInputButtonの中心点から発生しているようにする。
    //問題あり！。音声入力NG時or編集時に右上のDoneを押すとボタンが消えてしまう。
    func waitingView(){
        circleGrowLottieAnimationView.isHidden = true
        //        startMicAnimation()
        //        addTodoView.isHidden = false
        //        inputTodoTextFields.isHidden = false
        goToEditView.isHidden = false
        todoBlurVibrancyEffect.isHidden = true
    }
    
}


