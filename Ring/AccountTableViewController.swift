//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Pablo on 27/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController, UINavigationControllerDelegate {
    //MARK: Properties
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        self.setNeedsStatusBarAppearanceUpdate()
        unarchiveAccounts()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AccountTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AccountTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AccountTableViewCell.")
        }
        let account = accounts[indexPath.row]
        let colorView = UIView()
        colorView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = colorView
        cell.nameLabel.text = account.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            accounts.remove(at: indexPath.row)
            archiveAccounts()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: Private methods
    private func archiveAccounts() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: accounts, requiringSecureCoding: true)
            print("Saving \(accounts)")
            try data.write(to: Account.ArchiveURL)
            print("Successfully written \(data)")
        } catch {
            print("Error info: \(error)")
        }
    }
    
    private func unarchiveAccounts() {
        do {
            let data = try Data(contentsOf: Account.ArchiveURL)
            print("Data to load: \(data)")
            guard let accounts = try
                NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Account] else {
                     fatalError("Error info: can't load array of accounts")
                }
            self.accounts = accounts
            print("Successfully loaded \(accounts)")
        } catch {
            print("Error info: \(error)")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToAccountList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AccountViewController, let account = sourceViewController.account {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                accounts[selectedIndexPath.row] = account
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: accounts.count, section: 0)
                accounts.append(account)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            archiveAccounts()
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddAccount":
            print("Adding a new account.")
        case "ShowAccountDetail":
            guard let accountViewController = segue.destination as? AccountViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedAccountCell = sender as? AccountTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedAccountCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedAccount = accounts[indexPath.row]
            accountViewController.account = selectedAccount
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}
