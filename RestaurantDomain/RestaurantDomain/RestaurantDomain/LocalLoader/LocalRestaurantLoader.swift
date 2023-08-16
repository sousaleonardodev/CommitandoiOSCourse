//

import Foundation

public enum LoadResultState {
	case empty
	case success(items: [RestaurantItem], timestamp: Date)
	case failure(error: Error)
}

public final class LocalRestaurantLoader {
	private let cacheClient: CacheClient
	private let currentDate: () -> Date
	private let cachePolice: CachePolice

	public init(
		cacheClient: CacheClient,
		cachePolice: CachePolice = RestaurantCachePolice(),
		currentDate: @escaping () -> Date
	) {
		self.cacheClient = cacheClient
		self.currentDate = currentDate
		self.cachePolice = cachePolice
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
			validateCache(state: state)

			switch state {
			case let .success(items, timestamp) where self.cachePolice.validate(timestamp: timestamp, currentDate: currentDate()):
				completion(.success(items))
			case .success, .empty:
				completion(.success([]))
			case let .failure(error):
				completion(.failure(.invalidData))
			}
		}
	}

	private func validateCache(state: LoadResultState) {
		switch state {
		case .success(_, let timestamp) where !cachePolice.validate(timestamp: timestamp, currentDate: currentDate()):
			cacheClient.delete{ _ in }
		case .failure:
			cacheClient.delete{ _ in }
		default: break
		}
	}
}
