# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

We follow [Keep a Changelog](http://keepachangelog.com/) format.

## 0.4.0 - 2015-08-21
### Added
- I18n support

### Changed
- Fixed channel name on slack, which was incorrectly displaying ID

## 0.3.0 - 2015-07-19
### Modified
- Correctly using Lita::Room object
  * create queues based on room ID
  * display queue using room name metadata
  * modified specs to catch this change

## 0.2.0 - 2015-06-21
### Added
- Respond to the following additional command:
  * lita rotate!

### Changed
- More granular specs and better RSpec defaults (.rspec)

## 0.1.0 - 2015-06-14
### Added
- Initial plugin import with support for the following commands:
  * lita queue
  * lita queue me
  * lita unqueue me
  * lita queue next?
  * lita queue next!
- RSpec, Travis CI and Coveralls support
