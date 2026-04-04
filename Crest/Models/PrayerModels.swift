import Foundation
import Adhan

enum Prayer: String, CaseIterable, Identifiable {
    case fajr
    case sunrise
    case dhuhr
    case asr
    case maghrib
    case isha

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fajr: return "Fajr"
        case .sunrise: return "Sunrise"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }

    var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }

    var transliteration: String { displayName }

    var systemImage: String {
        switch self {
        case .fajr: return "sun.horizon"
        case .sunrise: return "sunrise"
        case .dhuhr: return "sun.max"
        case .asr: return "sun.min"
        case .maghrib: return "sunset"
        case .isha: return "moon.stars"
        }
    }

    /// Prayers that have adjustable offsets and notification/overlay toggles (excludes sunrise)
    static var adjustable: [Prayer] {
        [.fajr, .dhuhr, .asr, .maghrib, .isha]
    }
}

struct PrayerTime: Identifiable {
    let prayer: Prayer
    let time: Date
    var id: String { prayer.rawValue }

    func isPast(relativeTo now: Date = Date()) -> Bool {
        time < now
    }
}

enum CalculationMethodOption: String, CaseIterable, Identifiable {
    case muslimWorldLeague
    case egyptian
    case karachi
    case ummAlQura
    case dubai
    case qatar
    case kuwait
    case moonsightingCommittee
    case singapore
    case turkey
    case tehran
    case northAmerica

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .muslimWorldLeague: return "Muslim World League"
        case .egyptian: return "Egyptian General Authority"
        case .karachi: return "University of Islamic Sciences, Karachi"
        case .ummAlQura: return "Umm al-Qura, Makkah"
        case .dubai: return "Dubai"
        case .qatar: return "Qatar"
        case .kuwait: return "Kuwait"
        case .moonsightingCommittee: return "Moonsighting Committee"
        case .singapore: return "Singapore / Malaysia / Indonesia"
        case .turkey: return "Turkey (Diyanet)"
        case .tehran: return "Institute of Geophysics, Tehran"
        case .northAmerica: return "ISNA (North America)"
        }
    }

    var adhanMethod: CalculationMethod {
        switch self {
        case .muslimWorldLeague: return .muslimWorldLeague
        case .egyptian: return .egyptian
        case .karachi: return .karachi
        case .ummAlQura: return .ummAlQura
        case .dubai: return .dubai
        case .qatar: return .qatar
        case .kuwait: return .kuwait
        case .moonsightingCommittee: return .moonsightingCommittee
        case .singapore: return .singapore
        case .turkey: return .turkey
        case .tehran: return .tehran
        case .northAmerica: return .northAmerica
        }
    }
}

enum MadhabOption: String, CaseIterable, Identifiable {
    case shafi
    case hanafi

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .shafi: return "Shafi'i / Maliki / Hanbali"
        case .hanafi: return "Hanafi"
        }
    }

    var adhanMadhab: Madhab {
        switch self {
        case .shafi: return .shafi
        case .hanafi: return .hanafi
        }
    }
}
