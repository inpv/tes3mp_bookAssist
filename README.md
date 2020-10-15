# tes3mp_bookAssist

## Description:<br>
Like a very lightweight BookRotate, this script places books vertically upright with the spines facing the player. It basically allows you to put most books on a shelf neatly.<br>
## Installation:<br>
1. Place the script into `server/scripts/custom` directory.<br>
2. Add a line `bookAssist = require("custom.bookAssist")` in `server/scripts/customScripts.lua`
## Usage:
1. To enable the placement system, type `/ba 14` in chat (for most books' size). This sets the book's height to place it correctly in the space between the shelves instead of through them. For larger books, type `/ba 20` or `/ba 21`.
2. To disable the placement system (i.e. when placing open books or scrolls), type `/ba 0` in chat.

## Original description:<br>
A morrowind-multiplayer/TES3MP script implementing some of Book Rotates functionality for placing books vertically serverside<br>
Idea and maths taken from Book Rotate by Cydine & Maboroshi Daikon ( http://mw.modhistory.com/download-11-6953) & Hephs Book Rotate System (http://morrowind.heph.org/)
<br>Code largely based on Atkanas decoratorsAid and decorateHelp ( https://github.com/Atkana/tes3mp-scripts ) 
<br>Author: Falas/Buntnessel on Tes3mp Discord<br><br>
Ported and modified by inpv for 0.7.0-alpha.<br><br>
