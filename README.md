# Varnak Island
A TuJuJu Studios portrait 3D exploration prototype built in Godot 4.

## Open and play
1. Extract the entire ZIP to a normal folder.
2. Open Godot 4.5.1 or a compatible newer Godot 4 release.
3. Choose Import and select project.godot in the extracted folder.
4. Open the project and press F6 with main.tscn open, or F5 to run the project.
No external models, plugins or asset downloads are required.

## Controls
Phone: hold and drag in the bottom-left region to move. Swipe the right side to look. Approach a resident or collectible and tap Interact. Dialogue pauses movement. Scroll long panels vertically.
Desktop: WASD or arrow keys; hold the right mouse button and drag to look; E to interact. Escape closes panels.
The island is designed for portrait orientation, with a 480 x 854 reference layout. North is negative Z, along the light-colored main path. Signs say bei (north).

## Included
- Five contiguous areas: harbor, village, forest, river crossing and northern cove.
- Seven named residents and six connected quest objectives.
- Eight collectible objects and two wildlife observations.
- Varnak vocabulary, possession, movement, requests and evidential clues.
- Notebook with editable meaning guesses and optional meaning reveals.
- Inventory, island guide, automatic saving, manual restart confirmation.
- Procedural primitive 3D scenery with collision and deterministic tree placement.
- Wrong-answer feedback and shuffled evidence choices.

## Quest walkthrough
1. Pick up the brown bag beside Ena. Tell Ena Anni kel.
2. Collect wak, guro and kor beside the main path between harbor and village. Offer them to Mira.
3. Collect the blue kel west of the forest path. Offer it to Sanu.
4. Collect murak, sek and lin beside the path toward the river. Offer them to Tor.
5. Ask Tor about Neri. Talk to Lira in the village and Oren north of the crossing. Compare accounts. Tor's italpada is witnessed; Oren's italpashi is inferred; Lira's italpanu is reported.
6. Continue north to Neri at the cove.
Exploration is open. Finding Neri early acknowledges the discovery while leaving the clue objective available.

## Phone deployment
This ZIP is a source project, not an APK or iPhone app.
For Android, install Godot export templates matching your editor version, configure its Android SDK/JDK export environment, add an Android export preset, and export a debug APK to install on your device. Consult the current official instructions:
https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
For iOS, export/build/sign using macOS and Xcode:
https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html
Portrait layout reference:
https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
The project uses the Compatibility renderer to keep its graphics simple. Physical phone testing remains necessary, especially for touch gestures, safe areas, GPU performance and export configuration.

## Language decisions
Forms follow the supplied Varnak grammar's agreement and case tables. Normal dialogue joins morphemes; the notebook explains boundaries with plus signs. The inconsistent incorporated example in the document's introduction is not used. No new grammar rules are introduced.
Representative forms: anni kel (my bag); nalum (I go); talumo (Go!); tnaveno (Give it to me!); tekaru (to the village); tekama (in the village).
The arrival phrases use da, shi and nu for direct, inferred and reported evidence.
Residents' names are identifiers rather than vocabulary lessons.

## Current limits
This is a playable blockout, with simple models and short encounters. It does not yet include recorded Varnak speech, animated gestures, a broad dialogue generator, advanced sentence building, a simulated ecology, or a complete 50-root curriculum. Gestures are described in text. Bridge repair is represented through quest dialogue; the crossing remains traversable throughout. Walking time and six short quests are less than the previously proposed hour-long adventure.

## Verification
Imported and launched headlessly with Godot 4.5.1. The included smoke_test.gd checks all six quest completions, incorrect/correct evidence answers, inventory consumption, save/load and UI panel generation.
Run it with:
godot --headless --path . --script res://smoke_test.gd
The test writes a clean starting save after completion. Actual graphics and phone controls have not been visually or physically verified in this environment.

## Project structure
main.gd: world construction, movement, touch input, UI, quests and persistence.
main.tscn: entry scene.
project.godot: portrait display and rendering configuration.
smoke_test.gd: automated quest and persistence checks.
