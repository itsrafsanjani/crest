import Foundation
import CoreLocation
import Observation
import Adhan

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var latitude: Double?
    private(set) var longitude: Double?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var coordinates: Coordinates? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return Coordinates(latitude: lat, longitude: lon)
    }

    var statusDescription: String {
        switch authorizationStatus {
        case .authorizedAlways: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus
        loadCachedCoordinates()
    }

    func requestLocation() {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedAlways {
            manager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        cacheCoordinates()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fall back to cached coordinates silently
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    // MARK: - Cache

    private func cacheCoordinates() {
        guard let lat = latitude, let lon = longitude else { return }
        UserDefaults.standard.set(lat, forKey: AppSettingsKey.cachedLatitude)
        UserDefaults.standard.set(lon, forKey: AppSettingsKey.cachedLongitude)
    }

    private func loadCachedCoordinates() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: AppSettingsKey.cachedLatitude) != nil {
            latitude = defaults.double(forKey: AppSettingsKey.cachedLatitude)
            longitude = defaults.double(forKey: AppSettingsKey.cachedLongitude)
        }
    }
}
