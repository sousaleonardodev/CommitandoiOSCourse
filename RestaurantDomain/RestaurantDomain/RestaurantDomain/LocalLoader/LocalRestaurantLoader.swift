//

import Foundation

public enum LoadResultState {
	case empty
	case success(items: [RestaurantItem], timestamp: Date)
	case failure(error: Error)
}

public protocol CacheClient {
	typealias CacheCompletion = (Error?) -> Void
	typealias LoadCompletion = (LoadResultState) -> Void

	func save(_ restaurants: [RestaurantItem], timestamp: Date, completion: @escaping CacheCompletion)
	func delete(completion: @escaping CacheCompletion)
	func load(completion: @escaping LoadCompletion)
}

public extension CacheClient {
	func load(completion: @escaping LoadCompletion) {}
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
		cacheClient.load { [weak self] state in
			guard let self else {
				return
			}

			switch state {
			case let .failure(error):
				completion(.failure(.invalidData))
			case let .success(items, timestamp) where self.validate(timestamp: timestamp):
				completion(.success(items))
			case .success, .empty:
				completion(.success([]))
			}
		}
	}


	private func validate(timestamp: Date) -> Bool {
		let calendar = Calendar(identifier: .gregorian)

		guard let maxAge = calendar.date(byAdding: .day, value: 1, to: timestamp) else {
			return false
		}

		return currentDate() < maxAge
	}
}
