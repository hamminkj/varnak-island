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
Desktop: W/S walk, A/D sidestep, left/right arrows turn; click and drag (or hold the right mouse button and drag) to look; walk close to an object or person, then click it or press E to interact. Escape closes panels.
The island is designed for portrait orientation, with a 480 x 854 reference layout. North is negative Z, along the light-colored main path. Signs say bei (north).

## Included
- Five contiguous areas: harbor, village, forest, river crossing and northern cove, plus a farm field and paddock east of the village.
- Seven named residents and six connected quest objectives.
- Eight collectible objects, four animals (bird, fish, dog, horse) and about thirty things to examine.
- Varnak vocabulary, possession, movement, requests and evidential clues, extended with case suffixes, ergative marking, imperatives, negation, questions and noun incorporation from the Varnak handoff document.
- Four house doors, each a small puzzle in commands: open, please open, do not open, close.
- Follow-up questions for every resident, a phrasebook of collected sentences, a word workshop for case endings, and practice quizzes.
- Counting piles with the Varnak number words, fishing with noun incorporation, signs that teach case endings.
- A bridge that is visibly broken until Tor's repair, and a table that is laid after Mira's meal.
- Notebook with editable meaning guesses, optional meaning reveals and mastery marks.
- Inventory, island guide, automatic saving, manual restart confirmation.
- Procedural 3D scenery: sky, sun with shadows, animated water, detailed houses, boat and bridge, trees, grass, flowers, butterflies, clouds, and characters with idle animation.
- Wrong-answer feedback and shuffled answer choices.

## Quest walkthrough
1. Pick up the brown bag beside Ena. Tell Ena Anni kel.
2. Collect wak, guro and kor beside the main path between harbor and village. Offer them to Mira.
3. Collect the blue kel west of the forest path. Offer it to Sanu.
4. Collect murak, sek and lin beside the path toward the river. Offer them to Tor.
5. Ask Tor about Neri. Talk to Lira in the village and Oren north of the crossing. Compare accounts. Tor's italpada is witnessed; Oren's italpashi is inferred; Lira's italpanu is reported.
6. Continue north to Neri at the cove.
Exploration is open. Finding Neri early acknowledges the discovery while leaving the clue objective available.

## Playing in a browser
The game is published at https://hamminkj.github.io/varnak-island/ from the committed
build in docs/. To update it after changing the game, re-export and commit:

    godot --headless --export-release "Web" docs/index.html

Godot needs the matching web export templates installed. The export preset has thread
support switched off, which GitHub Pages requires because it cannot send the headers
that threaded builds need.

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
Forms added in the expansion are listed in VARNAK_CONTENT.md, marked either as appearing in the handoff document or as composed from its rules, so they can be reviewed in one place. All language data lives in data.gd.
Representative forms: anni kel (my bag); nalum (I go); talumo (Go!); tnaveno (Give it to me!); tekaru (to the village); tekama (in the village).
The arrival phrases use da, shi and nu for direct, inferred and reported evidence.
Residents' names are identifiers rather than vocabulary lessons.

## Current limits
This is a playable blockout, with simple models and short encounters. It does not yet include recorded Varnak speech, animated gestures, a broad dialogue generator, advanced sentence building, a simulated ecology, or a complete 50-root curriculum. Gestures are described in text. The crossing remains traversable throughout, although its planks are visibly broken until Tor repairs it. Walking time and six short quests are less than the previously proposed hour-long adventure.

## Verification
Imported and launched headlessly with Godot 4.5.1. The included smoke_test.gd checks all six quest completions, incorrect/correct evidence answers, inventory consumption, save/load and UI panel generation. It also checks that every sentence card, door, counting pile, fishing step, workshop and practice screen works, that every Varnak form used has a notebook gloss, and that every interactable can be used.
Run it with:
godot --headless --path . --script res://smoke_test.gd
The test writes a clean starting save after completion. Graphics were checked in software-rendered screenshots; phone controls and real-device performance have not been tested.

## Project structure
main.gd: world construction, movement, input, UI, quests, interactions and persistence.
art.gd: procedural models (characters, houses, boat, bridge, animals, items) and the water and ground shaders.
data.gd: Varnak sentences, door puzzles, word workshop data and glosses.
VARNAK_CONTENT.md: every form added in the expansion, with its source in the handoff document.
export_presets.cfg: web export preset (single-threaded, required by GitHub Pages).
docs/: the exported web build that GitHub Pages serves.
.github/workflows/deploy-pages.yml: optional workflow that exports and deploys from GitHub Actions.
main.tscn: entry scene.
project.godot: portrait display and rendering configuration.
smoke_test.gd: automated quest and persistence checks.
