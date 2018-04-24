# wriggler-qbasic
This is a 1998 prototype QBASIC game, the concept ripped entirely from Romantic Robot's Wrigger on Amstrad CPC.

In 1998, I was 17. This was as far as I got with my crack at it!

The game pits you, a plucky young worm (composed of 4 lines and a blob), against a world of anatomically incorrect spiders in your mission to see a duck and solve a single puzzle.

I guess there would be more to it, but it was 1998, I was 17, and I lost focus... This was as far as I got with my crack at it!

Full playthrough video here: https://youtu.be/IMtjw2OJrKs

![Screenshot 1][qbasic-wriggler-1]
![Screenshot 2][qbasic-wriggler-2]
![Screenshot 3][qbasic-wriggler-3]

I don't suppose there's much to be learned from my code, but I've popped the disk image in this repo for completeness - and because I don't want to lose it again! I seem to have followed a fairly traditional sprite system, using QBasic's built-in GET and PUT to grab and then render sprites. As a result, there's a loading sequence where all the sprites are individually drawn to the screen before they are grabbed before the game begins...

I remember very little about the actual coding, but it seems like I also wrote some tools to edit the sprites in the game, and to design the rooms in the level. I stopped development roughly around the time I ran out of disk space it seems, and in the last moment of the game you see a teleporter system that I never actually finished. Early mentions of it are commented out in the code, which tells me it wasn't working the last time I showed the game to someone!

Anyway, feel free to tinker with it if that's your groove (or not, it's just a QBasic doodle).

You can see the original Wriggler on Amstrad and Spectrum here: https://www.youtube.com/watch?v=02Kh076wja8

[qbasic-wriggler-1]: https://github.com/instantiator/wriggler-qbasic/raw/master/media/qbasic-wriggler-01.png "It was a game that pitted one plucky worm against an army of anatomically incorrect spiders"
[qbasic-wriggler-2]: https://github.com/instantiator/wriggler-qbasic/raw/master/media/qbasic-wriggler-02.png "The whole puzzle, the only puzzle, and nothing but the puzzle"
[qbasic-wriggler-3]: https://github.com/instantiator/wriggler-qbasic/raw/master/media/qbasic-wriggler-03.png "Also, for some reason, a duck."
