//
//  ViewController.swift
//  AssignmentIos
//
//  Created by User on 6/10/20.
//  Copyright © 2020 Simranjeet kaur. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController,CLLocationManagerDelegate{
    
    var zoomingIn = false
    var selectedPlace: CLLocationCoordinate2D?
       
    @IBOutlet weak var segmentedController:
    UISegmentedControl!
    
    @IBOutlet weak var zoomOutButton: UIButton!
    
    var destination: CLLocationCoordinate2D!
   
    @IBOutlet weak var directionBtn: UIButton!
    
    
   
    @IBOutlet weak var mapView: MKMapView!
    let places = Place.getPlaces()
     
    
    var locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
       locationManager.delegate = self
        mapView.showsUserLocation = true
    
        
       mapView.delegate = self
        
        addDoubleTap()
        
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        view.addGestureRecognizer(pinch)
        
        if (selectedPlace != nil) {
            let annotation = MKPointAnnotation()
            annotation.title = "My destination"
            annotation.coordinate = selectedPlace!
            mapView.addAnnotation(annotation)
            destination = selectedPlace!
        }
        
        
}
    
   @objc func handlePinch(sender: UIPinchGestureRecognizer) {
              guard sender.view != nil else { return }
              
              if sender.state == .began || sender.state == .changed {
                  sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
                  sender.scale = 1.0
              }
     
        }
    
    
    @IBAction func zoomButton(_ sender: Any) {
        
        let coordinatezoomin = mapView.userLocation.coordinate
                let region = MKCoordinateRegion(center: coordinatezoomin, latitudinalMeters: 800*2, longitudinalMeters: 800*2)
                mapView.setRegion(region, animated: true)
    
        
    }
    
    
    
    func addPlaces() {
           mapView.addAnnotations(places)
           
           let overlays = places.map { MKCircle(center: $0.coordinate, radius: 1000)}
           mapView.addOverlays(overlays)
       }
    
    func addPolyline() {
        let coordinates = places.map {$0.coordinate}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           let userLocation = locations[0]
           
           let latitude = userLocation.coordinate.latitude
           let longitude = userLocation.coordinate.longitude
           
           displayLocation(latitude: latitude, longitude: longitude, title: "Your Location", subtitle: "you are here")
           
           
       }
       //MARK: - display user location method
          func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
              // 2 - define delta latitude and delta longitude for the span
              let latDelta: CLLocationDegrees = 0.05
              let lngDelta: CLLocationDegrees = 0.05
              
              // 3 - creating the span and location coordinate and finally the region
              let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
              let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
              let region = MKCoordinateRegion(center: location, span: span)
              
              // 4 - set region for the map
              mapView.setRegion(region, animated: true)
            
          }
      func addDoubleTap() {
              let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
              doubleTap.numberOfTapsRequired = 2
              mapView.addGestureRecognizer(doubleTap)
          }
          @objc func dropPin(sender: UITapGestureRecognizer) {
                 removePin()
                 
                 // add annotation
                 
                 let touchPoint = sender.location(in: mapView)
                 let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                 let annotation = MKPointAnnotation()
                 annotation.title = "My destination"
                 annotation.coordinate = coordinate
                 mapView.addAnnotation(annotation)
              destination = coordinate
    }
            
            
func getdirection(destination:CLLocationCoordinate2D){
    
let destinationcoordinate = MKDirections.Request()
    let sourcecoordinate = mapView.userLocation.coordinate
    
    let source = CLLocationCoordinate2DMake(sourcecoordinate.latitude, sourcecoordinate.longitude)
    let destination = CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    
    print(source)
    print(destination)
    
    let sourceplacemark = MKPlacemark(coordinate: source)
    let destinationplacemark = MKPlacemark(coordinate: destination)
    
    
    let finalsource = MKMapItem(placemark: sourceplacemark)
    let finaldestination = MKMapItem(placemark: destinationplacemark)
    destinationcoordinate.source = finalsource
    destinationcoordinate.destination =  finaldestination
    
    
    
    
    switch segmentedController.selectedSegmentIndex {
        case 0 :
    destinationcoordinate.transportType = .automobile
            print("automobile")
    for overlay in mapView.overlays{
    mapView.removeOverlay(overlay)
                            
                        }
    case 1 :
    destinationcoordinate.transportType = .walking
    for overlay in mapView.overlays{
    mapView.removeOverlay(overlay)}

    print("walking")
    case 2:
    destinationcoordinate.transportType = .transit
                            
    print("transit")
        default:break
            
        }
            
            
let direction = MKDirections(request: destinationcoordinate)
    direction.calculate{(response, error) in
        guard let response = response else{
        if let error = error{
                           print(error)
                       }
                       return
                   }
        let route = response.routes[0]
    self.mapView.addOverlay(route.polyline,level:.aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                   }
               }
            
            
            
            
            
            
            
            
            
            
            
          func removePin() {
                  for annotation in mapView.annotations {
                      mapView.removeAnnotation(annotation)
                  }
          
              }
    
    @IBAction func SaveFavLocation(_ sender: UIBarButtonItem) {
        let alt = UIAlertController(title: "Save", message: "Enter the name", preferredStyle: .alert)
        alt.addTextField()
        let altAction = UIAlertAction(title: "submit", style: .default) { (ac) in
            let pObj = Place(title: alt.textFields![0].text, subtitle: "s1", coordinate: self.destination)
            placeObj.favPlaces.append(pObj)
        }
        alt.addAction(altAction)
        present(alt, animated: true)
    }
    @IBAction func drawDirection(_ sender: Any) {
    
    
    mapView.removeOverlays(mapView.overlays)
                
                let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
                let destinationPlaceMark = MKPlacemark(coordinate: destination)
                
                // request a direction
                let directionRequest = MKDirections.Request()
                
                // define source and destination
                directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
                
                // transportation type
                directionRequest.transportType = .walking
                
                // calculate directions
               
        
        let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                    guard let directionResponse = response else {return}
                    // create route
                    let route = directionResponse.routes[0]
                    // draw the polyline
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    // defining the bounding map rect
                    let rect = route.polyline.boundingMapRect
        //            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
                    self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                }
            
    }
}
     
       
    
    
    extension ViewController: MKMapViewDelegate{

           
           func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
           
            
              guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
               
               let reuseId = "pin"
               var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
               
               if pinView == nil {
                   pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                   pinView!.canShowCallout = true
                   pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
                   pinView!.pinTintColor = UIColor.red
               }
               else {
                   pinView!.annotation = annotation
               }
               return pinView
            
        }
           
            
            
            
            
            
            
           
           
        /*   func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
               if control == view.rightCalloutAccessoryView {
                   if let doSomething = view.annotation?.title! {
                      print("do something")
                   }*/
               
           
    
    func map(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
           let alertController = UIAlertController(title: "Your Place", message: "Welcome", preferredStyle: .alert)
           let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
           alertController.addAction(cancelAction)
           present(alertController, animated: true, completion: nil)
       }
    
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        if overlay is MKCircle {
                   let rendrer = MKCircleRenderer(overlay: overlay)
                   rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
                   rendrer.strokeColor = UIColor.green
                   rendrer.lineWidth = 2
                   return rendrer
               }
                   else if overlay is MKPolyline {
                   let rendrer = MKPolylineRenderer(overlay: overlay)
                   rendrer.strokeColor = UIColor.blue
                   rendrer.lineWidth = 3
                   return rendrer
               
               }
               return MKOverlayRenderer()
        
        }
    
}
    
        



       

       




