import UIKit
import MapKit

class DetailTableViewController: UITableViewController {

    //상위 뷰 컨트롤러로 부터 넘겨받을 데이터의 변수 선언
    var mapItems = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    //테이블 뷰를 출력하는 메소드 구현
    //*TableViewController일 때는 overriding, ViewController일 때는 implementation
    //섹션의 개수를 만드는 메소드
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //섹션별 행의 개수를 설정하는 메소드
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //셀 생성
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as! MyTableViewCell
        //행번호에 해당하는 데이터 찾아오기
        let row = self.mapItems[indexPath.row]
        //출력
        cell.lblName.text = row.name
        cell.lblPhone.text = row.phoneNumber

        return cell
    }
    
    
    //테이블의 셀을 선택했을 때 호출되는 메소드 재정의
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //출력할 하위 뷰 컨트롤러의 객체를 생성
        let routeViewController = self.storyboard?.instantiateViewController(withIdentifier: "RouteViewController") as! RouteViewController
        //행 번호에 해당하는 데이터 넘겨주기
        routeViewController.destination = mapItems[indexPath.row]
        //이동
        self.navigationController?.pushViewController(routeViewController, animated: true)
    }
}
