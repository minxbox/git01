//
//  DetailViewController.swift
//  Kxmemo
//
//  Created by NHIT on 2022/10/05.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var memoTableView: UITableView!
    
    
    
    //이전 화면에서 전달한 메모를 전달할 객체
    var memo: Memo?
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    @IBAction func share(_ sender: Any) {
        guard let memo = memo?.content else { return }
        
        let vc = UIActivityViewController(activityItems: [memo], applicationActivities: nil)
        
        present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func deleteMemo(_ sender: Any) {
        //확인창
        let alert = UIAlertController(title: "삭제 확인", message: "메모를 삭제할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] (action) in
            DataManager.shared.deleteMemo(self?.memo) //현재 화면에 표시되어있는 메모 전달
            //이전 화면으로 돌아가야함
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(okAction)
        
        //취소버튼 - 어떤 버튼을 눌러도 창이 꺼지기때문에 nil
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.children.first as?
            ComposeViewController {
            vc.editTarget = memo
        }
    }
    
    var token: NSObjectProtocol?
    
    //옵저버 해제
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        token = NotificationCenter.default.addObserver(forName: ComposeViewController.memoDidChange, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in self?.memoTableView.reloadData()
            
        })

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    //테이블이 어떤 뷰를 보여줄지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)
            cell.textLabel?.text = memo?.content
            
            return cell
        case 1 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
            
            cell.textLabel?.text = formatter.string(for: memo?.insertDate)
            return cell
        default:
            fatalError()
        }
    }
    
    
}
