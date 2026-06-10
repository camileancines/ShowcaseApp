//
//  LocationManager.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import CoreLocation
import Combine
import MapKit

@MainActor
final class LocationManager: NSObject, ObservableObject {

    @Published private(set) var countryCode: String = LocationManager.localeFallback

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    static var localeFallback: String {
        Locale.current.region?.identifier.lowercased() ?? "us"
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced // país basta
    }

    func refreshRegion() async {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            return // o callback de mudança de status reinicia o fluxo
        case .restricted, .denied:
            countryCode = Self.localeFallback // degradação graciosa
            return
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            countryCode = Self.localeFallback
            return
        }

        do {
            let location = try await requestLocation()
            countryCode = await isoCountry(from: location) ?? Self.localeFallback
        } catch {
            countryCode = Self.localeFallback
        }
    }

    private func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
    
    private func isoCountry(from location: CLLocation) async -> String? {
        guard let request = MKReverseGeocodingRequest(location: location) else { return nil }
        do {
            let mapItems = try await request.mapItems
            guard let name = mapItems.first?.addressRepresentations?.regionName else { return nil }
            return Self.isoCode(forCountryName: name)
        } catch {
            return nil
        }
    }
    
    // nome localizado do país -> código ISO, via Locale
    private static func isoCode(forCountryName name: String) -> String? {
        let locale = Locale.current
        return Locale.Region.isoRegions.first {
            locale.localizedString(forRegionCode: $0.identifier)?
                .caseInsensitiveCompare(name) == .orderedSame
        }?.identifier.lowercased()
    }

    private func resume(with result: Result<CLLocation, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in self.resume(with: .success(location)) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in self.resume(with: .failure(error)) }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in await self.refreshRegion() }
    }
}
