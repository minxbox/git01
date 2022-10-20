//
//  MemoListTableViewController.swift
//  Kxmemo
//
//  Created by NHIT on 2022/10/03.
//

import UIKit

class MemoListTableViewController: UITableViewController {
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.fetchMemo() //배열이 데이터로 채워짐
        tableView.reloadData()
      //  tableView.reloadData()
        
        //print(#function)
    }
    
    //세그웨이가 연결된
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //몇번 째 셀인지 확인
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                vc.memo = DataManager.shared.memoList[indexPath.row]
            }
            //sague 실행하는 화면을 소스 새롭게 나오는 화면이 데스티네이션
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: ComposeViewController.newMemoDidInsert, object: nil, queue: OperationQueue.main) { [weak self] (noti) in self?.tableView.reloadData()}

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.shared.memoList.count
    }

    
    // 가장 중요한 method
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let target = DataManager.shared.memoList[indexPath.row]
        cell.textLabel?.text = target.content
        cell.detailTextLabel?.text = formatter.string(for: target.insertDate)
        
        if #available(iOS 11.0, *) {
            cell.detailTextLabel?.textColor = UIColor(named: "MyLabelColor")
        } else {
            //rgb로 컬러 설정하믄 됨
            cell.detailTextLabel?.textColor = UIColor.lightGray
            // Fallback on earlier versions
        }
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true //편집기능 활성화
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { //delete 처리하는 코드
            // Delete the row from the data source
            
            let target = DataManager.shared.memoList[indexPath.row]
            DataManager.shared.deleteMemo(target)// crush
            DataManager.shared.memoList.remove(at: indexPath.row) //중요
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
