# CleanUI

A lightweight World of Warcraft (WotLK 3.3.5) addon designed to modernize the interface with class-themed elements and improved layouts while maintaining the classic feel.

## Key Functionalities
- **Class-Themed Portraits**: Replaces standard 3D portraits with high-quality custom class icons for the 10 standard WotLK classes.
- **Dynamic Fallbacks**: Automatically reverts to native 3D portraits for NPCs, Pets, and custom Ascension classless builds.
- **Class-Colored Health Bars**: Health bars automatically update to match the unit's class color.
- **Modernized Layouts**: Optimized positioning for Player, Target, Focus, and Target-of-Target frames.
- **Improved Typography**: Adds outlines and shadows to unit frame names for better readability.
- **Clean Loot Stack**: Custom anchoring for loot roll frames to prevent screen clutter.

## Slash Commands
Access features and management via the `/cui` command:

| Command | Action |
|:---|:---|
| `/cui portrait` | Toggles between **Class Icons** and **Default 3D Faces** for unit frames. |
| `/cui loot test` | Toggles test mode for loot frames to adjust positioning. |
| `/cui party test`| Toggles test mode for party frames to preview layout. |
| `/cui reset` | Resets all frame positions to default and reloads the UI. |

## Installation
1. Place the `CleanUI` folder into your `Interface/AddOns/` directory(make sure the folder containing the addon files is named "CleanUI").
2. Ensure your custom class icons are located in `Interface/AddOns/CleanUI/Media/classes/` as `.blp` files named after the class (e.g., `WARRIOR.blp`).
