
import UIKit
//맵 뷰 사용
import MapKit
//현재 위치 출력
import CoreLocation

class ViewController: UIViewController {
  

    //위치정보 사용 객체의 변수를 선언
    var locationManager:CLLocationManager!
    
    //디자인 mapView와 변수 연결
    @IBOutlet weak var mapView: MKMapView!
    
    //툴바 아이템 3개와 이벤트 메소드 연결
    @IBAction func zoom(_ sender: Any) {
        //맵 뷰에서 현재 사용자의 위치 가져오기
        let userLocation = mapView.userLocation
        //출력 영역 만들기
        let region = MKCoordinateRegion(center:userLocation.coordinate, latitudinalMeters:2000, longitudinalMeters:2000)
        //맵 뷰에 설정
        mapView.setRegion(region, animated: true)
    }
    @IBAction func type(_ sender: Any) {
        if mapView.mapType == .satellite{
            mapView.mapType = .standard
        }else{
            mapView.mapType = .satellite
        }
    }
    @IBAction func moveDetail(_ sender: Any) {
        let detailTableViewController =
            self.storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
        detailTableViewController.mapItems = self.matchingItems
        self.title = "MainView"
        self.navigationController?.pushViewController(detailTableViewController, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //위치정보 사용 객체를 생성
        locationManager = CLLocationManager()
        //위치정보 사용 권한을 묻는 대화상자를 출력
        locationManager?.requestWhenInUseAuthorization()
        //맵 뷰에 현재 위치 출력
        mapView.showsUserLocation = true
        
        mapView.delegate = self
    }

    
    //검색결과를 저장할 배열 객체
    var matchingItems : [MKMapItem] = [MKMapItem]()
    //디자인 텍스트뷰 1개(검색창)와 변수 및 이벤트 메소드 연결
    @IBOutlet weak var txtSearch: UITextField!
    @IBAction func search(_ sender: Any) {
        //키보드 제거
        let textField = sender as! UITextField
        textField.resignFirstResponder()
        //맵 뷰의 어노테이션 제거
        mapView.removeAnnotations(mapView.annotations)
        //검색 메소드 호출
        performSearch()
    }
    
    //검색을 수행할 메소드
    func performSearch(){
        //기존 검색 내용 삭제
        matchingItems.removeAll()
        //검색 객체 만들기
        let request = MKLocalSearch.Request()
        //검색어와 검색영역 설정
        request.naturalLanguageQuery = txtSearch.text
        request.region = mapView.region
        //검색을 요청하는 객체 생성
        let search = MKLocalSearch(request: request)
        //검색요청과 핸들러
        search.start(completionHandler:{(response:MKLocalSearch.Response!,error:Error!) in
            if error != nil{
                print("검색 중 에러")
            }else if response?.mapItems.count == 0{
                print("검색된 결과가 없음")
            }else{
                print("검색 성공")
                //전체 데이터를 순회하면서
                for item in response.mapItems as [MKMapItem]{
                    print(item)
                    //데이터를 한개 씩 배열에 저장
                    self.matchingItems.append(item as MKMapItem)
                    //각각을 맵에 출력
                    let annotation = MKPointAnnotation()
                    //어노테이션 정보를 생성
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }
}

extension ViewController : MKMapViewDelegate{
    //사용자의 위치가 변경된 경우 호출되는 메소드
    func mapView(_ map: MKMapView, didUpdate userLocation: MKUserLocation){
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
}
