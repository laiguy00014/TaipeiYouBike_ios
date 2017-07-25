//
//  MapController.swift
//  Taipei YouBike
//
//  Created by 賴冠宇 on 2017/7/5.
//  Copyright © 2017年 LaiTest. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
class MapController: UIViewController{
    
    var netData : Data!
    var infoData: Dictionary<String, String>!
    //var info3: [[String:String]]!
    var session : URLSession? = nil
    var select : Int = -1
    //var myLocationManager :CLLocationManager!
    
    @IBOutlet weak var mMap: MKMapView!
    
    @IBAction func reorganize(_ sender: Any) {
        download()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //myLocationManager = CLLocationManager()
        //getLocation()
        mMap.delegate = self
        mMap.showsUserLocation = true
        print("select=\(select)")
        download()
        
        let center:CLLocation = CLLocation(
            latitude: 25.017755, longitude: 121.458308)
        
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan:MKCoordinateSpan =
            MKCoordinateSpanMake(latDelta, longDelta)
        let currentRegion:MKCoordinateRegion =
            MKCoordinateRegion(
                center: center.coordinate,
                span: currentLocationSpan)
        mMap.setRegion(currentRegion, animated: true)
        
//        let annotation = MKPointAnnotation()
//        let centerCoordinate = CLLocationCoordinate2D(latitude: 25,longitude: 121)
//        annotation.coordinate = (center?.coordinate)!
//        annotation.title = "Title"
//        mMap.addAnnotation(annotation)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func getLocation(){
//        print("getLocation")
//        if CLLocationManager.authorizationStatus()
//            == .notDetermined {
//            // 取得定位服務授權
//            myLocationManager.requestWhenInUseAuthorization()
//            // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
//            myLocationManager.distanceFilter =
//            kCLLocationAccuracyNearestTenMeters
//            
//            // 取得自身定位位置的精確度
//            myLocationManager.desiredAccuracy =
//            kCLLocationAccuracyBest
//            
//            // 開始定位自身位置
//            myLocationManager.startUpdatingLocation()
//        }
//            // 使用者已經拒絕定位自身位置權限
//        else if CLLocationManager.authorizationStatus()
//            == .denied {
//            // 提示可至[設定]中開啟權限
//            let alertController = UIAlertController(
//                title: "定位權限已關閉",
//                message:
//                "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
//                preferredStyle: .alert)
//            let okAction = UIAlertAction(
//                title: "確認", style: .default, handler:nil)
//            alertController.addAction(okAction)
//            self.present(
//                alertController,
//                animated: true, completion: nil)
//        }
//            // 使用者已經同意定位自身位置權限
//        else if CLLocationManager.authorizationStatus()
//            == .authorizedWhenInUse {
//            // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
//            myLocationManager.distanceFilter =
//            kCLLocationAccuracyNearestTenMeters
//            
//            // 取得自身定位位置的精確度
//            myLocationManager.desiredAccuracy =
//            kCLLocationAccuracyBest
//            // 開始定位自身位置
//            myLocationManager.startUpdatingLocation()
//            
//        }
//    }
    
    func download(){
        print("down")
        let jsonurl: URL = URL(string: "http://data.ntpc.gov.tw/api/v1/rest/datastore/382000000A-000352-001")!
        
        // 建立背景工作模式
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackgroundSession2")
        
        // 建立
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // 建立下載
        
        let task = session?.downloadTask(with: jsonurl)
        
        task?.resume()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("MapviewDidDisappear")
        //self.session?.invalidateAndCancel()
        //myLocationManager.stopUpdatingLocation()
    }
}

extension MapController : MKMapViewDelegate{
    
}
//extension MapController : CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locations[0]
//    }
//}
extension MapController: URLSessionDelegate, URLSessionTaskDelegate,URLSessionDownloadDelegate{
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
        
        let info3 = info2 as? [[String:String]]
        self.session?.invalidateAndCancel()
        
        
        DispatchQueue.main.sync {
            for temp in info3!
            {
                let annotation = MKPointAnnotation()
                let centerCoordinate = CLLocationCoordinate2D(latitude: Double(temp["lat"]!)!,longitude: Double(temp["lng"]!)!)
                annotation.coordinate = (centerCoordinate)
                annotation.title = "\(temp["sna"]!)"
                annotation.subtitle = "總車位：\(temp["tot"]!)\t\t可借：\(temp["sbi"]!)"
                mMap.addAnnotation(annotation)
                //print("add")
            }
            if select != -1 {
                let latDelta = 0.01
                let longDelta = 0.01
                let currentLocationSpan:MKCoordinateSpan =
                    MKCoordinateSpanMake(latDelta, longDelta)
                let center = CLLocationCoordinate2D(latitude: Double((info3?[select]["lat"])!)!,longitude: Double((info3?[select]["lng"])!)!)
                let currentRegion:MKCoordinateRegion =
                    MKCoordinateRegion(
                        center: center,
                        span: currentLocationSpan)
                mMap.setRegion(currentRegion, animated: true)
                
            }
            
        }
        
    }

}
