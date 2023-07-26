//

import Foundation

enum NetworkState {
	case success
	case error(Error)
}

protocol NetworkClient {
	func request(from url: URL, completion: @escaping (NetworkState) -> Void)
}

final class RemoteRestaurantLoader {
	let url: URL
	let network: NetworkClient

	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.network = networkClient
	}
	
	func load(completion: @escaping (RemoteRestaurantLoader.Error) -> Void) {
		network.request(from: url) { state in
			switch state {
			case .error:
				completion(.connectivity)
			default:
				completion(.invalidData)
			}
		}
	}
}
