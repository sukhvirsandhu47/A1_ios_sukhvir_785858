import UIKit
import MapKit
class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    @IBOutlet weak var mapview: MKMapView!
    var manager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        mapview.addGestureRecognizer(doubleTap)
    }
    @objc func doubleTap(_ gesture: UITapGestureRecognizer){
        let touch = gesture.location(in: mapview)
        let tapLocation = mapview.convert(touch, toCoordinateFrom: mapview)
        var title = "A"
        switch mapview.annotations.count {
        case 0:
            title = "A"
        case 1:
            title = "B"
        default:
            title = "C"
        }
    
        if let near = mapview.annotations.closest(to: CLLocation(latitude: tapLocation.latitude, longitude: tapLocation.longitude)){
            mapview.removeAnnotation(near)
            for overlay in mapview.overlays{
                mapview.removeOverlay(overlay)
            }
        }
        else{
            if mapview.annotations.count < 3{
                let pin  = MKPointAnnotation()
                pin.title = title
                pin.coordinate = tapLocation
                mapview.addAnnotation(pin)
                if mapview.annotations.count == 3{
                    let poly = MKPolygon(coordinates: mapview.annotations.map({$0.coordinate}), count: 3)
                    mapview.addOverlay(poly)
                }
            }
            else{
                mapview.removeOverlays(mapview.overlays)
                mapview.removeAnnotations(mapview.annotations)
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon{
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red
            rendrer.strokeColor = UIColor.green
            rendrer.alpha = 0.5
            return rendrer
        }
        else if overlay is MKPolyline{
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.lineWidth = 4
            rendrer.strokeColor = UIColor.purple
            return rendrer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapview.region = MKCoordinateRegion(center: locations[0].coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
}
// Refrence from internet
        extension Array where Iterator.Element == MKAnnotation {
            
            func closest(to fixedLocation: CLLocation) -> Iterator.Element? {
                guard !self.isEmpty else { return nil}
                var closestAnnotation: Iterator.Element? = nil
                var smallestDistance: CLLocationDistance = 7000
                for annotation in self {
                    let locationForAnnotation = CLLocation(latitude: annotation.coordinate.latitude, longitude:annotation.coordinate.longitude)
                    let distanceFromUser = fixedLocation.distance(from:locationForAnnotation)
                    if distanceFromUser < smallestDistance {
                        smallestDistance = distanceFromUser
                        closestAnnotation = annotation
                    }
                }
                return closestAnnotation
            }
        }
