# SwiftList : How to build lists using combine and diffable data source

## Overview
This demo app showcases how to use combine pub-sub features to dynamically load data into a table view that has a diffable data source. In this example, the app loads the response of an api, performs JSONDecode and then sets the resulting array into a data store object. 

For purposes of this demo app, the data store object is invoked as a singleton, however dependency injection is a more preferred format in production grade apps.

```
class PostFeed: ObservableObject {
    static let shared = PostFeed()
    private init() {}
    @Published var posts = [Post]()
}
```

Since the data store conforms to `ObservableObject` and the mutating property is marked with a `@Published` property wrapper, the property can be observed and changes published into a subscriber. Checkout the code in `PostViewController::setupSubscriptions` function to understand how this is done. 

While using Combine its important that the developer focuses on some sanity checks while writing code.
1. Be cognizant of the fact that if a UI refresh is needed as a result of the incoming data stream, receive the published stream on `Runloop.main` or `DispatchQueue.main`
2. If an item in the array is getting modified, and content is modified, then use the `reconfigureItems` api on snapshots rather than `reloadItems`
3. ItemIdentifier is not the object instance, but is used to indicate the type that represents a stable identity of the object instance. Generally we conform data entities to Identifiable, in which case a unique id key is required. Use that.  


## Video

https://user-images.githubusercontent.com/5061719/220075518-18384d79-efdd-4332-b093-371b0a0fef05.mov


---


## Optimization
Apple's WWDC examples that use combine use an array to download the list of objects and then use the objectId as an item identifier. This can be a bit of a performance drag, since in the diffable data source, you'd then need to do a linear search in the list of objects to extract the modified object. 

A good optimization to this is to use a `OrderedDictionary`. This will however need your project to import the [swift-collections](https://github.com/apple/swift-collections) package.

> While using `OrderedDictionary` you have to pay attention to the key thats used, it is important that the key following all the guidelines of good hashing, else it could lead to collisions, in which case lookups default to linear searches thereby taking away to benefits of using the OrderedDictionary object. 

An example of how this data structure could be used in combine is implemented in this [commit](https://github.com/sadyojat/SwiftList/commit/b8fbb2e7a5b6dfdf8bfa498f68016bff4b4d1517#diff-78f628a934988156096af1ffee798cd4e6cb89ff31bdffb4f8df76e731e42aa2). Here I also explore some nuance of when to receive on `RunLoop.main` vs `DispatchQueue.main`, and using appropriate item identifiers. 


---


## Asynchronous asset downloads

Images are generally downloaded asynchronously. We can leverage the power of swift concurrency and diffable data sources to do targeted download and reconfigure specific items in the data source. To see this behavior in action refer to this [commit](https://github.com/sadyojat/SwiftList/commit/1f60b53aaa7d8c1711af8b20b06f57f6fd2534cd#diff-66d6bb6a602212a604e22af08c0779613de7c376a7b88a88d34122e4127d87c9)


https://user-images.githubusercontent.com/5061719/220228178-f6746ef0-8e49-4bc3-93b3-4e9a078ed528.mov

