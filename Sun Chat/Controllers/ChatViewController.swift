//
//  ChatViewController.swift
//  Sun Chat
//  Created by Yasin Ağbulut on 21/07/2023

//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    var messages : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.cellNibName , bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        title = K.appName
 
        loadMessages()
        

    }
    
    func loadMessages() {
       
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            self.messages = []
            if let e = error {
                print("Something is wrong. from firestore data retriving")
            }
            else {
                if let snapshotDocumanets = querySnapshot?.documents {
                    for doc in snapshotDocumanets {
                        let data = (doc.data())
                        if let MessageSender = data [K.FStore.senderField] as? String , let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: MessageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0 )
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                self.messageTextfield.text = ""
                            }
                           
                            
                        }
                    }
                }
            }
                
                }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
       
        if let messageBody = messageTextfield.text , let MessageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data:
                                                                [K.FStore.senderField : MessageSender ,
                                                                 K.FStore.bodyField :  messageBody,
                                                                 K.FStore.dateField : Date().timeIntervalSince1970
                                                                ])
            { error in
                if let e = error {
                    print("Something wrong!")
                }
                else {
                    print("Succesfuly save data.")
                }
            }
        }
    }
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            navigationController?.popToRootViewController(animated: true)
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    

}

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftAvatar.isHidden = true
            cell.rightAvatar.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        else {
            cell.leftAvatar.isHidden = false
            cell.rightAvatar.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
         return cell
    }
        
        
    }

