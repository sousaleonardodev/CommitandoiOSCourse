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

	private var completionDeleteHandler: ((Error?) -> Void)?
	func completionHandleForDelete(error: Error? = nil) {
		completionDeleteHandler?(error)
	}

	private var completionSaveHandler: ((Error?) -> Void)?
	func completionHandlerForSave(error: Error? = nil) {
		completionSaveHandler?(error)
	}

	private var completionLoaderHandler: ((Error?) -> Void)?
	func completionHandlerForLoad(error: Error? = nil) {
		completionLoaderHandler?(error)
	}

	func load(completion: @escaping GetCompletion) {
		calledMethods.append(.load)
		completionLoaderHandler = completion
	}
}
