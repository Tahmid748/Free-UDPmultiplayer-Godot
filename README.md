
# This is my Godot Multiplayer project using manual UDP hole punching, to implement a completely cost free multiplayer set-up.

This project makes an STUN request, and exposes the users IP and Port, And using the IP and Port (which is encrypted for the users), a manual hole punching is done, after the hole punching is established the connection is wrapped aroung ENet to take advantage of Godots high level multiplayer features.

There is a local mode for testing on the same device which is on by default. To test the actual hole punching there needs to be 2 devices on 2 different networks, you can test it with a friend or using a VPS.

## !Caution

> UDP hole punching has its limits, players behind Symmetric NATs, CGNATs etc often will will reject UDP hole punching, in real wolrd scenario for only around 60% - 80% of the players this will be successful (I have no sources to back this up).

If you want to accomodate 100% of players you will need to support relay servers.

This project is mostly done to learn about multiplayer stuff, for an actual game lunching on steam you can use steams multiplayer system or outside steam you can use Netfox.

## The gameplay part of this project is not finished yet, only level 1 and 2 are finished right now, level 3 is in the works.

To actually play the game you'll need to also add your own assets, since the assets used to make the game are not going to be made public.

Use your own assets for all the images mentioned in the ASSET_MANIFEST.md

## Thank you for checking this project out!

If you have any inquiries feel free to reach me out to discord: titnian

---

This repository is primarily intended as a learning and code-reuse resource. The source code is licensed under GPL-3.0. The original game's assets and branding are not included in this repository and remain the property of their respective copyright holders.
