//
//  TodoTableViewCell.swift
//  todo_talk
//
//  Created by 宏輝 on 30/06/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit

//デリゲート先に適用してもらうプロトコル
protocol EditTodoDelegate {
    func textFieldDidEndEditing(cell:TodoTableViewCell, value:String)
}

class TodoTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    var delegate:EditTodoDelegate! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    //デリゲートメソッド
    //参考URL
    //【Swift】テーブルに表示しているデータをキーボードを使って変更する。
    //https://hajihaji-lemon.com/smartphone/swift/セル編集/
    //swift2.1を変更した。
    func textFieldDidEndEditing(_ textField: UITextField) {
        //テキストフィールドから受けた通知をデリゲート先に流す。
        self.delegate.textFieldDidEndEditing(cell: self, value: textField.text!)
    }
    
}

