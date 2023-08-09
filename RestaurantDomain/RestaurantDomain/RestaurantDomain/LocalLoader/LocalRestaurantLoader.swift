//

import Foundation

public protocol CacheClient {
	func save(_ restaurants: [RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void)
	func delete(completion: @escaping (Error?) -> Void)
}

public final class LocalRestaurantLoader {
	private let cacheClient: CacheClient
	private let currentDate: () -> Date

	public init(cacheClient: CacheClient, currentDate: @escaping () -> Date) {
		self.cacheClient = cacheClient
		self.currentDate = currentDate
	}

	public func save(_ restaurants: [RestaurantItem], completion: @escaping (Error?) -> Void) {
		cacheClient.delete { [weak self] error in
			guard let error = error else {
				self?.saveOnCache(restaurants, completion: completion)
				return
			}
			completion(error)
		}
	}

	private func saveOnCache(_ restaurants: [RestaurantItem], completion: @escaping (Error?) -> Void) {
		cacheClient.save(restaurants, timestamp: currentDate()) { [weak self] error in
			guard self != nil else {
				return
			}
			completion(error)
		}
	}
}
