//

import Foundation
import RestaurantDomain

final class CacheClientSpy: CacheClient {
	enum Method: Equatable {
		case save(items: [RestaurantItem], timestamp: Date)
		case delete
		case load
	}

	private(set) var calledMethods: [Method] = []

	func save(
		_ restaurants: [RestaurantDomain.RestaurantItem],
		timestamp: Date,
		completion: @escaping (Error?) -> Void
	) {
		completionSaveHandler = completion
		calledMethods.append(.save(items: restaurants, timestamp: timestamp))
	}

	func delete(completion: @escaping (Error?) -> Void) {
		completionDeleteHandler = completion
		calledMethods.append(.delete)
	}

	private var completionDeleteHandler: CacheCompletion?
	func completionHandleForDelete(error: Error? = nil) {
		completionDeleteHandler?(error)
	}

	private var completionSaveHandler: CacheCompletion?
	func completionHandlerForSave(error: Error? = nil) {
		completionSaveHandler?(error)
	}

	private var completionLoaderHandler: LoadCompletion?
	func completionHandlerForLoad(state: LoadResultState) {
		completionLoaderHandler?(state)
	}

	func load(completion: @escaping LoadCompletion) {
		calledMethods.append(.load)
		completionLoaderHandler = completion
	}
}
