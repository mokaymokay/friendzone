![friendzone logo](app/assets/images/friendzone-full-logo.png)

### *Friendzone* is an app that lets you see your friends' location and local time based on their time zone.

## Built with:
* Ruby on Rails
* PostgreSQL
* [Foursquare Places API](https://developer.foursquare.com/places-api)
* [Google Geocoding API](https://developers.google.com/maps/documentation/geocoding/intro)
* [Google Time Zone API](https://developers.google.com/maps/documentation/timezone/intro)

## Description
The app uses the Google Geocoding API to get a user's coordinates from a query string (home city) and the Time Zone API to get the Time Zone ID (defined by [Unicode Common Locale Data Repository (CLDR) project](http://cldr.unicode.org/)). The TZInfo gem is used to get the current local time with the Time Zone ID.

## Usage Instructions
Users need to log in using their Foursquare accounts. Once authorized, the app will import their friends' data from Foursquare in order to display their home cities and local time.

## Screenshots

Home page when not logged in:
![home](github/home.png)

Friends in various time zones, shows name and location when hovered:
![friends](github/friends.png)

## Future
Currently, the app uses a static attribute (home city) from Foursquare's user data, instead of dynamic location data (check ins), which requires individual user's authorization. Dynamic location display is currently being implemented, along with the mobile version using React Native.

## Acknowledgement

### Design Inspiration:
* [timezone.io](https://timezone.io/)
