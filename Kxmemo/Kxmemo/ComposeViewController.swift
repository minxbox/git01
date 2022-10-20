//
//  ComposeViewController.swift
//  Kxmemo
//
//  Created by NHIT on 2022/10/04.
//

import UIKit

class ComposeViewController: UIViewController {
    
    //속성
    var editTarget: Memo?
    var originalMemoContent: String?

    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func save(_ sender: Any) {
        guard let memo = memoTextView.text,
              memo.count > 0 else{
            alert(message: "메모를 입력하세요")
            return
        }
        
//        let newMemo = Memo(content: memo)
//        Memo.dummyMemoList.append(newMemo)
        if let target = editTarget {
            target.content = memo
            DataManager.shared.saveContext()
            
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil) //broadcast
            
        } else {
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil) //broadcast
        }
        
        
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func close(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    var willShowToken:NSObjectProtocol? //옵저버 해제할때 씀
    var willHideToken:NSObjectProtocol? //옵저버 해제할때 씀
    
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //보통 한번만 실행되는 초기화 코드
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
            
            originalMemoContent = memo.content
            
            
        } else {
            navigationItem.title = "새 메모"
            memoTextView.text = ""
        }
        
        memoTextView.delegate = self
        
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            
            guard let strongSelf = self else { return }
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue {
                let height = frame.cgRectValue.height
                
                var inset = strongSelf.memoTextView.contentInset
                inset.bottom = height
                strongSelf.memoTextView.contentInset = inset //bottom을 제외한 나머지 여백은 유지됨
                
                inset = strongSelf.memoTextView.scrollIndicatorInsets
                inset.bottom = height
                strongSelf.memoTextView.scrollIndicatorInsets = inset
            }
                    
                    
        })
        
        
        
        //새로운 옵저버는 추가한 옵저버 다음에!
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else { return }
            
            var inset = strongSelf.memoTextView.contentInset
            inset.bottom = 0
            strongSelf.memoTextView.contentInset = inset
            
            inset = strongSelf.memoTextView.scrollIndicatorInsets
            inset.bottom = 0
            strongSelf.memoTextView.scrollIndicatorInsets = inset
        })
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //입력 포커스를 가진 뷰 - first respoder
        memoTextView.becomeFirstResponder()
        
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        memoTextView.resignFirstResponder() //입력포커스 제거되고 키보드 사라짐
        navigationController?.presentationController?.delegate = nil
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

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if #available(iOS 13.0, *) {
            if let original = originalMemoContent, let edited = textView.text {
                
                isModalInPresentation = original != edited //true - 시트형식으로 나옴 ios13 버전이상에서 실행됨
            }
        } else {
            // Fallback on earlier versions
            
        }
    }
}

extension ComposeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
            
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] (action) in
            self?.save(action)
        }
        
        alert.addAction(okAction)
        
        //cancle action
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] (action) in
            self?.close(action)
            
        }
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ComposeViewController {
    
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
