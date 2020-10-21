//
//  ViewController.swift
//  SecretMessage
//
//  Created by Brandon Barros on 11/12/19.
//  Copyright © 2019 Brandon Barros. All rights reserved.
//

import UIKit
import MapKit

struct MapData: Codable {
    let polylines: [Polyline]
    let annotations: [Annotation]
}

struct Polyline: Codable {
    let line_number: Int
    let coords: [Coord]
    
}

struct Coord: Codable {
    let lat: Double
    let long: Double
    
}

struct Annotation: Codable {
    let lat: Double
    let long: Double
}

class ViewController: UIViewController {
    
    var p = [Polyline]()
    var a = [Annotation]()
    var lines = [MKPolyline]()
    var ghosts = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        
        getData()
        
        var latit = 0.0
        var long = 0.0
        
        for c in a {
            latit = latit + c.lat
            long = long + c.long
        }
        
        latit = latit/Double(a.count)
        long = long/Double(a.count)
        
        print(latit)
        print(long)
        
        let initialLocation = CLLocation(latitude: latit, longitude: long)
        let regionRadius: CLLocationDistance = 3000
        
        
        centerMapOnLocation(location: initialLocation, region: regionRadius)
        
        
        drawLines()
        
        drawGhosts()
        
    }
    

    func drawLines() {
        for l in lines {
            mapView.addOverlay(l)
        }
    }
    
    func drawGhosts() {
        for g in ghosts {
            mapView.addAnnotation(g)
        }
    }
    

    
    func centerMapOnLocation(location: CLLocation, region: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: region, longitudinalMeters: region)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func getData() {
        let url = Bundle.main.url(forResource: "secretmessage", withExtension: "json")!
        let jsonData = try! Data(contentsOf: url)
        
        if let mData = try? JSONDecoder().decode(MapData.self, from: jsonData) {
            // Update the UI
            self.p = mData.polylines
            self.a = mData.annotations
        }
        
        
        
        for line:Polyline in p{
            
            var c = [CLLocationCoordinate2D]()
            
            for co in line.coords {
                
                let x = CLLocationCoordinate2D(latitude: co.lat, longitude: co.long)
                c.append(x)
            }
            
            let m = MKPolyline(coordinates: c, count: line.coords.count)
            
            lines.append(m)
        
        }
        
        for place:Annotation in a{
            let g = MKPointAnnotation()
            
            g.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.long)
            
            ghosts.append(g)
        }
    }
}



extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.lineWidth = 10
        renderer.strokeColor = UIColor.orange
        
        
        return renderer
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "ghostIdentifier"
        var av: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            av = dequeuedAnnotationView
            av?.annotation = annotation
        } else {
            av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let av = av {
            // Configure the look and behavior of the annotationView
            // This is where you set up the image & callout
            
            av.image = UIImage(named: "ghost.png")
            let l = UILabel()
            l.text = "BOO!"
            av.canShowCallout = true
            av.detailCalloutAccessoryView = l
        }
        
        return av
    }
}

