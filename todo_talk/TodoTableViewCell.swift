//
//  TodoTableViewCell.swift
//  todo_talk
//
//  Created by 宏輝 on 30/06/2019.
//  Copyright © 2019 Hiroki Kondo. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var todoTableViewCellTextField: UITextField!
    
    var listItems:ListItem? {
        didSet {
            todoTableViewCellTextField.text = listItems?.text
        }
    }
    
    
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
    
}

