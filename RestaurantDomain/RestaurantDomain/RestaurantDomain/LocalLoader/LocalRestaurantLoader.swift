//

import Foundation

protocol CacheClient {
	func save(_ restaurants: [RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void)
	func delete(completion: @escaping (Error?) -> Void)
}

final class LocalRestaurantLoader {
	let cacheClient: CacheClient
	let currentDate: () -> Date

	init(cacheClient: CacheClient, currentDate: @escaping () -> Date) {
		self.cacheClient = cacheClient
		self.currentDate = currentDate
	}

	func save(_ restaurants: [RestaurantItem], completion: @escaping (Error?) -> Void) {
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
