# Tinybeans iOS Development Challenge

Included with this package is a simple iOS app designed for candidates
to demonstrate their knowledge of iOS patterns and issues.

Imagine a member of your team has created a proof-of-concept app and management decided that you're the person to make it production ready.

All the app does is pull a list of Reddit articles from our backend server and display them in a list.
The articles come combined in a (potentially large) zip file.
Inside the zip file is a bunch of JSON payloads collected from the Reddit public API.
The app is responsible for unzipping, parsing and displaying these articles in a list.
On every launch, the app wipes and pre-fills its database with some example articles.

## Instructions

## Required improvements

1) Currently the app is unusable whilst it is loading the articles;

2) The progress bar should continuously update to indicate the progress of the operation and only then disappear;

3) If the 'load articles' operation is run multiple times, there should not be any duplicates in the list;

4) There are a few 'code smells' within the project. Within reasonable limits, refactor the code to something
that you would be willing to maintain (perhaps for years);

5) Optionally, and time permitting, include some unit tests. Perhaps you want to add a test to ensure that we will never have the same article accidentally inserted twice in the database.

## New Features to add

1) The network operation should be cancellable;
After the user taps the 'load articles' button, whilst the operation is in progress,
the 'load articles' button should be replaced by a 'cancel' button.
Tapping cancel should terminate the operation as soon as possible

2) Add a new label to each cell to indicate the score of the corresponding article.
The `score` attribute can be fetched from the JSON payload under the `score` key of each article

3) Articles should be ordered by firstly by their `created` parameter, then
by the `score` parameter, in descending order;

## Submission

Once you’re happy with the status of your project, please email the following to your recruiter:

*Your Code.* Zip up the project and include it in the email. This can be either flat files, or a zipped up git repo containing development history. Please name the file: [firstname]_[lastname].zip.
In a README in that project, please include:

*1* *Build Tools & Versions Used.*Please tell us what version of Xcode, Android Studio, IntelliJ, etc you used to build and test your project, as well as what versions of iOS or Android we should use to evaluate your submission.

- XCode Version 12.5.1 (12E507)
- iPhone 8 Simulator iOS 13.5

*2* *Your Focus Areas.* What area(s) did you focus on when working on the project? The architecture and data flow? The UI? Something else? Please note what you think best exhibits your skills and areas of expertise.

- Achitecture, 
- UI
- Reusable pieces of code

*3* *Copied-in code or copied-in dependencies.* We’re obviously looking to evaluate your skills as an engineer! As such, please tell us which code you’ve copied into your project so we can distinguish between code written for this project, vs code written at another time, or by others (if you’re just referencing a dependency via a dependency manager, no need to call it out here).

- protocols 
- tableView extensions

*4* *Tablet / phone focus.* If you focused on one or the other of tablet or phone, please let us know which one.

- phone

*5* *How long you spent on the project.* We’d like to know how long you spent on the project so we can calibrate our review. Please do not feel like you need to spend more than the expected 4-5 hours.

~ 6-8 hours in summary

*6* *Anything else you want us to know.* If there’s anything else of note that you think we should know while evaluating the project, please let us know!

## FAQ

*Can I use third party libraries?*

Yes, but we will probably ask you to explain why you chose
each dependency (especially if a foundation alternative exists)

*Do I need to write tests?*

You should structure your code so that it's testable. There is no minimum or maximum amount of test coverage we are looking for - instead try to provide enough coverage such that regressions would be caught by automated tests. Only worry about unit tests - you can skip view snapshot or integration tests.

*How much time should I spend on this?*

The actual engineering work should take approximately 4-5 hours, and you can split this across the week however you see fit(all at once, over a few days etc).

*Should I improve the UI?*

If you can fit them into your 4 hours, go for it. Otherwise we can talk about some of the ideas
you had when we review the challenge with you.
