//
//  ViewController.swift
//  Taipei YouBike
//
//  Created by 賴冠宇 on 2017/7/3.
//  Copyright © 2017年 LaiTest. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    
    var session : URLSession? = nil
    var controller : MapController? = nil
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func reorganize(_ sender: UIBarButtonItem) {
        download()
        tableShow.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        
        controller = segue.destination as! MapController
        
    }
    
    @IBOutlet weak var tableShow: UITableView!
    var netData : Data!
    var infoData: Dictionary<String, String>!
    //var account: Int!
    var info3: [[String:String]]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        download()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func download(){
        let jsonurl: URL = URL(string: "http://data.ntpc.gov.tw/api/v1/rest/datastore/382000000A-000352-001")!
        // 建立背景工作模式
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackgroundSession")
        // 建立
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        // 建立下載
        let task = session?.downloadTask(with: jsonurl)
        task?.resume()
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
//        self.session?.invalidateAndCancel()
    }
}

extension ViewController: URLSessionDelegate, URLSessionTaskDelegate,URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("Start Download...")
//        
        netData = try! Data(contentsOf: location)
        
        print(netData)
        
        let jsonDict = try! JSONSerialization.jsonObject(with: self.netData, options:
            
            JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]

        
        //依據先前觀察的結構，取得result對應中的results所對應的陣列
        let info = (jsonDict as? Dictionary<String, Any>)?["result"]
        let info2 = (info as? Dictionary<String,Any>)?["records"]
        //print("info2=\(info2)")
        info3 = info2 as? [[String:String]]
//        account = info3?.count
//        for temp in info3! {
//            //print(temp["sna"])
//            let sna = temp["sna"]
//            let tot = temp["tot"]
//            let sbi = temp["sbi"]
//            
//        }
        tableShow.delegate = self
        tableShow.dataSource = self
        self.session?.invalidateAndCancel()
        //dispatch_async(dispatch_get_main_queue()
        
                DispatchQueue.main.sync {
                    self.tableShow.reloadData()
                }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData
        
        bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        print("啟動載入指示器2")
    }
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        
//        print("停止載入指示器")
//        
//        
//        
//        // 取回資料
//        
//        let jsonDict = try! JSONSerialization.jsonObject(with: self.netData, options:
//            
//            JSONSerialization.ReadingOptions.mutableContainers)
//        
//        print("jsonDict=\(jsonDict)")
//        
//        
//        
//        // 取得相關資源
//        
//        let info = (jsonDict as? Dictionary<String, Any>)?["stationinfo"]
//        
//        print("stationinfo=\(info)")
//        
//        
//        
//        infoData = info as? Dictionary<String, String>
//        
//        
//        
//        // 取得 jsonData 的字串
//        
//        let name = infoData["name"]
//        
//        let ename = infoData["ename"]
//        
//        let krtco = infoData["krtco"]
//        
//        let kbus = infoData["kbus"]
//        
//        print("name=\(name)")
//        
//        
//        
//        // 顯示內容
//        
//        // dispatch_async(dispatch_get_main_queue() 解決UI更新問題
//        
//        DispatchQueue.main.sync {
//            
////            self.nameField.text = name!
////            
////            self.enameField.text = ename!
////            
////            self.krtcoField.text = krtco!
////            
////            self.kbusField.text = kbus!
//        }
//    }
}

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    // 資料筆數
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return info3.count
        
    }
    
    // 儲存格內容
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        
        UITableViewCell {
            
            
            // 宣告 cell,並利用 tableView.dequeueReusableCell 取得儲存格
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
                cell.textLabel?.text = info3[indexPath.row]["sna"]
                cell.detailTextLabel?.text = "總車位：\(info3[indexPath.row]["tot"]!)\t\t可借：\(info3[indexPath.row]["sbi"]!)\t\t更新時間：\(info3[indexPath.row]["mday"]!)"
            
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //google map 失敗
//        let lat = info3[indexPath.row]["lat"]!
//        let lng = info3[indexPath.row]["lng"]!
//        let sna = info3[indexPath.row]["ar"]!
//        print("\(sna) -- \(lat),\(lng)")
//        //var url = "comgooglemaps://?center=\(lat),\(lng)&zoom=12"
//        //print(url)
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//            UIApplication.shared.open(URL(string:"comgooglemaps://?q=\(sna)&center=\(lat),\(lng)")!, options: [:], completionHandler: nil)
//        } else {
//            print("Can't use comgooglemaps://");
//        }
        
        controller?.select = indexPath.row
        
    }
}

