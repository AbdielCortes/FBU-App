# INSERT APP NAME

## Table of Contents
1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)

## Overview
### Description
An app that allows artist to showcase their work and sell it. Users can follow other artists to see their posts show up in their home feed. When a user creates a post, they can select if they want to display it as a ‘for sale’ item.  

### App Evaluation
- **Category:** Social Networking / Art / Shopping
- **Mobile:** It would be developed for mobile only at first, but with a web version coming in the future. Both the mobile and web version would have the same content and features. 
- **Story:** Allows artists to display and sell their work. Allows art enthusiasts to view and purchase art. 
- **Market:** Visual artists (painters, sculptors, digital artists, photographers, etc..) and art enthusiasts. 
- **Habit:** The app would really benefit from users creating a habit of using the app daily like and interacting with other users. 
- **Scope:** The main part of this app would be for users to be able to see the posts from the users that they follow, this can be done with a table view. For the user's profile I want their post to show up in a collection view in a similar way to Instagram. The buy and sell feature would be complicated to implement, the final app should at least allow the user to select between posting a regular post or posting a sell post. 

## Product Spec
### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [ ] User can create an account and log in
- [ ] Profile pages for each user
- [ ] User can follow other accounts
- [ ] User in their home feed can see posts from the accounts that they follow
- [ ] When posting user can select between making a regular post or a sell post
- [ ] When creating a post, the user can tag the location 

**Optional Nice-to-have Stories**

- [ ] Multi image posts
- [ ] Liking posts
- [ ] Sharing posts
- [ ] Commenting on posts
- [ ] Profile shows all of the users posts using a collection view
- [ ] Private messages

### 2. Screen Archetypes

* Login - User Logs in into their account
   * User can select to mainting their account logged in so they don't have to do it every time the open the app.
* Sign Up - User creates account
   * User inputs all their information and creates an account.
* Home Feed  
   * Shows posts from the accounts that the user is following, uses table view.
* Post Details 
   * Shows additional information for the post and allows user to comment.
* Posting  
   * Post are image based with a text caption; the user can select between making a regular post or a buy post.
* Profile  
   * Shows the username, profile picture, button to follow the account, and the user's contact information.
* Messaging - 1 on 1 messaging
   * Users can message each other without the need to be mutually following each other.
* Settings 
   * Lets the user change notification and privacy settings.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Feed
* Profile

Optional:
* Messaging

**Flow Navigation** (Screen to Screen)
* Login - Opened if the user has not registered an account, user puts their username and password to login.
    * -> Sign Up - User creates an account by entering their email, username, and password twice.
* Home Feed - Shows posts form the accounts the user is following.
    * -> Post Details - User can tap on post to view details or comment.
    * -> Posting - Button that allows user to create a post.
* Profile - User can modify ther profile picture image, and contact information.
    * -> Settings - User can modify notification and privacy settings.
* Messaging - User can send messages to the accounts that they're are following.

### 4. App Expectactions
- [x] Your app has multiple views
- [x] Your app interacts with a database - I'll be using Parse for the backend 
- [x] You can log in/log out of your app as a user
- [x] You can sign up with a new user profile
- [x] Somewhere in your app you can use the camera to take a picture and do something with the picture - When creating a post the user can use the camera and add that picture to the post
- [x] Your app integrates with a SDK - Google Maps SDK for iOS, used for taggin locations on posts
- [ ] Your app contains at least one more complex algorithm 
- [x] Your app uses gesture recognizers - double tap image to like and/or pinch zoom for images
- [x] Your app use an animation - transition animation when tapping post button in home feed
- [ ] Your app incorporates an external library to add visual polish

## Wireframes

<img src="ReadMeImages/wireframe_hand-drawn.jpg" width="600"> 
