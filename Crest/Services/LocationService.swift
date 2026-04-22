import Foundation
import CoreLocation
import Observation
import Adhan
import AppKit

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

    var canRequestLiveLocation: Bool {
        authorizationStatus == .authorizedAlways
    }

    var needsSettingsAction: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    var permissionHelpText: String {
        switch authorizationStatus {
        case .denied:
            return "Location access is off. Enable Location Services for Crest in System Settings, then try again."
        case .restricted:
            return "Location access is restricted on this Mac. Update your privacy restrictions, then try again."
        case .notDetermined:
            return "Allow location access to calculate accurate prayer times, or use a static location below."
        default:
            return ""
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

    func openLocationPrivacySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") else {
            return
        }
        NSWorkspace.shared.open(url)
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
