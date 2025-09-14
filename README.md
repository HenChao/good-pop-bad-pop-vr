# Good Pop, Bad Pop VR

My submission for the fourth Godot XR game jam (https://itch.io/jam/godot-xr-game-jam-sep-2025).

https://henrychao.itch.io/good-pop-bad-pop

## About this game

*"In the parental justice system, the children are represented by two separate yet equally important authorities: the good pop, who keep the peace; and the bad pop, who enforce the rules. These are their stories."*

Looks like these kids are up to no good again. Chief of Police Mom needs you to question the suspects in a series of tough who-dun-it cases and get to the bottom of these mysteries. But you won't be able to do it without using a few tricks from the old dad playbook.

Act as the Good Pop to sooth your suspect if they start feeling too anxious or scared. You want to keep them calm and happy if you expect to get any useful information out of them.

Or act as the Bad Pop if you think your suspect isn't telling you everything. Sometimes a stern talking to can scare them straight. But be careful, go too far and they'll be asking for Lawyer Mommy to help them out.

## About this submission

As this is my first Game Jam and my first submission, I'm proud and excited to share the outcome with others! Given the time constraints, I do wish that I had more time to polish the game further, but I'm happy with what I have so far.

I will say that while the game is (hopefully) playable and completeable, there are several bugs I know of, and unfortunately, not much time to perform play testing and test on different devices. Please forgive any game breaking issues or less-than-optimal gameplay due to these constraints.

## Development workflow

A majority of this game was developed on a Windows laptop, with most of the testing and debugging performed on-device with a Meta Quest 3 through the Godot XR Editor. Testing and debugging was much easier on-device, but managing and adding assets to the project was ultimately easier on the laptop. The initial setup of the environment was as follows:

* Setup SideQuest (https://sidequestvr.com/) and connect to XR device.
* Use SideQuest to install F-Droid (https://f-droid.org/en/) on device, then install Termux (https://f-droid.org/en/packages/com.termux/) through F-Droid.
* Install git and open-ssh on the device.
* Grant Termux permission to storage on device (https://wiki.termux.com/wiki/Termux-setup-storage).
* Download and setup the Godot XR Editor on device.
* Setup a SSH keypair on device, and add it to my GitHub account.
* Setup a new project in GitHub, and clone it on device in a directory accessible to the Godot XR Editor.

With the environment setup complete, the development workflow was as followed:
* Clone the same project from GitHub to my laptop.
* Write code, add assets, or do whatever is needed on the laptop.
* Commit and push changes through git to GitHub.
* On device, pull the changes, and open up the project in the Godot XR Editor.
* Debug, make changes, or do whatever is needed on device.
* Commit and push changes through git to GitHub.
* On laptop, pull the changes.

And continue with the pull/push process between both devices as needed. Overall, once the majority of the work was completed on the environment setup, the rest of the process and workflow was simple. Though I will admit that having previous knowledge of working with Linux, terminal environment, and git helped greatly with troubleshooting problems with the environment setup.

## Limitations

A few known bugs and limitations in the game.

* Pause menu interaction is not working. Pausing is still possible, but triggering any of the menu objects does not work. I suspect I'm doing something wrong with the tree pausing and cursor interactions in the scene, but no time to figure that out now.
* Toy interactions sometimes gets dropped, and tracking is lost by the baby. Unable to determine why so far.
* Player and object positioning is off on some scene loads. Resetting the position through the device recentering function.
* Lots of optimizations possible through the game, including with textures and images. Can also probably refactor key portions of the code (like the levels) to reduce duplication.
