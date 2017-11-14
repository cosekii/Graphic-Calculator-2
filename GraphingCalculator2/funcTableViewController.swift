//
//  funcTableViewController.swift
//  GraphingCalculator2
//
//  Created by Craig Frey on 9/23/17.
//  Copyright © 2017 CS2048 Instructor. All rights reserved.
//

import UIKit

class funcTableViewController: UITableViewController {

    //let testFuncs = ["x", "x**2", "x+2"]
    //static var currentEquation = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(FunctionsDBChangeNotification), object: FunctionsDB.sharedInstance, queue: nil) { (NSNotification) in self.tableView.reloadData() }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FunctionsDB.sharedInstance.functions.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! funcTableViewCell

        cell.expressionLabel?.text = FunctionsDB.sharedInstance.functions[indexPath.row]
        cell.expressionImage?.image = FunctionsDB.sharedInstance.functionImages[indexPath.row]
        return cell
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.beginUpdates()
            FunctionsDB.sharedInstance.functions.remove(at: indexPath.row)
            FunctionsDB.sharedInstance.functionImages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } /*else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }  */
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame: CGRect = tableView.frame
        let button = UIButton(frame: CGRect(x: frame.size.width - 35, y: 5, width: 30, height: 30))
        button.setTitle("⨁", for: .normal)
        button.setTitleColor(self.view.tintColor, for: .normal)
        let title = UILabel(frame: CGRect(x: 5, y: 5, width: 100, height: 30))
        title.text = "Functions"
        button.addTarget(self, action: #selector(addNewFunctionPressed), for: .touchUpInside)
        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.addSubview(title)
        headerView.addSubview(button)
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func addNewFunctionPressed(_ sender: UIButton) {
        
        FunctionsDB.sharedInstance.functions.append("x")
        FunctionsDB.sharedInstance.functionImages.append(nil)
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

 
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! funcTableViewCell
        let vcDest = segue.destination as! FunctionPlottingViewController
        vcDest.expressionFromSegue = cell.expressionLabel?.text
        vcDest.expressionIndexFromSegue = tableView.indexPath(for: cell)?.row
        
    }


}
