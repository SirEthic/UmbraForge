# UmbraForge - Game Design & Technical Context

## Overview
**UmbraForge** is a grounded, purely 2D puzzle-platformer designed to run efficiently on low-end hardware (integrated graphics). 
The core hook of the game is: **"Shadows are Solid Matter."**

The player navigates levels that are otherwise impassable (too wide, too high, or filled with hazards) by dynamically creating their own collision platforms out of the shadows cast by level geometry.

## The Dual-Control Core Loop
The gameplay revolves around controlling two separate entities (or switching between modes):
1. **The Character:** A grounded, 2D physics-based character. Affected by gravity. Can walk, jump, and push small objects.
2. **The Drone (Light Source):** An omnidirectional 2D point light. Unaffected by gravity. The player flies this drone around the room to cast shadows from static or movable objects.

**The Loop:**
- **Observe:** The player sees a gap they cannot cross.
- **Manipulate Light:** The player moves the Drone. As the light hits a solid column or pushed crate, a shadow is cast across the gap.
- **Generate Platforms:** The 2D shadow dynamically becomes a physical collision polygon in the game engine.
- **Traverse:** The player switches back to the Character and walks across the newly formed "shadow bridge."
- **Puzzle Solving:** The player must sequence light movements, push physical crates to create new shadow casters, and avoid trapping themselves. Moving the light while standing on the shadow can act as an elevator or a moving platform.

## Progression & Advanced Mechanics
As the player progresses, new mechanics keep the puzzles fresh:
- **Movable Casters:** Pushing crates into the perfect position so their shadow creates a necessary ramp.
- **Moving Lights:** Lights on pendulums or tracks create moving shadow platforms.
- **Multiple Lights:** Two light sources overlapping will cancel a shadow out. Players must carefully overlap lights to carve "holes" through solid shadow walls.
- **Colored Lights (Material Properties):** A Red Light might cast a shadow that acts as a trampoline (high restitution), while a Blue Light casts a slippery shadow (zero friction).

## Technical Implementation (Godot Architecture)
This game is designed to be built in Godot Engine using purely 2D systems.

### Generating Collision from Shadows
The technical challenge and showcase of this project is turning lighting data into physics data in real-time.
1. **Light & Occluders:** Use Godot's built-in `Light2D` and `LightOccluder2D` to generate the visual shadows.
2. **Raycasting / Geometry Calculation:** 
   - Option A: Write a GDScript algorithm that calculates the polygon of the shadow by projecting rays from the `Light2D` origin past the vertices of the occluders.
   - Option B: If Godot exposes the 2D lighting shadow map data, use it to generate the points. (Usually, manual vertex projection math from the light source against occluder polygons is the most reliable way to get a clean `PackedVector2Array`).
3. **Collision Polygon Generation:** Feed the calculated shadow vertices into a `CollisionPolygon2D` node. 
4. **Real-time Updates:** Update this collision shape dynamically every frame (or only when the light/occluder moves) to allow for "shadow elevators" and moving platforms.

## Goals for Antigravity (agy)
When running `agy` in this folder, the assistant should reference this document to understand:
- The game is purely 2D.
- The visual and physical mechanics rely heavily on Godot's 2D lighting and collision systems.
- The tone is mechanical, puzzle-focused, and highly systemic.
- The primary technical hurdle is the dynamic generation of `CollisionPolygon2D` data based on light-occluder geometry.
