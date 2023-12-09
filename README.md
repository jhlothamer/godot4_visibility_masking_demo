# Visibility Masking in Godot 4.1+
This demo shows how to create a visibility masking effect in Godot 4.1. This effect simulates the view cone of the player for a top down 2D game by masking out things not in the player's line of site. The classic horror survival game Darkwood is a great of example of this technique.

## Credit Where It is Greatly Deserved
The technique in this demo, and that I will attempt to explain below, was first brought to my attention in the video [Godot 4 visibility mask tutorial redux](https://www.youtube.com/watch?v=iKRJqx9KCJU). In this video the author shows roughly how to accomplish creating a visibility mask using the SubViewport node. In the video, tile maps with occluders are used, and separate copies of the tilemap are kept so that the main viewport and mask viewport can have something to render. This demo does away with any need to copy anything using a common technique for 2D split-screen games in the Godot engine.

## The General Idea

This technique uses a light along with light occluders to generate a light mask. This is done by using a light texture that matches the desired visibility area and a texture that is set to only be visible when it is lit. Placing this within a SubViewport node gives us access to a texture that we can then use as a mask.

<p align="center">
<img src="readme_images/mask_created_by_light.png" />
</p>

## Sharing World's Between SubViewports

In Godot we can set the world_2d properties of two or more SubViewports to the same World2D. This is done so that each viewport can see the same things but position their camera's at different locations, which is very handy in multi-player games.

<p align="center">
<img src="readme_images/subviewports_sharing_world_2d.png" />
</p>


What is nice about this technique is that game objects (nodes for Godot) only need to be placed under one of the SubViewports. This allows us to define the entire game level under one viewport and just link up the other viewports to the main viewport by sharing it's World2D.

We will use this fact to our advantage and have everything for the game world under one main viewport, and everything for the mask under another viewport. But these viewports will share a World2D, and so will see eachother's game objects.

## Controlling What a SubViewport "Sees"
Another useful thing about SubViewports is their Canvas Cull Mask property, which is a bitmask that sets what rendering layers they see. And this relates to the Visibility Layer bitmask in CanvasItem nodes (2D game objects in Godot).

In generating a visibility mask we want to designate one of the rendering layers to be seen by the masking Subviewport only. For the demo I used Layer 2 for this as Layer 1 is used by default by every CanvasItem. Layer 3 is reserved for things like enemies, which we only want to appear when they are in view and not part of a desaturated background. (More on this background later.)

<p align="center">
<img src="readme_images/rendering_layers.png" />
</p>

Now we only need to have light occluders that play a part in forming the view mask (i.e. blocking the players view) set to be in the second 2D render layer. They can, and usually will, be in other render layers as well.

## The Setup

Now that we've covered generating a mask with a light, sharing a World2D between SubViewports so we don't have to duplicate nodes and the fact that the only thing in the game world we need to be visible to the mask Subviewport are the light occluders, here's a diagram of how the game scene is setup.

<p align="center">
<img src="readme_images/game_level_setup.png" />
</p>

Note that the game level is it's own scene as you cannot edit nodes visually once they are under a Subviewport. Same is true for the mask SubViewport's child nodes.

We've covered everything in the above diagram except for maybe the TextureRect node. That is present so that the mask light will have something to light. It also has a CanvasItemMaterial added to it with the Light Mode set to Light Only. This means that the texture will only show up when it is lit, and that is what forms the mask.

## RemoteTransforms

What's left is setting up remote transforms between the player and the masking light, and the camera's in each of the subviewports.

In Godot this is easy as there is node called RemoteTransform2D. So, all we have to do is get a reference to the player node and add a RemoteTransform2D under it that references the masking light.

<p align="center">
<img src="readme_images/remote_transform_setup.png" />
</p>

The same must be done between the camera's in the main SubViewport and the masking SubViewport. This is easy to do because we can get a 2d camera from a viewport via it's get_camera_2d() function.

However, a camera's position isn't determined solely by it's position property. Other properties like Anchor Mode, Position Smoothing properties and limits play a role as well. Because of this, the demo duplicates the camera from the main SubViewport. Its also maintains the limit property values on each frame so that the actual camera positions between viewports will match.

Also note that if your game switches cameras or changes other properties, you'll need to contend with this as well.

## What's Seen Outside of the View

So far we've only considered masking out anything not in view. But what do we want to show outside of the view? Many games show a desaturated version of the game world, without certain elements like enemies and hazards. We can do this with another SubViewport that has it's Canvas Cull Mask set to show only things that are always visible (Layer 1 for this demo).

<p align="center">
<img src="readme_images/outside_view.png" />
</p>

To show the desaturated image in the background, all we need to do is place the SubViewportContainer wrapping the background SubViewport before the main SubViewport in the scene tree.

## Caveats and Issues

### 2D Lights not always Visible When Sharing World2D Between SubViewports

There is, what I would call, a bug when it comes to 2D lights and sharing World2D objects between SubViewport nodes.

Take these two SubViewport nodes, A and B. Note that they both have nodes that will need to be rendered.

<p align="center">
<img src="readme_images/lights_dont_reregister.png" />
</p>

In code we set SubViewport B's world_2d property to SubViewport A's property.

When this happens, all the visible elements that were originally part of SubViewport B's World2D move themselves to SubViewport A's World2D. If they did not, then they would not be drawn.

However, Light2D derived nodes do not do this. To work around this the demo removes and re-adds the masking light to the scene tree. When this is done, the light adds itself to the shared World2D.

Note: A bug has been created for this issue. At some point it may no longer be necessary to do this.

Alternately you could add the light directly to the game level and avoid the above work-around. However, in my opinion keeping things separate is better organization.

### SubViewportContainer Disrupts Mouse Enter/Exit
For some reason the mouse_entered/mouse_exited signals of any CollisionObject2D type node (Area2D, Character/Rigid/Static-Body2D) do not work correctly when the object is under a SubViewportContainer. The behavior I experienced from this was that the mouse_exited signal fires immediately after the mouse_entered signal even when the mouse has not actually exited.

A work around for this is possible. Rather than use a SubViewportContainer, instead use a regular Sprite2D along with a ViewportTexture. Then create a node that forwards events to the SubViewport by call it's push_event() function. This is pretty close to what the SubViewportContainer does for us but it allows the mouse signals to work.

The following is a script for a Node2D node that will do the event forwarding described above.


class_name subViewportInputShim
extends Node2D

var _sub_viewport: SubViewport

func _ready() -> void:
for child in get_children():
if child is SubViewport:
_sub_viewport = child
if _sub_viewport:
return
# we did not find a SubViewport child - don't process inputs
set_process_input(false)
set_process_unhandled_input(false)

func _input(event: InputEvent) -> void:
# forward event to SubViewport child
_sub_viewport.push_input(event)

func _unhandled_input(event: InputEvent) -> void:
# forward event to SubViewport child
_sub_viewport.push_input(event)


### ViewportTexture Shader Parameter Loses Path to SubViewport Node
For some reason, the node path of a ViewportTexture that is used as a shader parameter is sometimes changed to point to the scene's root node rather than the SubViewport node we set it to. This seems to happen when the scene that contains all the SubViewports are open and the game is started. This issue is present in Godot 4.1 and 4.2, though in 4.2 it happens less frequently.

When this happens the view masking will no longer work, and the game will look funny, like it has a pink semi-transparent texture over it. This is because, for some reason, this is what a ViewportTexture defaults to when it's not connected to an actual SubViewport node.


<p align="center">
<img src="readme_images/shader_param_viewport_texture_wrong.png" />
<img src="readme_images/shader_param_viewport_texture_correct.png" />
</p>

The fix is easy: just reset the node path.

Hopefully this will be fixed in a future release.


### Wavy View Mask
As you run the demo, you may notice something odd in the shadows created by the tree truncs and other view occluding things. The shadows waver back and forth. This does not occur when moving the character with the movement keys, but only when the mouse is moved so that the character and masking light are rotated.

<p align="center">
<img src="readme_images/vis_masking_wavy_shadows.gif" />
</p>

This issue is also present in the classic survival horror game Darkwood, though not as pronounced.

<p align="center">
<img src="readme_images/vis_masking_wavy_shadows_darkwood.gif" />
</p>

Since moving a light but not rotating it does not produce this waving effect, it should be possible to use one masking light to generate a shadow mask for the entire screen and then use a second light with shadows turned off to mask down to the view cone.













