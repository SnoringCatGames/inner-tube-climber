extends Node
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# - Problem: With current multiplier setup, the player is rewarded for going
#   slower, since they can get the multiplier to a higher value earlier in the
#   level.
#   - We instead want to reward the player for going as fast as possible.
#   - Possible ways to refactor the multiplier:
#       - Only have the cooldown relate to time spent on a given platform
#         elevation.
#       - Reset the multiplier whenever the player touches a lower platform
#         than the previous platform.
#       - Landing back on the same platform we jumped from, or on another
#         platform at the same height, doesn't affect the cooldown.
# 
# - 
#   - Suggest switching to slower or faster tier after enough falls on a level,
#     or enough levels without a fall.
#   - Make difficulty selectable in Settings, and make auto suggestion for
#     changing difficulty be toggleable in Settings too.
# 
# - Refactor level:
#   /- Count the number of deaths within the current playthrough of the current
#     tier.
#   /- Count the number of tiers climbed without dying.
#   - Add stubs for triggering popups suggesting changing difficulty.
#   - Implement the popups for for suggesting changing difficulty.
#     - Include two buttons in each: "Dismiss" and "Update difficulty".
#   - Create a concept of a zoom amount for each tier.
#     - Configure this with the tier definitions.
#     - Set the camera zoom accordingly within level when switching tiers.
#     - Have the zoom change animate.
#   - Change how base-level case is handled.
#     - Don't encode in config.
#     - Auto-append when starting level.
#     - Change tier ratio display values to show index + 1 as numerator.
#   - Consolidate some logic between Level._start_new_level and
#     Level._on_entered_new_tier.
# 
# - Fix bug where player can double-jump if second jump is very quickly after 
#   first.
# 
# - Make wall-bounce give more extra vertical speed.
# 
# - Make new sound effects:
#   - For button press, that is more subtle.
#     - Still use the old one on start-game press though.
#   - For game over (lost all lives), that is different than fall sound effect.
#     - Dies irae?
#   - Foot-snow-crunching sound effect when walking.
#   - Hard-ice-tapping sound effect when walking on ice.
#   - For move-sideways event triggering.
#     - Will help inform player when switching directions.
#   - For "move_left" / "move_right" just pressed.
#   - For _on_last_tier_completed.
#   - Multiplier value increased.
#   - Multiplier value reset.
# 
# - Implement Level._on_final_tier_completed()
#   - Trigger a new sound effect.
#   - Implement an animation effect? Confetti?
#   - A message?
#   - Animate tier ratio (e.g. 7/7).
# 
# - Consider refactoring into stuck zoom animation to instead just use the
#   zoom_multiplier on LevelConfig for TIERS[0].
# 
# - Pause screen
#   - Restart level
#   - Exit to main menu.
#   - Skip to tier?
#   - Show current height/time/falls and best height/time/falls.
#   - Show level number/name.
#   - Show current tier number within level (Tier 7/10)?
#   - Explain score calcualtion.
# 
# - Level-select screen
#   - Show best heights and times for completed levels
#   - Lock future levels
#     - The next level requires beating the previous level (with any rating)
#     - Have a couple locked bonus levels that require beating all levels with
#       A rating, or with A+ rating, to unlock.
#   - Give a rating for the user's best time on each level.
#     - A, B, C?
#     - Or gold, silver, bronze
#     - Give a plus/other-indicator to the rating if the user didn't die at all
#       during their run.
#     - Give another indicator to the rating if the user ever looped through
#       the level 3 total times (independent of fall-count rating).
#   - 
# 
# - Settings menu
#   - Toggle visibility of mobile control display pads.
#   - Toggle which moblie control version is used.
#   - Toggle haptic feedback (only on Android).
#   - Toggle hard mode.
#     - Or just remove hard mode entirely?
#   - Change sensitivity of gestures.
#     - Make it a slider.
#     - Don't label with a unit, other than more/less sensitive.
#     - Flat multiplier? Or quadratic?
#   - Have settings persist to local storage.
#   - Toggle sfx; toggle music.
#   - The difficulty setting and/or Time.physics_framerate_multiplier.
#   - Toggle debug panel visible.
#   - Set starting lives count.
#   - Set scroll-speed-up rate and max.
#   - Toggle whether the auto-difficulty update suggestion popups appear.
#   - Toggle whether framerate-multiplier/difficulty automatically track to the
#     current climb speed.
#   - Set how many camera-speed indices are decremented when falling.
#   - Toggle whether score, height, lives, level tier completion ratio, and
#     multiplier boards are shown.
#   - Toggle whether max-height indicators are shown along sides of screen.
# 
# - Replace main menu button text with icons
#   - Both somewhat pixelated
#   - "Start game" -> tuber jumping
#   - "Settings" -> gear
#   - Also, try to replace text in other menus. In general, I want this to not
#     use much text, so it can be accessible to international audiences.
# 
# - Refactor all panels:
#   - Add support to handle Android back button.
#   - What about iOS? Create a new on-screen back button? Include that same
#     back button for Android? Is it possible to tell the Android OS when to
#     hide the nav buttons at the bottom of the screen?
#   - Create the settings panel.
#   - Update credits panel to mention Copyright Levi, all rights reserved.
#   - Refactor UtilityPanel:
#     - Remove old thing.
#     - Use SettingsScreen instead.
#     - Create a static, always present icon/button at the top-right of the
#       screen.
#       - Gear symbol?
#       - Pause symbol?
#     - This will pause the game and open _some_ screen, from which the user
#       can navigate to other screens or resume playing.
#   - Test how to get the nav bar to appear on android and whether mobile
#     controls are ever likely to make it appear annoyingly by accident.
# 
# - Update CanvasLayers to support some layers rendering within game area, and
#   some within entire viewport.
# 
# - Add-back ability to collide with tier gaps:
#   - The problem is that collisions get weird with tier-gap-walled-to-open.
#   - Will need to check many more alternate TileMaps in surface contact update.
# 
# - When resetting tier after a fall (or, actually, even just starting any
#   non-zero tier), set initial camera pan to be lower down.
#   - And maybe also only start scroll after first input.
# 
# - Change how speed-up works:
#   - Configure a speed for each tier within the level tier-collection.
#   - Then, also configure a level-loop speed-up multiplier, that is applied to
#     each tier in the level on the next loop, and then again on the next, and
#     so on.
#   - Make sure this level-loop speed-up multiplier happens on a log scale, so
#     that it doesn't become quickly impossible.
# 
# - Change max-height indicators to be pixel images.
# 
# - Create a special tutorial level.
#   - Pause the level at the start of each tier and show an explanatory
#     info-graphic overlay that can be x-ed out with a button in the top-left
#     corner.
#   - Explain one concept per tier.
#   - Make each tier short and simple.
#   - Explain concepts in the info-graphics, and also during tier gameplay,
#     with radial highlights and arrows.
#   - Show a very transparent black screen behind the info-graphic overlay.
#   - Info-graphics can also show player moving through a sequence with arrows.
# 
# - In general, make all tiers a lot easier if you know the trick for how to
#   approach the tier.
# 
# - Change score to accumulate between deaths.
#   - Maybe count current elevation separately.
#   - Then can make score more complicated, subracting deaths, including a
#     multiplier for speed, etc.
#     - Maybe, we should do something else for score...:
#       - We want to allow some number of resets/falls.
#       - We want to keep the scroll accelerating, but maybe slow a little on
#         each fall.
#       - Maybe it's easy, just give X (3?) lives per level attempt.
#         - Then can still slow scroll a bit on each death, and we don't need
#           to worry too much about how to adjust score, and/or even force an
#           end condition.
#       - But then also have a hard-mode with one life, and faster initial
#         speed, but slower acceleration.
# - Fix scroll speed bug.
#   - Also, maybe have speed decrease after each death.
# - Make scroll speed configurable from the main menu.
# - Configurable frame rate/difficulty from main menu.
# - Add intro animation.
# - Add a pause feature.
#   - In the pause menu, allow the player to quit back to the main menu.
#   - Auto-save progress through each tier to local storage, so the user can
#     resume there on next load?
# - Possible to add levels with lots of sideways movement and camera panning.
#   Probably conditionally lock camera horizontal pan.
#   - Theme-wise, we can eventually make the player escape the crevasse and
#     start climbing up the mountain.
#   - We can show trees and mountain range in the background.
#   - Idk if there's something clever we can do to make the inner-tubing
#     continue to make sense at this point though... why would they care to do
#     more than escape the crevasse?
#   - And then, what is the end goal? Is there something they get at the top of
#     the mountain? Or just the beautiful view?
#   - How do we then make it loop?
#     - Maybe, show a cut-scene after the final mountain-ascent tier, once
#       they've reached the summit.
#     - Show a flag, show a beautiful sun-rise, show them stop and finally free
#       themselves from their inner tube (maybe with a tool or with some help?),
#       then show them start tubing down the mountain again, and repeat the
#       intro animation in order to loop back to the start tier.
# - Make the wall-bounce-vertical-boost more consistent/predictable; don't want
#   it to be better to bounce near bottom of jump instead of top.
# - Add a delay after falling before restarting.
# - Make a tier te emphasize the slipperiness of ice (mostly snow, but fail on
#   ice  near the top, must jump to bounce off wall).
# - Make a tier to emphasize dynamic jump height.
# - Make a tier to emphasize fast scroll speed.
#   - Lots of zig zagging on ground tiles (that can't be jumped through).
#   - Maximum bouncing for speeeeeed!
# - Mobile control idea: touch either corner to move sideways, swipe slightly
#   up on either to jump.
# 
# Long-term planning:
# - Maybe have a set sequence of tiers per-day? Per week? Per month?
#   - Randomly shuffle?
#   - Pre-generate for the whole year, at least.
# - Or have a set of pre-made levels, with their own tier sequences, each
#   showing the ascent art transition and summit animation.
#   - Could show a different flag color for each level.
#   - Anything else interesting to differentiate, art-wise?
#   - Clearly, difficulty of levels should change.
# - Show a leaderboard for each level, and also for the current special/rotating
#   level.
#   - Leaderboard should show a couple things:
#     - Farthest climbed without dying.
#       - Or score?
#     - Fastest ascent through one cycle of the level.
#   - Show username, and their score/speed.
# 
# [30]- Add ability to unlock the bounce jump and the double jump.
#   - Add a flag to tier configs that states whether that tier needs/unlocks
#     it.
#   - Then, just remember in level whether any tier yet has unlocked it.
#   - When a new tier arrives that unloks it, show the key indicator for using
#     it.
#   [30]- Create new tiers to take advantage of these.
# >- Take screenshot?
# [2hr]- Add more intro animations.
# >- Take screenshot?
# - Add an unlock for face-plant-bounce-off-tube-higher-jump after a certain
#   tier.
# - Add an unlock for double jump after a certain tier.
# >- Take screenshot?
# - Balance volumes of sfx and music.
# - Create alternate art for foreground and background for different tiers, in
#   order to add more variety.
# - Increase music playback speed when camera pan speed increases.
# - Polish tilemap tile choices, since autotile isn't working.
# - Fix localStorage usage for high score.
# - Add shading to the tuber player animations.
# - Add an animation to shake the screen on game over.
# 
# 
# - Add support for logging stats over the network to a backend.
#   - Do I need to get user permissions for that?
#     - Or is it sufficient to post a EULA?
#   - Things to log:
#     Utils.get_screen_ppi(),
#     Utils.get_viewport_ppi(),
#     OS.get_screen_dpi(),
#     IosResolutions.get_screen_ppi(),
#     get_viewport().size.x,
#     get_viewport().size.y,
#     OS.get_screen_scale(),
#     OS.get_screen_size(),
#     OS.window_size,
#     OS.get_real_window_size(),
#     OS.get_name(),
#     OS.get_model_name(),
#     OS.get_window_safe_area (),
#   - Research legal/app-store requirements around this.
# - Add internationalization.
#   - Research what my options are for this.
# 
###############################################################################

func _enter_tree() -> void:
    Global.register_main(self)
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    Nav.create_screens()

func _ready() -> void:
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)
    # Start playing the default music for the menu screen.
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
