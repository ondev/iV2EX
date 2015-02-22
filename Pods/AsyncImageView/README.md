Purpose
--------------

AsyncImageView includes both a simple category on UIImageView for loading and displaying images asynchronously on iOS so that they do not lock up the UI, and a UIImageView subclass for more advanced features. AsyncImageView works with URLs so it can be used with either local or remote files.

Loaded/downloaded images are cached in memory and are automatically cleaned up in the event of a memory warning. The AsyncImageView operates independently of the UIImage cache, but by default any images located in the root of the application bundle will be stored in the UIImage cache instead, avoiding any duplication of cached images.

The library can also be used to load and cache images independently of a UIImageView as it provides direct access to the underlying loading and caching classes.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 7.1 (Xcode 5.1, Apple LLVM compiler 5.1)
* Earliest supported deployment target - iOS 5.0
* Earliest compatible deployment target - iOS 4.3

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

As of version 1.5, AsyncImageView requires ARC. If you wish to use AsyncImageView in a non-ARC project, just add the -fobjc-arc compiler flag to the AsyncImageView.m file. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click AsyncImageView.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in AsyncImageView.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including AsyncImageView.m) are checked.


Thread Safety
--------------

AsyncImageView uses threading internally, but none of the AsyncImageView external interfaces are thread safe, and you should not call any methods or set any properties on any of the AsyncImageView classes except on the main thread.


Installation
--------------

To use the AsyncImageView in an app, just drag the AsyncImageView class files into your project.


Categories
------------

The basic interface of AsyncImageView is a category that extends UIImageView with the following property:

    @property (nonatomic, strong) NSURL *imageURL;
    
Upon setting this property, AsyncImageView will begin loading/downloading the specified image on a background thread. Once the image file has loaded, the UIImageView's image property will be set to the resultant image. If you set this property again while the previous image is still loading then the images will be queued for loading in the order in which they were set.

This means that you can, for example, set a UIImageView to load a small thumbnail image and then immediately set it to load a larger image and the thumbnail image will still be loaded and set before the larger image loads.

If you access this property it will return the most recent image URL set for the UIImageView, which may not be the next one to be loaded if several image URLs have been queued on that image view. If you wish to cancel the previously loading image, use the `-cancelLoadingURL:target:` method on the AsyncImageLoader class, passing the UIImageView instance as the target (see below).


Classes
------------

AsyncImageView includes an AsyncImageView class, which is a subclass of UIImageView. This implements some useful features on top of the UIImageView category, including the automatic display of a loading spinner, and a nice crossfade effect when the image loads.

AsyncImageView also provides an AsyncImageLoader class for advanced users. AsyncImageLoader manages the loading/downloading and queueing of image requests. Set properties of the shared loader instance to control loading behaviour, or call its loading methods directly to preload images off-screen.


AsyncImageView properties
-------------------------

The AsyncImageView class has the following properties:

    @property (nonatomic, assign) BOOL showActivityIndicator;
    
If YES, the AsyncImageView will display a loading spinner when the imageURL is set. This will automatically hide once the image has loaded. Note that this value should bet set *before* setting the imageURL. Setting this value when loading is already in progress will have no effect. Defaults to YES.

    @property (nonatomic, assign) UIActivityIndicatorViewStyle activityIndicatorStyle;
    
The style that will be used for the UIActivityIndicator (if enabled). Note that this value should bet set *before* setting the imageURL. Setting this value when loading is already in progress will cause the spinner to  disappear.
    
    @property (nonatomic, assign) NSTimeInterval crossfadeDuration;

The crossfade animation duration, in seconds. If value is greater than 0, the image will crossfade in once it loads instead of appearing suddenly. Defaults to 0.4.


AsyncImageLoader notifications
-------------------------------

The AsyncImageLoader can generate the following notifications:

    AsyncImageLoadDidFinish
    
This fires when an image has been loaded. The notification object contains the target object that loaded the image file (e.g. the UIImageView) and the userInfo dictionary contains the following keys:

- AsyncImageImageKey

The UIImage that was loaded.

- AsyncImageURLKey

The NSURL that the image was loaded from.

- AsyncImageCacheKey

The NSCache that the image was stored in.

    AsyncImageLoadDidFail
    
This fires when an image did not load due to an error. The notification object contains the target object that attempted to load the image file (e.g. the UIImageView) and the userInfo dictionary contains the following keys:

- AsyncImageErrorKey

The NSError generated by the underlying URLConnection.

- AsyncImageURLKey

The NSURL that the image failed to load from.


AsyncImageLoader properties
----------------------------

AsyncImageLoader has the following properties:

    @property (nonatomic, strong) NSCache *cache;

The cache to be used for image load requests. You can change this value at any time and it will affect all subsequent load requests until it is changed again. By default this is set to `[AsyncImageLoader sharedCache]`. Set this to nil to disable caching completely, or you can set it to a new NSCache instance or subclass for fine-grained cache control.

    @property (nonatomic, assign) NSUInteger concurrentLoads;

The number of images to load concurrently. Images are loaded on background threads but loading too many concurrently can choke the CPU. This defaults to 2;
    
    @property (nonatomic, assign) NSTimeInterval loadingTimeout;

The loading timeout, in seconds. This defaults to 60, which should be more than enough for loading locally stored images, but may be too short for downloading large images over 3G.


AsyncImageLoader methods
-------------------------

