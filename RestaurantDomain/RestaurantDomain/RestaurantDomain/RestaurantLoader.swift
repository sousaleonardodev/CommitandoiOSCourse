//

import Foundation

public enum RestaurantResultError: Error {
	case connectivity
	case invalidData
}

public protocol RestaurantLoader {
	typealias RestaurantResult = Result<[RestaurantItem], RestaurantResultError>
	func load(completion: @escaping (RestaurantResult) -> Void)
}
