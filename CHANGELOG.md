# Changelog

## [1.0.0] - 2024-09-15

### Added
- Initial release of pfQuest World Map for Project Epoch
- Continent-level quest pins for Eastern Kingdoms and Kalimdor
- Smart quest filtering (PvP, chicken quest, level-inappropriate)
- Coordinate transformation system for zone to continent mapping
- `/pfworld` command to force quest search

### Features
- Shows available quests on continent maps with yellow exclamation marks
- Hovers show quest information
- Performance optimized with pin limits (500 max)
- Separate pin pool to avoid conflicts with pfQuest zone pins

### Known Issues
- World map (two-continent view) pins disabled due to coordinate accuracy issues
- Some quests may show incorrect locations due to pfQuest database inaccuracies (e.g., "Vital Supplies")

### Technical
- Hooks into pfQuest's UpdateNodes function
- Uses zone boundary data for coordinate conversion
- Filters quests based on player level and quest type