//

import Foundation

public protocol CacheClient {
	typealias CacheCompletion = (Error?) -> Void
	typealias LoadCompletion = (LoadResultState) -> Void

	func save(_ restaurants: [RestaurantItem], timestamp: Date, completion: @escaping CacheCompletion)
	func delete(completion: @escaping CacheCompletion)
	func load(completion: @escaping LoadCompletion)
}

final class CacheService: CacheClient {
	private let managerURL: URL
	private struct Cache: Codable {
		let restaurants: [RestaurantItem]
		let timestamp: Date
	}

	init(managerURL: URL) {
		self.managerURL = managerURL
	}

	func save(_ restaurants: [RestaurantItem], timestamp: Date, completion: @escaping CacheCompletion) {
		let cache = Cache(restaurants: restaurants, timestamp: timestamp)
		let encoder = JSONEncoder()

		do {
			let encoded = try encoder.encode(cache)
			try encoded.write(to: managerURL)

			completion(nil)
		} catch {
			completion(error)
		}
	}

	func delete(completion: @escaping CacheCompletion) {
		guard FileManager.default.fileExists(atPath: managerURL.path) else {
			completion(nil)
			return
		}
		
		do {
			try FileManager.default.removeItem(at: managerURL)

			completion(nil)
		} catch {
			completion(error)
		}
	}

	func load(completion: @escaping LoadCompletion) {
		guard let data = try? Data(contentsOf: managerURL) else {
			completion(.empty)
			return
		}

		do {
			let decoder = JSONDecoder()
			let cache = try decoder.decode(Cache.self, from: data)
			completion(.success(items: cache.restaurants, timestamp: cache.timestamp))
		} catch {
			completion(.failure(error: error))
		}
	}
}
