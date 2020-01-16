# Snail Mail
iOS app that sends Slack notifications when mail is delivered. Designed to improve mail system in Make School student housing.
<p align="center">
  <img width="460" height="460" src="https://github.com/SamuelFolledo/SnailMail/blob/master/SnailMail/Assets.xcassets/AppIcon.appiconset/1024.png">
</p>

### Tools Used
- __UI/UX Programming Language__ - [Swift](https://swift.org/)
- __Backend Programming Language__ - [Python](https://www.python.org/)
- __API Framework__ - [Flask](https://www.fullstackpython.com/flask.html)
- __Slack Bot__ - [SlackBot API](https://slack.com/help/articles/202026038-An-introduction-to-Slackbot)
- __Database and Storage__ - [Firebase](https://firebase.google.com/)
- __Text Recognizer Machine Learning Kit__ [Firebase/MLVision](https://firebase.google.com/docs/ml-kit/ios/recognize-text)

### Demo 1: User exist
- This demo shows how the app captures an image and using Machine Learning and name finder algorithm I wrote, displays the name found from the mail. It also shows a Slack message received with the address written on the mail.
<img src="https://github.com/SamuelFolledo/SnailMail/blob/master/static/gif/demo1.gif" width="563" height="1000">

### Demo 2: Update mail's recipient
- This demo shows how the app works with any type of mail or shipping labels and how the name can be updated if for some reason, the name it captures is wrong. It also demonstrates in the Slack message's address matches the mail's address.
<img src="https://github.com/SamuelFolledo/SnailMail/blob/master/static/gif/demo2.gif" width="563" height="1000">

### Demo 3: Swipe to delete, and delete all mails
- This demo shows secondary screens like larger image and list of all mails scanned which can be swiped to delete, or delete all with animations. 
<img src="https://github.com/SamuelFolledo/SnailMail/blob/master/static/gif/demo3.gif" width="563" height="1000">

License under the [MIT License](LICENSE)
