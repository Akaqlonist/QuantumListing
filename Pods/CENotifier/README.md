# CENotifier

Add in-app ambient notifications with growl-like alerts.

## Screenshot

!["screenshot"](https://raw.github.com/jazzychad/CENotifier/master/cenotifierscreenshot.png)

## Video

Demo video at [http://youtu.be/Ee7aiKoDaGg](http://youtu.be/Ee7aiKoDaGg)

## Installation

####Using cocoapods:

Follow these steps in order to use the CENotifier within your own Xcode 5+ project using CocoaPods. This is the easiest installation method if you are familiar with CocoaPods.

* Ensure that your Podfile is targeting :ios and "5.0" at minimum
* Add a line containing `pod 'CENotifier', '~> 0.1'` to your Podfile.
* Run `pod install` in the Terminal.
* Add `#import <CENotifier/CENotifier.h>` to the file(s) you want

####If you prefer to clone the repo:

Clone this repo and add the CENotifier.h/m and CENotifyView.h/m files
to your project. These classes also depend on
[SDWebImage](https://github.com/rs/SDWebImage), so follow the
instructions there for installation if you don't already have it as
part of your project.

## How To Use

Mostly you will interact with the `CENotifier` static methods to
display notification in your app.

```objective-c
+ (void)displayInView:(UIView *)v 
             imageurl:(NSString *)imageurl
                title:(NSString *)title 
                 text:(NSString *)text
             duration:(NSTimeInterval)duration 
             userInfo:(NSDictionary *)userInfo
             delegate:(id <CENotifyViewDelegate>)delegate;


+ (void)displayInView:(UIView *)v 
                image:(UIImage *)image
                title:(NSString *)title 
                 text:(NSString *)text
             duration:(NSTimeInterval)duration 
             userInfo:(NSDictionary *)userInfo
             delegate:(id <CENotifyViewDelegate>)delegate;

```

`CENotifier` will take care of queueing up the notifications and only
displaying them if they will fit on the screen without overlapping
with other notification views already being displayed.

Tapping on the main part of a notification view will dismiss the view
immediately and send a delegate message to let you know the view was
tapped.

If the user taps the image part of the notification, it acts as a
"cancel" action and a separate delegate message is sent in that case.

## Demo Project

The demo project uses SDWebImage as a git submodule. After you `git
clone` this repo, do the following:

```bash
git submodule init
git submodule update
```

This will clone SDWebImage into the project, and from there you should
be able to compile the demo project.

