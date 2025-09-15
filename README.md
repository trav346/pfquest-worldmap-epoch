# pfQuest World Map - Epoch Edition

A World of Warcraft addon that adds quest availability pins to continent maps for pfQuest-wotlk.

## Features

- **Continent Quest Pins**: Shows available quest locations on Eastern Kingdoms and Kalimdor continent maps
- **Smart Filtering**: Automatically filters out:
  - PvP quests (Warsong, Arathi, Alterac battleground quests)
  - Chicken escort quest spam (CLUCK! quests that appear everywhere)
  - Gray quests
  - Red quests

## Installation

1. Make sure you have [pfQuest-wotlk](https://github.com/shagu/pfQuest) installed
2. If on Project Epoch, also install pfQuest-epoch addon
3. Download this addon and place in your `Interface/AddOns/` folder
4. Folder structure should be: `Interface/AddOns/pfquest-worldmap-epoch/`
5. Reload your UI or restart the game

## Usage

- Open your world map (M key)
- Zoom out to continent view (Eastern Kingdoms or Kalimdor)
- Yellow exclamation marks (!) will appear showing zones with available quests
- Hover over pins to see quest information

### How It Works

The addon hooks into pfQuest's `UpdateNodes` function to display quest pins on continent views. It:

1. Triggers pfQuest's quest database search for level-appropriate quests
2. Converts zone coordinates to continent coordinates using zone boundary data
3. Creates visual pins on the WorldMapButton frame
4. Filters quests based on level, type, and other criteria

### Architecture

- **continent-pins-separate.lua**: Main implementation file
  - Maintains separate pin pool to avoid conflicts with pfQuest's zone pins
  - Uses coordinate transformation to map zone positions to continent positions
  - Implements quest filtering logic

### Coordinate System

The addon uses a mapping table to convert between:
- Zone coordinates (0-100 within each zone)
- World coordinates (absolute position in game world)
- Continent coordinates (0-1 normalized position on continent)

### Known Limitations

- **World Map Disabled**: Two-continent world map view pins are disabled due to coordinate accuracy issues
- **Quest Data Accuracy**: Some quests may show in wrong locations due to incorrect data in pfQuest's database (e.g., "Vital Supplies" quest)
- **Project Epoch Specific**: Optimized for Project Epoch's custom content and may not work correctly on other servers
