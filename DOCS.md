DOCUMENTATION IS A WORK IN PROGRESS. FOR NOW SEE BELOW THE HIGHLIGHT OF EACH RELEASE. 
PROPER DOCUMENTATION WILL BE DONE AT SOME POINT.


**Version 0.8.0** - New Features - Sculpt Mode and Smart Fill Mode

**Version 0.7.0** - New Feature - ANIMATED TILES

- This feature works with a concept of a Animation Frame. A frame is not a single tile, it is a region of your tileset that can span multiple tiles. You select the entire area of your animation in the tileset, then tell the plugin how to subdivide it into frames using Rows and Columns.

- For example, if your tileset has a 2×2 waterfall texture that animates across 4 steps laid out horizontally, you would select the full 8×2 tile region and set: Columns = 4, Rows = 1, Frames = 4. Each frame will be a 2×2 block of tiles. The animation cycles through these frames automatically.

- How to use it:
1. Switch to Animated Tiles mode in the top toolbar
2. Select the full tile region in the tileset that contains all animation frames
3. Set Rows / Columns to define how the region is subdivided into frames
4. Set total frames to play (can be less than Rows × Columns to skip trailing slots)
5. Set Speed — playback rate
6. Click "New" to save the animation definition
7. Select it from the list and paint in the 3D viewport. Tiles animate immediately

**Version 0.6.0** - Multiple important updates and refactors.

UI Updates:
- Revamped UI: Left Toolbar is now the main toolbar; Bottom Toolbar becomes a Context Panel showing controls relevant to each mode
- TilePlacer Panel moved to the lower editor area for more texture display space
- New Zoom and Pan controls in the Tile Selection screen
- Mode switching now via Main Toolbar buttons on the left
<img width="745" height="716" alt="image" src="https://github.com/user-attachments/assets/200fd05a-5cdb-4e22-a7ff-7fc09926d9a0" />


New mode: Smart Select: Raycast-based tile selection that finds regular, rotated, and tilted tiles with precision. Includes three selection modes:
- Single Pick - Select individual tiles (additive — clicking more tiles adds to the selection)
- Connected UV - Selects all tiles on the same Grid Plane that share identical UV/texture
- Connected Neighbor - Selects all tiles on the same Grid Plane regardless of texture

Smart Select Operations:
- Delete - Remove/Delete all tiles in selection
- Replace UV/Texture - Replace selected tiles' texture with the current TileSet panel selection


**Version 0.5.0** - New UI, Toolbar and Data model (If you use versions before 0.4, this will break old scenes). Migrate to 0.4 first then to 0.5

**Version 0.4.0** - Major update with 3D mesh modes, SpriteMesh integration, and optimized storage.
