# Assignment for candidate

## iOS assignment

Maintaining your health comes in all forms and we need a way to help brighten a person's day. For this exercise, we need an iOS app that lists 'Rick and Morty' episodes and provides some extra details for each one of them. Use this [API](https://rickandmortyapi.com/documentation/#rest) to retrieve all the needed data.

In detail:

- The app should list all episodes available from the api-
- On the list, each episode should show the name, air date (in dd/mm/yyyy format) and the code of the episode.
- Show with text that the user has reached the end of the list (after all episodes are loaded on the screen)
- Tapping on the episode should list all the id's of the characters of that episode
- Tapping on each character's id should show the details page of that character (image, name, status, species, name of the origin and the total number of episodes the character appears in)
- Provide an export functionality to export the character details (name, status, species, name of the origin and the total number of episodes) in a file and store it locally so it can be opened by another app, such as a document reader or file explorer.
- Implement refreshing the list content in the background.

You can use any colours, fonts and UI design patterns that you think are a proper fit for this app. For this assessment we don't care too much about the design. Just make sure that the app looks like an app 🙂.

The app should be written in Swift and use SwiftUI. You shouldn't spend more than a weekend on it. You are free to use third party libraries if required. The app should be delivered via a public repository (i.e. Github, Gitlab, etc).

**It is not a requirement, but you can get extra points for:**

- Implementing a persistence mechanism for the data received from the api
- A pull to refresh mechanism (if persistence is used)
- Timestamp showing the last time content was refreshed (if persistence is used)
- Writing unit and ui tests.
