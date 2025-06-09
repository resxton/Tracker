import Foundation

enum TrackerType {
    case habit
    case irregularEvent
    
    var createTitle: String {
        switch self {
        case .habit:
            return "Новая привычка"
        case .irregularEvent:
            return "Новое нерегулярное событие"
        }
    }
    
    var normalTitle: String {
        switch self {
        case .habit:
            return "Привычка"
        case .irregularEvent:
            return "Нерегулярное событие"
        }
    }
    
    var editTitle: String {
        switch self {
        case .habit:
            return "Редактировать привычку"
        case .irregularEvent:
            return "Редактировать нерегулярное событие"
        }
    }
}
