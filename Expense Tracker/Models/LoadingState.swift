enum LoadingState: Equatable {
    case loading
    case error(String)
    case data
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}
