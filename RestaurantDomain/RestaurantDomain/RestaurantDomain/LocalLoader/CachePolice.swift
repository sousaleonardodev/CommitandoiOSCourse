//

import Foundation

public protocol CachePolice {
	func validate(timestamp: Date, currentDate: Date) -> Bool
}

public final class RestaurantCachePolice: CachePolice {
	private let maxAge: Int = 1

	public init() {}

	public func validate(timestamp: Date, currentDate: Date) -> Bool {
		let calendar = Calendar(identifier: .gregorian)

		guard let maxAge = calendar.date(byAdding: .day, value: 1, to: timestamp) else {
			return false
		}

		return currentDate < maxAge
	}
}
