//

import Foundation

public protocol CacheClient {
	typealias CacheCompletion = (Error?) -> Void
	typealias GetCompletion = (Error?) -> Void

	func save(_ restaurants: [RestaurantItem], timestamp: Date, completion: @escaping CacheCompletion)
	func delete(completion: @escaping CacheCompletion)
	func load(completion: @escaping GetCompletion)
}

public extension CacheClient {
	func load(completion: @escaping GetCompletion) {}
	func save(_ restaurants: [RestaurantItem], timestamp: Date, completion: @escaping CacheCompletion) {}
	func delete(completion: @escaping CacheCompletion) {}
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

extension LocalRestaurantLoader: RestaurantLoader {
	public func load(completion: @escaping (RestaurantResult) -> Void) {
		cacheClient.load { error in
			guard error == nil else {
				completion(.failure(.invalidData))
				return
			}

			completion(.success([RestaurantItem]()))
		}
	}
}
