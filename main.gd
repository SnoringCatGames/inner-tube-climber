extends Node2D
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# - Add handing candles/sconces around tier-ratio signs:
#   - Create candle pixel art.
#   - Use a particle system to render the flame.
#   - Have the flame emit light.
#     - Orangish colored.
#     - Have this light also render on the player (unlike the light emitting
#       from the player).
#   - Use a separate particle system for occasional random sparks falling
#     downward from candle.
#   - Configure a concept of windiness in each level, and have this affect the
#     direction of the flame and sparks.
#     - windiness_multiplier
#     - Configure as a simple float on each tier and level; sign indicates
#       direction.
#     - Also have this affect snow fall that will be implemented later.
# 
# - Consider adding a noise system for swirly fog effects in the gloom screen.
#   - Then use a related fluidy noise system for swirling snow fall?
# 
# - Consider adding a super-fancy depth-based lighting in the style of
#   Terraria?
#   - "Block lighting"
#   - Re-read shading docs:
#     https://docs.godotengine.org/en/stable/tutorials/shading/index.html
#   - Decide if there are any other places to use custom shader logic.
#   - Use a separate thread.
#   - Watch this video and consider their techniques:
#     https://www.youtube.com/watch?v=NEHMJwt7oUI
#     - Read comments for improvements?
# 
# - Add particle systems:
#   - https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
#   - Snow spray effect from feet when jumping, landing, walking.
#   - Ice spray effect when bouncing on wall.
# 
# - PROBLEM: Walk into wall, tap jump, tap repeatedly into wall, ascend
#   infinitely.
#   - POSSIBLE SOLUTIONS:
#     - BAD: Make it so that wall-bounce vertical boost only ever happens once
#       per jump (would break bouncing up tubes).
#     - OK: Make it so that wall-bounce vertical boost can't happen on the same
#       surface twice in a row in the same jump.
#     - BETTER: Force a minimum horizontal speed when bouncing, which should
#       prevent the player from being able to make it back to the same wall at
#       a higher position than before.
# 
# - Create a couple new platform types:
#   - They crumble away after a short delay after being landed on.
#   - Create a version for both snow platforms and ice platforms (not for solid
#     ground tiles).
#   - This will require detecting all tiles in a given platform.
#     - Should be easy though, given all my custom surface-parsing logic.
#   - Will need to create crumble start, build, and fall-away animations.
#   - Will need to dynamically update TileMap.
#   - Update multiplier cooldown to be dynamic depending on the type of tile
#     being walked on?
#     - Want it to at least represent the time remaining until a platform would
#       crumble.
#     - This could just mean making all multiplier cooldowns match the
#       crumble-tile duration.
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
#   - Test out adding a very subtle sound effect for each score-board tween
#     number update.
#   - For landing on a crumble tile.
#   - For a crumble tile about to collapse (maybe just a long sfx that lasts
#     for the entire crumble tile duration).
#   - For a crumble tile falling away.
# 
# - Create additional animations for various events:
#   - Bouncing off wall?
#     - Radiating circle pulse?
#   - Landing-on/jumping-off snow?
#     - Spray/circular-sector-outward-triangle-shape of snow dots?
#   - Vibrate screen when falling?
#     - Or just on gameover?
#   - Do something special on game over.
#   - Reaching next tier.
#     - Confetti?
#     - 
#   - _on_final_tier_completed
#     - A message?
#   - Snow-falling effect.
#     - Have this appear on specific level+tier configs.
#     - Have different parameters or types for this:
#       - Number of flakes
#       - Size of flakes
#       - Speed of flakes
#       - Direction of flakes
#       - Amount of random course deviation for flakes
#       - Can then emulate strong wind flurries with fast, sideways, straight
#         trajectories, vs calm with fat flakes, slow, downward, and lots of
#         deviation.
#   - Also, animate the cooldown text with a single pulse of red, each time the
#     multiplier value changes.
#   - Add lighting effects to animations.
# 
# - Add wood-grain texture to gesture buttons.
# 
# - Change max-height indicators to be pixel images?
# 
# - Test on iOS:
#   - Ability to save/load scores and game state.
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
# - Add some logic to conditionally suggest changing difficulty (as a sticky
#   setting) from the game-over screen, depending on recent performance.
#   - Suggest switching to slower or faster tier after enough falls on a level,
#     or enough levels without a fall.
#   - Make difficulty selectable in Settings, and make auto suggestion for
#     changing difficulty be toggleable in Settings too.
# 
# - In general, make all tiers a lot easier if you know the trick for how to
#   approach the tier.
# 
# - Create a fun Christmasy level, with new tile art with Christmas light
#   strands.
#   - Make these actually act as light emitting sources.
#   - Add a cover of a classic Christmas song.
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
# - Theme-wise, we can eventually make the player escape the crevasse and start
#   climbing up the mountain.
#   - Use tiers with lots of horizontal panning at this point.
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
# - Make new tiers:
#   - Emphasize the slipperiness of ice (mostly snow, but fail on ice near the
#     top, must jump to bounce off wall).
#   - Emphasize dynamic jump height.
#   - Emphasize fast scroll speed.
#     - Lots of zig zagging on ground tiles (that can't be jumped through).
#     - Maximum bouncing for speeeeeed!
#   - Emphasize camera_horizontally_locked=false (and with zoom).
#   - Emphasize crumbling platforms.
#   - Emphasize the increased jump height from wall bounce.
#   - Emphasize windiness decreasing and increasing horizontal jump distance.
#   - Emphasize windiness decreasing and increasing vertical jump distance.
#   - Emphasize thick fog hiding the tier / level.
#   - Emphasize thick snow hiding the tier / level.
#   - Showcase all the different LevelConfig properties:
#     - Fog colors (super dark; sunset tinted).
#     - Fog opacity (super thick; high and low contrast between primary and
#       secondary opacities).
#     - Light energy.
#     - Snow density.
# - Mobile control idea: touch either corner to move sideways, swipe slightly
#   up on either to jump.
# 
# - Fix/redo player art:
#   - Make art at new x1.5 size, so we don't have scaling artifacts.
#   - Add shading to the animation.
#   - Fix inner-tube perspective.
#   - ...
# 
# - Add a new fade-out border along margins:
#   - Use a repeated pixel image.
#   - Use dithering.
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
# - Settings menu
#   - Toggle whether the auto-difficulty update suggestion popups appear.
#   - Change sensitivity of gestures.
#     - Make it a slider.
#     - Don't label with a unit, other than more/less sensitive.
#     - Flat multiplier? Or quadratic?
# 
# - Explain score calculation?
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
# 
# - Add ability to gradually transition tier config values over the final X
#   pixels of the tier, before we reach the next tier.
# 
# - Have level config affect _POST_STUCK values (not just tier config).
# 
# --- Old TODOs from the jam: -------------------------------------
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
#   - Replace any additional text with icons?
# 
# - Figure out how to persist save game state to the cloud through Android and
#   iOS APIs?
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
    Audio.cross_fade_music( \
            Audio.MAIN_MENU_MUSIC_PLAYER_INDEX, \
            true)
