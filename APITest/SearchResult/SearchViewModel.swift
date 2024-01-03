//
//  SearchViewModel.swift
//  APITest
//
//  Created by Juan Olivera on 20/12/23.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {

  @Published var userResult: SearchModel?
  private var tasks: [Task<Void, Never>] = []

  init() {
  }

  func getUser() {
    let task = Task {
      do {
        let request: Request<SearchModel> = .getUser(user: "sallen0400")
        userResult = try await URLSession.shared.decode(request)
      } catch NetworkError.notFound {
        print("User not found")
      } catch NetworkError.badRequest, NetworkError.invalidURL, NetworkError.internalError  {
        print("Service unavailable. please try again later")
      } catch NetworkError.forbidden, NetworkError.unauthorized {
        print("You don't have permissions to get this content")
      } catch {
        print("There was an unexpected error. Please try again later")
      }
    }
    tasks.append(task)
  }

  func cancelTasks() {
    tasks.forEach { $0.cancel() }
    tasks = []
  }

}

extension Request where Response == SearchModel {
  static func getUser(user: String) -> Self {
    Request(url: "https://api.github.com/users/\(user)",
            method: .get([]),
            needsAuthorization: false)
  }

  static func saveUser(user: String) -> Self {
    let fakeModel = SearchModel(login: "login", avatarUrl: "avatar_url", bio: "This is my bio.")
    let encoder = JSONEncoder()
    return Request(url: "https://api.github.com/users/\(user)",
                   method: .post(try! encoder.encode(fakeModel)),
                   needsAuthorization: true)
  }
}
