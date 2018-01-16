# BookTag

This app is built using XCode 9 and Swift 4. It uses the Goodreads API with my developer API key. The Goodreads API returns data as XML and Apple hasn't yet provided a simple way to parse XML in Swift, so I am using [drmohundro's SWXMLHash library](https://github.com/drmohundro/SWXMLHash) to parse data. Consequently, CocoaPods is required to build the project.

The app has three screens: a tag screen, a collage screen and a book detail screen. When the user launches the app, they see the tag screen with a message "You haven't added any tags yet." There's a plus button in the top right nav bar to add a tag. When the user hits it, a popup appears asking the user to enter a tag, with buttons to "continue" or "cancel".

If the user enters a tag and hits "continue", the app navigates to the collage screen and indicates to the user that books are being loaded from Goodreads. The app notifies the user if they are not connected to the Internet or if an error occurs.
When the books are loaded from Goodreads, the app loads the images for each book into the collection view on the collage screen.

There are two buttons on the nav bar of the collage screen. One is for sharing a screenshot of the collage. Another is for rerolling the collage - replacing the current page of books with a random page of books loaded from Goodreads.
If the user taps one of the books in the collage, the app navigates to a detail view showing the book cover, title, description and rating. 

The user may navigate back from the book detail screen to the collage screen, and from the collage view back to the tag screen.

The tags and books are stored using Core Data. The book cover images are stored using Core Data's external image storing capability, referencing the image files from the database.

If the user opens the app having already used it, they will see their existing tags on the tag screen. The user can swipe a tag to the left to see a "tap to delete" message appear in red. This will allow them to delete the tag and its associated books.

