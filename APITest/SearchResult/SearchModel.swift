//
//  SearchModel.swift
//  APITest
//
//  Created by Juan Olivera on 20/12/23.
//

import Foundation

struct SearchModel: Codable {
  let login: String
  let avatarUrl: String
  let bio: String
  
  enum CodingKeys: String, CodingKey {
    case login, bio
    case avatarUrl = "avatar_url"
  }
}
