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
    var mails: [String: Mail] = [:]
    
//MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
//MARK: IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
//MARK: Helpers
    
}

//MARK: Extensions
extension MailsTableVC: UITableViewDelegate {
    
}

extension MailsTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MailCell = tableView.dequeueReusableCell(withIdentifier: "mailCell") as! MailCell
//        cell.mail = mails
        return cell
    }
    
    
}
