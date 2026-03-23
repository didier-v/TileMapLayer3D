DOCUMENTATION IS A WORK IN PROGRESS. FOR NOW SEE BELOW THE HIGHLIGHT OF EACH RELEASE. 
PROPER DOCUMENTATION WILL BE DONE AT SOME POINT.

## **Version 0.8.0** - New Features - Sculpt Mode and Smart Fill Mode
Version 0.8.0 Summary
- New Sculpt Mode for brush-based terrain painting with volume generation
- New Smart Fill sub-mode with Ramp Fill operation (with optional side fill)
- Restructured Smart Select into a new Smart Operations mode with sub-modes
  
### New Feature: Sculpt Mode
- A new Sculpt Mode that lets you paint terrain using brushes and quickly raise or lower height to create 3D volumes of tiles. 
- Tiles are auto-resolved to match the desired shape, making it much easier to build large terrains.
- For now, the Sculpt Mode only works on the Y Axis (Floor), as that is the common axis for Terrain Generation.

How to use the Sculpt Mode:
- Select a Tile in the TileSetPanel. Ensure the Camera/Editor is looking at the Floor Plane (Facing Y Axis)
- Draw — Click and drag to paint the brush pattern onto the floor grid
- Confirm — Release to lock the pattern in place
- Set Height — Click on the pattern and drag up/down to raise or lower the volume

Sculpt Mode - Generation Options:
- Brush Size — Adjustable radius for all brush shapes
- Draw Top — Toggle top (ceiling) tile generation on/off (default: on)
- Draw Base — Toggle bottom (floor) tile generation on/off (default: off)
- Flip Sides — Flip face orientation for wall tiles
- Flip Top — Flip face orientation for top tiles
- Flip Bottom — Flip face orientation for bottom tiles

Sculpt Brush Shapes:
- Diamond (default) — Creates organic volumes with triangle tiles at the boundaries
- Square — Creates rectangular grid volumes

### New Feature: Smart Operations Mode
- The previous Smart Select mode has been restructured into a new Smart Operations mode with two sub-modes:

Smart Select (updated)
- Pick individual tiles, flood-fill by matching UV, or flood-fill all connected neighbours
- Now correctly picks up tiles with custom transforms (e.g., tiles placed by Smart Fill Ramp)

Smart Fill Mode (new)
- A new sub-mode for quickly filling areas with tiles and creating connections and ramps between two points.
- Currently includes one operation: Smart Fill — Ramp Fill: Creates ramps that connect any two tiles by generating a tilted surface between them. 
- Allow to change the Width of created Ramps and also to fill sides to create "Prism-Like" Ramps.

How to use the Smart Fill Mode:
- Ensure you have a UV/Tile selected in the TileSet panel
- 1st Click - Set the start tile — the tile where the ramp begins
- 2nd Click - set the end tile — the tile where the ramp ends
- The ramp is automatically generated with a live preview shown between clicks

Fill Ramp Options:
- Fill Width — Control how many tiles wide the ramp is (1 = single column, 2+ = multi-column)
- Growth Direction — Symmetric, anchor left (grow right), or anchor right (grow left)
- Flip Face — Reverse tile face orientation
- Ramp Sides — Automatically generate ramp side walls to enclose the ramp

## **Version 0.7.0** - New Feature - ANIMATED TILES

- This feature works with the concept of an Animation Frame. A frame is not a single tile; it is a region of your tileset that can span multiple tiles. You select the entire area of your animation in the tileset, then tell the plugin how to subdivide it into frames using Rows and Columns.

- For example, if your tileset has a 2×2 waterfall texture that animates across 4 steps laid out horizontally, you would select the full 8×2 tile region and set: Columns = 4, Rows = 1, Frames = 4. Each frame will be a 2×2 block of tiles. The animation cycles through these frames automatically.

- How to use it:
1. Switch to Animated Tiles mode in the top toolbar
2. Select the full tile region in the tileset that contains all animation frames
3. Set Rows / Columns to define how the region is subdivided into frames
4. Set total frames to play (can be less than Rows × Columns to skip trailing slots)
5. Set Speed — playback rate
6. Click "New" to save the animation definition
7. Select it from the list and paint in the 3D viewport. Tiles animate immediately

## **Version 0.6.0** - Multiple important updates and refactors.

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


## **Version 0.5.0** - New UI, Toolbar and Data model (If you use versions before 0.4, this will break old scenes). Migrate to 0.4 first then to 0.5

## **Version 0.4.0** - Major update with 3D mesh modes, SpriteMesh integration, and optimized storage.
