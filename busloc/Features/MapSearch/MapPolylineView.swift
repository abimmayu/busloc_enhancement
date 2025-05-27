//
//  MapPolylineView.swift
//  busloc
//
//  Created by Abim on 17/05/25.
//

import SwiftUI
import MapKit

struct MapPolylineView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var polylines: [MKPolyline]
//    var routeBusPolylines: [MKPolyline]
    var walkingPolylines: [MKPolyline]
    var busStops: [BusStop]
    var userStartCoordinate: CLLocationCoordinate2D?
    var userDestinationCoordinate: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.isRotateEnabled = false
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if !region.equals(to: uiView.region) {
            uiView.setRegion(region, animated: true)
        }

        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addOverlays(walkingPolylines)
        uiView.addOverlays(polylines)

        for stop in busStops {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
            annotation.title = stop.name
            uiView.addAnnotation(annotation)
        }

        if let start = userStartCoordinate {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = start
            startAnnotation.title = "Start Point"
            uiView.addAnnotation(startAnnotation)
        }

        if let end = userDestinationCoordinate {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = end
            endAnnotation.title = "Destination"
            uiView.addAnnotation(endAnnotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapPolylineView

        init(parent: MapPolylineView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.region = mapView.regionAsCoordinateRegion()
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
            }

            let renderer = MKPolylineRenderer(polyline: polyline)

            switch polyline.title {
            case "walking":
                renderer.strokeColor = UIColor.systemGray
                renderer.lineWidth = 2
                renderer.lineDashPattern = [6, 6]
            case "bus":
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 6
                renderer.lineDashPattern = nil
            default:
                renderer.strokeColor = UIColor.black
                renderer.lineWidth = 3
            }

            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "PinAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            if let title = annotation.title ?? "" {
                switch title {
                case "Start Point":
                    (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemRed
                case "Destination":
                    (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemBlue
                default:
                    (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemGreen
                }
            }

            return annotationView
        }
    }
}

// MARK: - Helpers
extension MKCoordinateRegion {
    func equals(to other: MKCoordinateRegion, threshold: Double = 0.0001) -> Bool {
        abs(center.latitude - other.center.latitude) < threshold &&
        abs(center.longitude - other.center.longitude) < threshold &&
        abs(span.latitudeDelta - other.span.latitudeDelta) < threshold &&
        abs(span.longitudeDelta - other.span.longitudeDelta) < threshold
    }
}

extension MKMapView {
    func regionAsCoordinateRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: centerCoordinate, span: region.span)
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }

    static func walkingPolyline(from coords: [CLLocationCoordinate2D]) -> MKPolyline {
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        polyline.title = "walking"
        return polyline
    }

    static func busPolyline(from coords: [CLLocationCoordinate2D]) -> MKPolyline {
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        polyline.title = "bus"
        return polyline
    }
}
