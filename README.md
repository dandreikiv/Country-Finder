Country-Finder
==============
The application built by using [iOS KML Framework] (http://kmlframework.com) to simplify development.

I was also using CocoaPods to add the framework.

As the KML file might be huge I decided to use  GCD to perform parsing in background thread and when it is done to update UI.