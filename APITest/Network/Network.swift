//
//  Network.swift
//  APITest
//
//  Created by Juan Olivera on 20/12/23.
//

import Foundation

enum NetworkError: Error {
  case invalidURL
  case notFound
  case internalError
  case unauthorized
  case forbidden
  case badRequest
  case unknown
}

enum HttpMethod: Equatable {
  case get([URLQueryItem])
  case put(Data?)
  case post(Data?)
  case delete
  case head

  var name: String {
    switch self {
    case .get: return "GET"
    case .put: return "PUT"
    case .post: return "POST"
    case .delete: return "DELETE"
    case .head: return "HEAD"
    }
  }
}

struct Request<Response> {
  let url: String
  let method: HttpMethod
  let body: [String: String]? = nil
  var needsAuthorization: Bool
}

extension Request {
  var urlRequest: URLRequest {
    get throws {
      guard let urlObject = URL(string: url) else {
        throw NetworkError.invalidURL
      }

      var request = URLRequest(url: urlObject)

      switch method {
      case .post(let data), .put(let data):
        request.httpBody = data
      case let .get(queryItems):
        var components = URLComponents(url: urlObject, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        guard let url = components?.url else {
          throw NetworkError.invalidURL
        }
        request = URLRequest(url: url)
      default:
        break
      }

      //If the endpoint needs authorization, setting the needsAuthorization flag to true will add the token to the header which will need to be previously stored
      if needsAuthorization {
        var headers: [String: String] = [:]
        headers.updateValue("Bearer [token]", forKey: "Authorization")
        request.allHTTPHeaderFields = headers
      }

      request.httpMethod = method.name
      return request
    }
  }
}

extension URLSession {
  func decode<Value: Decodable>(_ request: Request<Value>, 
                                using decoder: JSONDecoder = .init()) async throws -> Value {
    let decoded = Task.detached(priority: .userInitiated) {
      let (data, response) = try await self.data(for: request.urlRequest)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.unknown
      }

      switch httpResponse.statusCode {
      case 400:
        throw NetworkError.badRequest
      case 401:
        throw NetworkError.unauthorized
      case 403:
        throw NetworkError.forbidden
      case 404:
        throw NetworkError.notFound
      case 500...511:
        throw NetworkError.internalError
      default:
        break
      }

      try Task.checkCancellation()
      return try decoder.decode(Value.self, from: data)
    }
    return try await decoded.value
  }
}
