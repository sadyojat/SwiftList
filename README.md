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

