# Social ME

Social ME is a modern cross-platform messenger app that has both a web and mobile (iOS) interface. Registered users can chat with others with have accepted their friend requests. Photo messaging and group chat are also supported. Real-time communication on both ends for instant messaging and friend requests.


**Technoloy that built with**
- MongoDB
- AngularJS
- Express
- NodeJS
- Twitter Bootstrap
- Socket.io
- Swift
- Core Data
- Ajax

##Running the App
The site is already deployed here: http://52.36.153.231/#/welcome <br/>
However, if you want to run it locally, make sure that you do the following:

1. Install all the dependencies
  1. ```npm install``` within the server folder
  2. ```bower install``` within the client folder
  3. ```pod install``` within the iOS folder
2. start ```mongod``` connection
3. start node server with ```nodemon server.js```
4. navigate to ```http://localhost:5000```

##Features with Demo
- Login and Registration with validations
- Friend Requests: functionality of sending friend requests to others and responding to others' friend requests (with options to accept and ignore)
![friendrequests](https://cloud.githubusercontent.com/assets/15684513/13453425/dea1cc82-e004-11e5-8ade-d0590aaf38ea.gif)

- Private Messaging: private conversation between two friended users
![privatemess](https://cloud.githubusercontent.com/assets/15684513/13454368/7a68ec30-e00b-11e5-8089-4233039afac4.gif)

- Group Chat: public conversation allows two and more users talk to each other
![groupmess](https://cloud.githubusercontent.com/assets/15684513/13454628/46996694-e00d-11e5-8920-fec8abe640bb.gif)

- Media Message: sending and receiving photo in conversation
![mediamess](https://cloud.githubusercontent.com/assets/15684513/13456449/0ef4b06c-e018-11e5-9715-99d0fb6021fa.gif)

- Updating Profile Picture
![imageupdate](https://cloud.githubusercontent.com/assets/15684513/13456482/385c97d0-e018-11e5-9160-bce50a5f4243.gif)




