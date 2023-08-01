//

import Foundation
import XCTest
import RestaurantDomain

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequests: [URL] = []
	private var completionHandler: ((NetworkResult) -> Void)?

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
		urlRequests.append(url)
		completionHandler = completion
	}

	func setupSuccessCompletion(statusCode: Int = 200, data: Data = Data()) throws {
		let response = try XCTUnwrap(HTTPURLResponse(url: urlRequests[0], statusCode: statusCode, httpVersion: nil, headerFields: nil))

		completionHandler?(.success((data, response)))
	}

	func setupFailureCompletion(error: Error = NetworkClientSpy.anyError()) {
		completionHandler?(.failure(error))
	}

	static private func anyError() -> Error {
		NSError(domain: "Any error", code: -1)
	}
}