AsyncImageLoader has the following methods:

    - (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure;
    
This queues an image for download. If the queue is empty and the image is already in cache, this will trigger the success action immediately.

The target is retained by the AsyncImageLoader, however the loader will monitor to see if the target is being retained by any other objects, and will release it and terminate the file load if it is not. The target can be nil, in which case the load will still happen as normal and can completion can be detected using the `AsyncImageLoadDidFinish` and `AsyncImageLoadDidFail` notifications. 
    
    - (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action;
    
Works the same as above, except the action will only be called if the loading is successful. Failure can still be detected using the `AsyncImageLoadDidFail` notification.

    - (void)loadImageWithURL:(NSURL *)URL;
    
Works the same as above, but no target or actions are specified. Use `AsyncImageLoadDidFinish` and `AsyncImageLoadDidFail` to detect when the loading is complete.
    
    - (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action;
    
This cancels loading the image with the specified URL for the specified target and action.
    
    - (void)cancelLoadingURL:(NSURL *)URL target:(id)target;
    
This cancels loading the image with the specified URL for any actions on the specified target;
    
    - (void)cancelLoadingURL:(NSURL *)URL;
    
This cancels loading the image with the specified URL.

    - (void)cancelLoadingImagesForTarget:(id)target action:(SEL)action;
    
This cancels loading all queued image URLs with the specified action on the specified target;
    
    - (void)cancelLoadingImagesForTarget:(id)target;
    
This cancels loading all queued image URLs for the specified target;
    
    - (NSURL *)URLForTarget:(id)target action:(SEL)action;
    
This returns the most recent image URL set for the given target and action, which may not be the next one to be loaded if several image URLs have been queued on that target.

    - (NSURL *)URLForTarget:(id)target;

This returns the most recent image URL set for the given target, which may not be the next one to be loaded if several image URLs have been queued on that target.


Usage
--------

You can use the AsyncImageView class exactly as you would use a UIImageView. If you want to use it in Interface Builder, drag a regular UImageView or media image into your view as normal, then change its class to AsyncImageView in the inspector.

For cases where you cannot use an AsyncImageView, such as the embedded imageView of a UIButton or UITableView, the UIImageView category means that you can still set the imageURL property on the imageView to load the image in the background. You will not get the advanced features of the AsyncImageView class this way however (such as the loading spinner), unless you re-implement them yourself.

To load or download an image, simply set the imageURL property to the URL of the desired image. This can be a remote URL or a local fileURL that points to the application's bundle or documents folder.

If you want to display a placeholder image in the meantime, just manually set the image property of the UIImageView to your placeholder image and it will be overwritten once the image specified by the URL has loaded.

If you want to asynchronously load a smaller thumbnail image while the main image loads, just set the thumbnail URL first, then the full image URL. AsyncImageLoader will ensure that the images are loaded in the correct order. If the larger image is already cached, or loads first for some reason, the thumbnail image loading will be cancelled.

To detect when the image has finished loading, you can use NSNotificationCenter in conjunction with the `AsyncImageLoadDidFinish` notification, or you can use KVO (Key-Value Observation) to set up an observer on the UIImageView's image property. When the image has finished loading, the image will be set, and with KVO you can detect this and react accordingly.

By default, all loaded images are cached, and if the app loads a large number of images, the cache will keep building up until a memory warning is triggered. You can avoid memory warnings by manually removing items from the cache according to your own maintenance logic. You can also disable caching either universally or for specific images by setting the shared AsyncImageLoader's cache property to `nil` before loading an image (set it back to `[AsyncImageLoader sharedInstance]` to re-enable caching afterwards).


Release Notes
----------------

Version 1.5.1

- Fixed accidental recursion
- Fixed mismatched selector

Version 1.5

- Now works correctly on ARM64
- Now requires ARC (see README for details)
- Loaded images are now decompressed prior to drawing to avoid stutter
- Spinner no longer shows if nil URL is set
- Removed redundant crossfadeImages property
- Now conforms to -Weverything warning level
- Added podspec

Version 1.4

- Loading queue is now LIFO (Last-In, First-Out) for better performance
- Removed AsyncImageCache class (replaced with ordinary NSCache)
- Fixed some bugs when checking for duplicate items in UIImage cache
- AsyncImageView no longer requires QuartzCore framework

Version 1.3

- Added additional effects options to AsyncImageView
- Added additional AsyncImageLoader methods
- Fixed broken example
- Added Effects example
- AsyncImageView now fades in the first time image is set
- Fixed memory leak in AsyncImageView
- Update ARC Helper
- Added new AsyncImageView class with loading spinner and crossfade effect.
- Fixed crash when setting a nil imageURL.
- Fixed crash when image fails to load.
- Now requires the QuartzCore framework.
- Now requires iOS 4.x

Version 1.2.3

- Improved queuing behaviour so cached images aren't blocked from appearing by slow loading images in the queue.
- Added example project.

Version 1.2.2

- Fixed crash when accessing imageURL that has already been released.
- Fixed some thread concurrency issues

Version 1.2.1

- Fixed crash when attempting to load a corrupt image, or a URL that isn't a valid image file.

Version 1.2

- Images are now automatically decompressed on a background thread after loading before being displayed. This reduces stuttering when displaying the images in a scrolling view such as a UITableView or carousel.
- Images located in the root of the application bundle will now be stored in the UIImage imageNamed cache instead of in the AsyncImageCache by default. This avoids duplication of images loaded via different mechanisms.
- It is now possible to disable caching, or use multiple different caches for different images.

Version 1.1

- AsyncImageView is now a category on UIImageView instead of a standalone class, making it easier to use with existing code or classes.
- Now uses asynchronous NSURLConnections for loading, allowing image loading to be cancelled partway through.
- Loaded images are now cached in memory, and de-duplication is handled automatically.
- Added public AsyncImageCache and AsyncImageLoader classes, for fine-grained control over loading and caching.

Version 1.0

- Initial release