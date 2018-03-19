# university website: JSU

<h1> Introduction </h1>
<hr>

<p>This project was developed as part of a team effort for a class in software engineering. All the code uploaded here (including the database) is my own, except for the static html pages that display each major's classes and the add courses page (the add courses page was developed by team member Drake and reworked by me). The rest of the features discussed below are not included, only the bare-bones features to demonstrate the working site. </p>

<h2> The Story Behind the Project </h2>
<hr>

<p>The major challenge of this project was this: how do you develop a fully complete university website (front- and back-end) with a team of members who mostly never touched HTML, CSS, SQL, or JavaScript? This was developed in the spring semester of 2017, and during the previous semester, I faced a similar situation: with the help of a good textbook, several online tutorials, and dozens of stackoverflow posts, I was able to learn the basics and complete the project on time.</p>

<p>I volunteered to be the project manager for this project, so what I did was start by taking account of the situation. Everyone knew Java, so I figured each member could build a section of the site using what he knew, instead of trying to do what I did and quickly cram in all the knowledge needed to get going on even the basics. For instance, we had a member who knew how to build the interface for a chat client, so his job was to work on implementing a chat system for the site in the form of an applet that could be launched on the main page. Using each member this way, we could build a more expansive and fully featured site, since no training would be involved. Overall, it worked as intended.</p>

<h2> Authentication and Authorization </h2> 
<hr>
<p>The auth system built into the site is simplistic: we decided to use a cookie system--which actually worked more like tokens, since session ids weren't stored in the database--that would store a different cookie depending on the type of user. Pages cannot be accessed unless first logged in, and only the correct type of user could access certain pages: the professor's homepage was different from the students, so they had to be logged in as a professor to accomplish this.</p>

<h2> Caveats </h2>
<hr>
<p>The database design did not follow any normalization principles, simply because I was not aware of them at the time (I had taken a database management class the previous semester and it did not cover the topic). I only later learned about them, since during the course of developing the database for the project and managing it, I encountered a lot of the anomolies the principles were meant to address--such as insert anomolies. Also, as before in the airline project, the code is very WET, as I never could figure out how to properly create working templates--nothing ever displayed properly, and I abondoned the effort since using IntelliJ IDEA made it easy to create its own "templates" (just a new jsp file with the bare-bones html and the code I needed pasted in). I would have had to change it for a production environment, but I made do with it here since it wouldn't be counted against us.</p>

<p>The passwords are also stored as plaintext in the database. Naturally, this is a big offense, but it was taken as a measure of expiediency: I was working not only in INTELLIJ to edit JSPs and run the site but also using the command line inside the database to create new relations, edit old ones, and insert test data into tables. Real security was also never an issue, since the site was meant to be demoed but once, not run online and forced to hold up against attacks. </p>



