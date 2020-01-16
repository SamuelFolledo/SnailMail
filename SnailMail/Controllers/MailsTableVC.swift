//
//  MailsTableVC.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/8/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class MailsTableVC: UIViewController {
//MARK: Properties
    var mails: [Mail]!
    
//MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteAllButton: UIBarButtonItem!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        updateDeleteButton()
        configureTableView()
    }
    
    fileprivate func configureTableView() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        // remove separators from cells
//        tableView.separatorStyle = .none
    }
    
//MARK: IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAllButtonTapped(_ sender: Any) {
        let alertVC = UIAlertController(title: "Delete All Mails?", message: "Are you sure? Mails will be gone forever.", preferredStyle: .alert)
        let deleteAllAction: UIAlertAction = UIAlertAction(title: "Delete All", style: .destructive) { (action) in //deleteAllMails method
            deleteAllMails(mails: self.mails) { (error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Error Deleting All Mails", message: error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    self.mails.removeAll() //removeAll mails
                    self.tableView.reloadData()
                    self.updateDeleteButton()
                    alertVC.dismiss(animated: true, completion: nil) //dismiss MailsTableVC
                }
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in //dismisses the alertVC
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(deleteAllAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
//MARK: Helpers
    fileprivate func updateDeleteButton() {
        deleteAllButton.isEnabled = mails.count > 0 ? true : false
    }
}

//MARK: Extensions
extension MailsTableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { //swipe to delete mail
        if editingStyle == .delete {
            let deletedMail = mails[indexPath.row]
            deleteMail(mail: deletedMail) { (error) in //delete mail from storage
                if let error = error {
                    Service.presentAlert(on: self, title: "Error Deleting Mail", message: error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    self.mails.remove(at: indexPath.row) //remove from list, and cell row
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.updateDeleteButton()
                }
            }
        }
    }
}

extension MailsTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MailCell = tableView.dequeueReusableCell(withIdentifier: "mailCell") as! MailCell
        cell.mail = mails[indexPath.row]
        cell.populateViews()
        return cell
    }
}
