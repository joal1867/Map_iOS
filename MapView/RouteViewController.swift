import UIKit
//MapView를 사용하기 위한 프레임워크
import MapKit
//현재위치를 사용하기 위한 프레임워크
import CoreLocation

class RouteViewController: UIViewController {
    //디자인 맵뷰 1개와 변수 연결
    @IBOutlet weak var mapViewNavi: MKMapView!
    
    //상위 뷰 컨트롤러로 부터 데이터를 넘겨받을 변수 생성
    //위처정보는 MKMapItem이 가지고 있습니다.
    var destination:MKMapItem?
    
    
    //현재 위치를 받아서 사용하기 위한 코드 (*사전작업: import CoreLocation)
    //위치정보를 사용하기 위한 변수
    //CLLocationManager(위치정보를 가져오기 위한 클래스)의 객체생성
    var locationManager = CLLocationManager()
    //위치정보를 저장하기위한 변수
    //현재위치를 저장할 CLLocation자료형의 변수를 인스턴스 변수로 선언
    var userLocation:CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //맵 뷰의 delegate 설정
        mapViewNavi.delegate = self
        //맵 뷰에서의 위치를 사용할 수 있도록 설정
        mapViewNavi.showsUserLocation = true
        
        //MapView의 현재 위치정보를 사용할 수 있도록 설정
        //정밀도 설정 - 높이면 배터리 소모량이 많습니다.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //delegate설정
        locationManager.delegate = self
        //위치정보 사용여부 확인
        locationManager.requestLocation()
    }
}

//에러방지를 위해 MKMapViewDelegate 프로토콜을 conform한 extension 생성
//CLLocationManagerDelegate 프로토콜을 conform 한 extension 생성 -> 메소드구현
extension RouteViewController : MKMapViewDelegate, CLLocationManagerDelegate{
    //지도에 경로를 출력해주는 사용자 정의메소드
    func showRoute(_ response : MKDirections.Response){
        //지도 위에 경로 출력
        for route in response.routes{
            //지도에 오버레이 출력
            mapViewNavi.addOverlay(route.polyline, level:MKOverlayLevel.aboveRoads)
            //경로를 콘솔에 출력
            for step in route.steps{
                print(step.instructions)
            }
        }
        //지도를 사용자의 위치에 따라 이동하도록 만들기
        if let coordinate = userLocation?.coordinate{
            let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
            mapViewNavi.setRegion(region, animated: true)
        }
    }
    
    //2개의 위치정보를 가지고 경로를 찾아오는 사용자 정의 메소드
    func getDirections(){
        //경로를 찾아주는 객체 만들기
        let request = MKDirections.Request()
        //위치설정
        request.source = MKMapItem.forCurrentLocation()
        if let destination = destination{
            request.destination = destination
        }
        //옵션 설정 - 반대 경로는 찾지 않기
        request.requestsAlternateRoutes = false
        //옵션을 가지고 길찾기를 수행해 줄 객체 생성
        let directions = MKDirections(request: request)
        //길찾기 시작
        directions.calculate(completionHandler: {(response, error) in
            //길찾기가 완료되면 지도에 출력하는 메소드 호출
            if let error = error{
                print(error.localizedDescription)
            }else{
                if let response = response{
                    self.showRoute(response)
                }
            }
        })
    }
    
    //위치정보를 가져오는데 성공했을 때 호출되는 메소드 : CLLocationManagerDelegate 메소드
    func locationManager(_ manager : CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //가장 마지막의 위치를 저장
        userLocation = locations[locations.count-1]
        //길찾기 메소드 호출
        getDirections()
    }
    
    //위치정보를 가져오는데 실패했을 때 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    //맵뷰에 오버레이를 할 때 호출되는 메소드
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
}
