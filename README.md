# lita-queue

[![Build Status](https://travis-ci.org/brodock/lita-queue.svg?branch=master)](https://travis-ci.org/brodock/lita-queue)
[![Coverage Status](https://coveralls.io/repos/brodock/lita-queue/badge.svg?branch=master)](https://coveralls.io/r/brodock/lita-queue)

Lita handler to manage people queue per channel

## Installation

Add lita-queue to your Lita instance's Gemfile:

``` ruby
gem "lita-queue"
```

## Usage

Manage a queue of users for any channel.

The following commands are available:
* lita queue
* lita queue me
* lita unqueue me
* lita queue next?
* lita queue next!
* lita queue rotate!

The following commands will be available in a further version:
* lita queue = [<new_queue,comma_separated>]
