//

import Foundation

public final class RemoteRestaurantLoader: RestaurantLoader {
	let url: URL
	let network: NetworkClient
	private let okResponse = 200

	public init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.network = networkClient
	}

	public func load(completion: @escaping (RestaurantResult) -> Void) {
		let okResponse = okResponse
		
		network.request(from: url) { [weak self] result in
			guard let self = self else {
				return
			}

			switch result {
			case let .success((data, response)):
				completion(self.successfullValidation(data: data, response: response))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}

	private func successfullValidation(data: Data, response: HTTPURLResponse) -> RestaurantResult {
		guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data),
			  response.statusCode == okResponse else {
			return .failure(.invalidData)
		}

		return .success(json.items)
	}
}
