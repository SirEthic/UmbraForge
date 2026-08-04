# UmbraForge

UmbraForge is a grounded, purely 2D puzzle-platformer built in Godot 4.6. The core hook of the game is: **"Shadows are Solid Matter."**

## Core Mechanics
The player navigates levels that are otherwise impassable by dynamically creating their own collision platforms out of the shadows cast by level geometry.
The gameplay revolves around controlling two separate entities (or switching between modes):
1. **The Character:** A grounded, 2D physics-based character affected by gravity.
2. **The Drone (Light Source):** An omnidirectional 2D point light. The player flies this drone around the room to cast shadows from static or movable objects.

## Technical Showcase
The primary technical hurdle of this project is the real-time dynamic generation of `CollisionPolygon2D` data based on light-occluder geometry.
- **ShadowColliderGenerator:** A highly optimized script that mathematically extrudes back-facing silhouettes from `LightOccluder2D` objects based on the Drone's position.
- **Enterprise Physics:** The generated shadow colliders are fed into a synchronized `AnimatableBody2D`, preventing player entombment, snagging, and physics server crashes.

## Running the Prototype
1. Open Godot 4.6 (or compatible 4.x Forward Plus version).
2. Import the `UmbraForge` folder.
3. Open `scenes/levels/prototype.tscn`.
4. Press **F5** to run the prototype.

**Controls:**
- **A / D**: Move left and right
- **W / Space**: Jump
- **TAB**: Switch control between the Player and the Drone
- **ESC**: Quit
