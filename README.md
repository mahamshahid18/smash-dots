# Smash Dots

This game was created as a project for 'Game Design' course that I took in my final semester of Undergrad. This game is a `collaborative effort`, with code written by me and my group partner. You can find the code in *[`main.lua` file](https://github.com/mahamshahid18/smash-dots/blob/master/main.lua)*

The game was uploaded to [Google Play Store](https://play.google.com/store/apps/details?id=io.github.thehappybug.smashdots). _This is the basic version of the game. Some enhancements were made before it was uploaded to Play Store. Unfortunately, the code for that has been lost._

The game mechanics are simple. Discs/circles appear on the screen from one corner of the screen and complete their animation to another side of the screen. The objective is simple, `Tap all the discs appearing on screen`. If a disc completes its movement from one corner of the screen to another, without being smashed, the game is over.

My group partner worked on the basic mechanics of the game (disc creation, disc animation, score increment, game over condition check). Whereas, I added enhancements to the gameplay, along with code to add in monetization (through ads). My work was basically to:

*  Add in `Color Theme Unlocking` functionality
*  Add in `Perfect Hit` functionality
*  Add in `Monetization through ads` functionality

## Color Theme Unlocking
Based on the player's score, the _theme_ of the game will change. This includes changing the color of the main game screen as well as the discs appearing on screen. This also included changing color of the disc explosion particle effect.

So, as the player progresses through the game, they get a subtle reward with changing themes (sense of achievement & reward). I wrote `changeBackgroundColor`, `changeItemColor` and `setBgColorTheme` for achieving this effect. And implemented their calls in the game loops, where necessary.

## Perfect Hit
When the player taps on the disc when it's in the center of the screen (horizontal center), it will result in a _Perfect Hit_ for which the player will get extra points. Usually the player gets 1 point for tapping a disc. But if _Perfect Hit_ occurs, the player is awarded with *5* points.

I implemented a basic version of this in `checkPerfectHit` function.

## Monetization through ads
I added monetization by including ads from admob. These functions were written for the purpose `checkShowAd`, `adListener`

## Code I wrote from scratch
Here's a list of the functions that I wrote from scratch:

* `checkShowAd` [See Code](https://github.com/mahamshahid18/smash-dots/blob/master/main.lua#L66)
* `adListener` [See Code](https://github.com/mahamshahid18/smash-dots/blob/master/main.lua#L45)
* `changeBackgroundColor` [See Code](https://github.com/mahamshahid18/smash-dots/blob/master/main.lua#L79)
* `changeItemColor` [See Code](https://github.com/mahamshahid18/smash-dots/blob/master/main.lua#L101)
* `setBgColorTheme` [See Code](https://github.com/mahamshahid18/smash-dots/blob/master/main.lua#L123)
* `checkPerfectHit` [See Code](https://github.com/mahamshahid18/smash-dots/blob/master/main.lua#L153)

Other than these, there were some minor things, like variable state persistence etc that was needed for implementing the above 3 features.
