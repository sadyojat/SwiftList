//
//  PostsFeed.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//


import OrderedCollections
import Combine
import Foundation


class PostFeed: ObservableObject {

    static let shared = PostFeed()

    private init() {}

    @Published var postMap = OrderedDictionary<Post.ID, Post>()
}
