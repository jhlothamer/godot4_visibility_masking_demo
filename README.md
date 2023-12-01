# Visibility Masking in Godot 4.1+
This demo shows how to create a visibility masking effect in Godot 4.1.  This effect simulates the view cone of the player for a top down 2D game by masking out many things not in the player's line of site.  The classic horror survival game Darkwood is a great of example of this technique.

## Credit Where It is Greatly Deserved
The technique in this demo, and that I will attempt to explain below, was first brought to my attention in the video [Godot 4 visibility mask tutorial redux](https://www.youtube.com/watch?v=iKRJqx9KCJU).  In this video the author shows roughly how to accomplish creating a visibility mask using the SubViewport node.  In the video, tile maps with occluders are used, and separate copies of the tilemap are kept so that the main view and mask view can have something to render.  (This may have only to demonstrate the technique, but I do not recall the author stating that or not.)  This demo does away with any need to copy anything using a common technique for 2D split-screen games in the Godot engine.

## What We Trying to Accomplish




