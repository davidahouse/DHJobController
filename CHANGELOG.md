# DHJobController CHANGELOG

## 0.2.1

Fixed DHConcurrentOperation so it didn't always start on the main thread. Also
added a method for executing a selector in the operation after a delay, and
a maximum runtime watchdog for making sure an operation doesn't keep running
over a certain amount of time.

## 0.2.0

First public release

## 0.1.1

Renamed to DHJobController

## 0.1.0

Initial release.
