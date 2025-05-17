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
    var busStops: [BusStop] // ⬅️ Tambahin ini

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.isRotateEnabled = false
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update region jika berubah
        if !region.equals(to: uiView.region) {
            uiView.setRegion(region, animated: true)
        }

        // 🔄 Hapus semua overlay & anotasi lama
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        // 🔁 Tambahin polyline & marker halte
        uiView.addOverlays(polylines)
        for stop in busStops {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
            annotation.title = stop.name
            uiView.addAnnotation(annotation)
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
            parent.region = mapView.regionAsCoordinateRegion()
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "BusStopAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemGreen
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    }
}

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
