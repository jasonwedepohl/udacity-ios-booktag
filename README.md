# BookTag

The Booktag app is an iOS app that fulfils all the requirements of the final project of Udacity's iOS nanodegree. The final project is meant to demonstrate competence in user interface design, networking with a web API, persistence using Core Data and UserDefaults. The project is self-decided, and every Nanodegree student must come up with their own app idea and bear it to fruition. The specification for the app is located [here](https://docs.google.com/document/d/1CWsC1jszFEYX5EM3CE9sX88FuIZCim4fMNml-lUPKlo/pub?embedded=true) and the marking rubric is located [here](https://review.udacity.com/#!/rubrics/23/view).

## Building and running the app

The app was built using Swift 4 and XCode 9. It requires CocoaPods to build, as it uses a third-party XML parsing library.

## User Experience

This app is best viewed on the iPhone screen sizes, although since it uses autolayout it will adjust to the iPad screen sizes.

The BookTag app has three screens: a tag screen, a collage screen and a book detail screen. When the user launches the app, they see the tag screen with a message "You haven't added any tags yet." There's a plus button in the top right nav bar to add a tag. When the user hits it, a popup appears asking the user to enter a tag, with buttons to "continue" or "cancel".

If the user enters a tag and hits "continue", the app navigates to the collage screen, blurs the screen and shows a loading spinner. The app notifies the user if they are not connected to the Internet or if an error occurs.
When the books are loaded from Goodreads, the app loads the images for each book into the collection view on the collage screen.

There are two buttons on the nav bar of the collage screen. One is for toggling night mode. Another is for "rerolling" the collage - replacing the current page of books with a random page of books loaded from Goodreads.
If the user taps one of the books in the collage, the app navigates to a detail view showing the book cover, title, author, page count, Goodreads rating, description, year of publication, ISBN, and ISBN13.

The user may navigate back from the book detail screen to the collage screen, and from the collage screen back to the tag screen.

The tags and books are stored using Core Data. The book cover images are stored using Core Data's external image storing capability, in which the files are referenced from the database.

If the user opens the app having already used it, they will see their existing tags on the tag screen. The user can swipe a tag to the left to see a "tap to delete" message appear in red. This will allow them to delete the tag and its associated books.

On every screen the nav bar contains a button to toggle night mode.

The app has a splash screen and an icon, both of which I created in MS Paint.

## Technical details

This app is built using XCode 9 and Swift 4. It uses the Goodreads API with my developer API key. The Goodreads API returns data as XML and Apple hasn't yet provided a simple way to parse XML in Swift, so I am using [drmohundro's SWXMLHash library](https://github.com/drmohundro/SWXMLHash) to parse data. Consequently, CocoaPods is required to build the project.

In terms of sophistication, the app does the following: 
- Uses Core Data for persistence of Tags and Books, with many books related to single tags
- Incorporates both modal and push navigation
- Uses UserDefaults to store the user's night mode preference
- Has both a table view and a collection view (which both use fetched result controllers to sync with the underlying database)
- Handles connectivity, network and parsing errors with appropriate error alerts
- Calls two different Goodreads API methods
- Parses XML responses using a third-party library linked through CocoaPods
- Uses custom icons and a custom splash screen
- Has three view controllers, not counting navigation controllers
- Uses alert views

## Challenges

During the course of this project some problems took much longer to solve than I had anticipated. 

The scrolling on the book detail view was broken and I spent about three hours going through StackOverflow solutions and building up the view heirarchy from scratch before I figured out what was wrong (the cover image view height needs to be set at design time).

I spent a couple of hours trying to figure out how to change the colour of the status bar information so that it would still be visible in night mode.

The limitations of the Goodreads API required some code acrobatics to negotiate. 
* The book search operation returns a maximum of only ten results, which cannot be changed. I planned to display at least twelve results on the collage view, so I had to code the client to recurse through the search call until it had accumulated enough results. 
* A lot of the books on Goodreads don't have cover images, and it doesn't look good to fill a collage with placeholder images, so I had to filter out those results. 
* A lot of the book metadata is either missing or contains HTML markup, so I had to sanitise it.
* The API serves results in XML, so I had to choose between writing my own XML parser or looking for a third-party parsing library (which I eventually did find, see Acknowledgements below).
* Finally, Goodreads doesn't want anyone calling their API more than once a second, so I had to make sure the client waited in between calling for more results.

Despite these challenges, I am very happy with how the app turned out.

## Improvements

The app as it stands fulfils all the requirements as specified in the specification and in the marking rubric. However, I do have some ideas for extensions and enhancements.

* A sharing button on the collage view that would screenshot the collection of book covers and allow the user to share it using the standard Activity controller.
* The ability to delete individual books on the collage view.
* A custom Alert view which would appear in the appropriate colours based on night mode. Apparently the standard Alert view cannot be customised, so the way to do this would be to create a custom view that behaves like an alert view.
* Goodreads exposes a great many API methods and this app only uses two of them, so there are many possible ways to extend the use of the API.


## Acknowledgements

- drmohundros's [SWXMLHash XML parsing library](https://github.com/drmohundro/SWXMLHash) performed flawlessly and I am immensely grateful to him for his continuing maintenance on that project.
- The Goodreads API, while having some frustrating limitations, was still consistently reliable during development and testing, for which I am grateful.
- The night mode nav bar I'm using I found on Iconscout [here](https://iconscout.com/icon/night-mode-2).
- StackOverflow was an invaluable resource as I ran into problems both great and small.
