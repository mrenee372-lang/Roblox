# Midnight Munchies 👻🍕

A tiny Roblox horror-comedy game: sneak through a ridiculous haunted snack shop, grab three cursed snacks, and escape before the very dramatic monster catches you. The monster is spooky, but its taste in jokes is worse.

## Run it

This is a [Rojo](https://rojo.space/) project. Install Rojo, then from this folder run:

```sh
rojo serve
```

Connect Roblox Studio to the Rojo server and press **Play**. The server script builds the map, monster, collectibles, and exit automatically. No assets or paid plugins are required.

## How to play

- Find and touch all **3 cursed snacks**.
- Avoid **The Snack Goblin**. If it catches you, it delivers a terrible joke and sends you back to the entrance.
- Get to the glowing exit with all three snacks to win.

## Tuning

The map, snack locations, monster speed, and catch distance are near the top of `src/server/Game.server.lua`. This is a compact prototype intended to be a fun starting point; publish it from Studio after testing and customizing it.
