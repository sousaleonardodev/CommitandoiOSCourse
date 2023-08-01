//

import Foundation

public protocol NetworkClient {
	typealias NetworkResult = Result<(Data, HTTPURLResponse), Error>
	func request(from url: URL, completion: @escaping (NetworkResult) -> Void)
}

public final class RemoteRestaurantLoader {
	let url: URL
	let network: NetworkClient
	private let okResponse = 200

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.network = networkClient
	}

	public typealias RemoterestaurantResult = Result<[RestaurantItem], RemoteRestaurantLoader.Error>
	public func load(completion: @escaping (RemoterestaurantResult) -> Void) {
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

	private func successfullValidation(data: Data, response: HTTPURLResponse) -> RemoterestaurantResult {
		guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data),
			  response.statusCode == okResponse else {
			return .failure(.invalidData)
		}

		return .success(json.items)
	}
}
