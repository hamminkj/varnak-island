extends RefCounted
# Language data for Varnak Island. Every form here comes from the Varnak section of the
# Constructed-Language Handoff Document (attested examples, marked "doc" in VARNAK_CONTENT.md)
# or is composed strictly by that document's rules (marked "composed").

# Notebook glosses for words and morphemes added in this expansion.
const WORDS = {
	"var": "big (as a verb root, var also means show)",
	"mun": "door", "gira": "bridge", "tab": "table", "puka": "book", "mara": "field",
	"gor": "dog", "mar": "horse", "fal": "flower", "yamat": "food", "hen": "sky",
	"kelar": "traveler (kel + ar, habitual agent)", "an": "I (independent pronoun)", "ti": "you (independent pronoun)",
	"yan": "one", "vel": "two", "mur": "three", "kes": "four", "pan": "five",
	"nav": "warm", "gao": "tall / high", "hala": "fast, quickly",
	"lum": "go (root)", "pal": "see (root)", "nuk": "take / catch (root)", "por": "open (root)",
	"hep": "close (root)", "pav": "run (root)", "esh": "be located / exist (root)",
	"varn": "make / build (root)", "dar": "cook (root)", "ven": "give (root)",
	"tari-nuk": "to fish (tari + nuk: the noun is incorporated into the verb)",
	"hama": "where", "han": "what", "hal": "who",
	"-ma": "in / at / on (locative case)", "-ru": "to / for (allative-dative case)",
	"-ta": "from (ablative case)", "-li": "with / by means of (instrumental case)",
	"-ni": "of / possessor (genitive case)", "-ke": "the one acting on something (ergative case)",
	"-ir": "plural", "-du": "pair of / two (dual)", "-su": "together with (comitative case)",
	"-ven": "as far as (terminative case)", "-se": "as (essive case)",
	"-o": "command (imperative)", "-ye": "please (polite, after -o)",
	"ma- -ki": "not (negation, wraps around the verb)",
	"-ha": "question (yes/no, replaces the evidential)",
	"-im": "in progress (progressive)", "-ak": "completed (perfective)",
	"-pa": "past tense", "-da": "I know this directly (witnessed)",
	"-shi": "apparently (inferred)", "-nu": "reportedly (hearsay)"
}

# Nouns for the word workshop: root -> [singular, plural]
const NOUNS = {
	"teka": ["village", "villages"], "mora": ["river", "rivers"], "dom": ["house", "houses"],
	"sena": ["boat", "boats"], "gira": ["bridge", "bridges"], "mara": ["field", "fields"],
	"tab": ["table", "tables"], "kor": ["container", "containers"], "puka": ["book", "books"],
	"guro": ["fruit", "fruit"], "wak": ["water", "waters"], "tari": ["fish", "fish"],
	"par": ["bird", "birds"], "gor": ["dog", "dogs"], "mar": ["horse", "horses"],
	"fal": ["flower", "flowers"], "mun": ["door", "doors"], "murak": ["tree", "trees"]
}

# Workshop suffixes: suffix -> English frame. %s is the noun phrase.
const SUFFIXES = {
	"ma": "in the %s", "ru": "to the %s", "ta": "from the %s", "li": "with the %s",
	"su": "together with the %s", "ven": "as far as the %s", "se": "as the %s",
	"ni": "of the %s", "ir": "%s", "du": "a pair of %s"
}

# Sentence cards. gesture: what the speaker does. words: forms added to the notebook.
const SENTENCES = {
	"village_big": {"v": "Teka i-var.", "parts": "teka  i-var\nvillage  3S-be.big", "en": "The village is big.",
		"gesture": "Mira sweeps an arm across the rooftops, then spreads her hands wide.",
		"words": ["teka", "var"], "wrong": ["The village is small.", "The village is far away."]},
	"food_warm": {"v": "Yamat i-nav.", "parts": "yamat  i-nav\nfood  3S-be.warm", "en": "The food is warm.",
		"gesture": "Mira holds a hand over the steaming bowl.",
		"words": ["yamat", "nav"], "wrong": ["The food is old.", "The food is finished."]},
	"mira_cooks": {"v": "Mirake yamat i-dar-im-da.", "parts": "Mira-ke  yamat  i-dar-im-da\nMira-ERG  food.ABS  3P-cook-IPFV-DIR",
		"en": "Mira is cooking the food (I can see it).",
		"gesture": "Mira stirs the pot and points to her own eyes, then to you.",
		"words": ["dar", "-ke", "-im", "-da"], "wrong": ["Mira cooked the food long ago.", "The food is cooking Mira."]},
	"boat_small": {"v": "Sena i-sen.", "parts": "sena  i-sen\nboat  3S-be.small", "en": "The boat is small.",
		"gesture": "Ena pats the boat and pinches two fingers close together.",
		"words": ["sena", "sen"], "wrong": ["The boat is big.", "The boat is old."]},
	"path_safe": {"v": "Sava ruk.", "parts": "sava  ruk\nsafe  path", "en": "A safe path.",
		"gesture": "Sanu taps the ground, nods firmly, and points ahead.",
		"words": ["sava", "ruk"], "wrong": ["A long path.", "A dangerous path."]},
	"gira_safe": {"v": "Gira i-sava-da.", "parts": "gira  i-sava-da\nbridge  3S-be.safe-DIR", "en": "The bridge is safe (I know it directly).",
		"gesture": "Tor stamps on the planks and spreads both hands.",
		"words": ["gira", "sava", "-da"], "wrong": ["The bridge is broken.", "The bridge is safe (I heard)."]},
	"tor_built": {"v": "Torke gira i-varn-ak-pa-da.", "parts": "Tor-ke  gira  i-varn-ak-pa-da\nTor-ERG  bridge.ABS  3P-build-PFV-PST-DIR",
		"en": "Tor built the bridge (I witnessed it).",
		"gesture": "Tor mimes hammering, then points at you and at the planks.",
		"words": ["varn", "-ke", "-ak", "-pa"], "wrong": ["The bridge will be built by Tor.", "The bridge built Tor."]},
	"river_small": {"v": "Mora i-sen-im.", "parts": "mora  i-sen-im\nriver  3S-be.small-IPFV", "en": "The river is small right now.",
		"gesture": "Tor holds two fingers close together over the water.",
		"words": ["mora", "sen", "-im"], "wrong": ["The river is big.", "The river is far away."]},
	"dog_runs": {"v": "Gor i-pav-im.", "parts": "gor  i-pav-im\ndog  3S-run-IPFV", "en": "The dog is running.",
		"gesture": "Lira wiggles two fingers like running legs and laughs.",
		"words": ["gor", "pav", "-im"], "wrong": ["The dog is sleeping.", "The dog is big."]},
	"horse_fast": {"v": "Mar hala i-pav.", "parts": "mar  hala  i-pav\nhorse  fast  3S-run", "en": "The horse runs fast.",
		"gesture": "Oren flicks his fingers quickly across his palm.",
		"words": ["mar", "hala", "pav"], "wrong": ["The horse is tired.", "The horse ran away."]},
	"tree_tall": {"v": "Murak i-gao.", "parts": "murak  i-gao\ntree  3S-be.tall", "en": "The tree is tall.",
		"gesture": "Oren raises one hand high above his head.",
		"words": ["murak", "gao"], "wrong": ["The tree is old.", "The tree is dark."]},
	"fish_river": {"v": "Tari morama i-esh-da.", "parts": "tari  mora-ma  i-esh-da\nfish  river-LOC  3S-be.located-DIR", "en": "A fish is in the river.",
		"gesture": "A silver flash in the water; you see it yourself.",
		"words": ["tari", "mora", "-ma", "esh", "-da"], "wrong": ["A fish is from the river.", "A fish is in the container."]},
	"bird_sky": {"v": "Par henma i-esh-da.", "parts": "par  hen-ma  i-esh-da\nbird  sky-LOC  3S-be.located-DIR", "en": "A bird is in the sky.",
		"gesture": "The bird flutters up, and you watch it climb.",
		"words": ["par", "hen", "-ma", "esh"], "wrong": ["A bird is on the table.", "The bird is small."]},
	"book_table": {"v": "Puka tabma i-esh-da.", "parts": "puka  tab-ma  i-esh-da\nbook  table-LOC  3S-be.located-DIR", "en": "A book is on the table.",
		"gesture": "You see the book resting on the table.",
		"words": ["puka", "tab", "-ma", "esh"], "wrong": ["A book is in the container.", "The book is warm."]},
	"water_container": {"v": "Wak korma i-esh-da.", "parts": "wak  kor-ma  i-esh-da\nwater  container-LOC  3S-be.located-DIR", "en": "Water is in the container.",
		"gesture": "Mira tips the pitcher and the water fills the bowl.",
		"words": ["wak", "kor", "-ma", "esh"], "wrong": ["Water is on the table.", "The container is empty."]},
	"sign_north": {"v": "Bei-ru.", "parts": "bei-ru\nnorth-ALL", "en": "To the north.",
		"gesture": "The painted arrow on the signpost points up the light path.",
		"words": ["bei", "-ru"], "wrong": ["From the north.", "In the north."]},
	"sign_village": {"v": "Teka-ma.", "parts": "teka-ma\nvillage-LOC", "en": "In the village.",
		"gesture": "A carved board marks the edge of the village.",
		"words": ["teka", "-ma"], "wrong": ["To the village.", "From the village."]},
	"sign_river": {"v": "Mora-ven.", "parts": "mora-ven\nriver-TERM", "en": "As far as the river.",
		"gesture": "A board warns that the cleared path ends at the water.",
		"words": ["mora", "-ven"], "wrong": ["With the river.", "From the river."]},
	"gira_broken": {"v": "Gira ma-i-sava-ki-da.", "parts": "gira  ma-i-sava-ki-da\nbridge  NEG-3S-be.safe-NEG-DIR", "en": "The bridge is not safe (I can see it).",
		"gesture": "Planks are missing and a rail dangles. Tor frowns at the gap and shakes their head.",
		"words": ["gira", "sava", "ma- -ki"], "wrong": ["The bridge is very safe.", "The bridge is not long."]},
	"field_big": {"v": "Mara i-var.", "parts": "mara  i-var\nfield  3S-be.big", "en": "The field is big.",
		"gesture": "Rows of green stretch away from you.",
		"words": ["mara", "var"], "wrong": ["The field is small.", "The field is dry."]}
}

# Door puzzles, one per house. situation is a gesture; options are Varnak commands.
const DOORS = {
	"house1": {"situation": "Warm light spills around the shut door. Someone inside waves, urging you to come in.",
		"options": ["Mun t-i-por-o!", "Mun t-i-hep-o!", "Ma-t-i-por-o-ki!"], "correct": 0,
		"words": ["mun", "por", "-o"],
		"right": "Mun t-i-por-o! means Open the door! The ending -o makes a command and replaces tense.",
		"wrong": "Think about what the person inside wants. Check the notebook for por (open) and hep (close)."},
	"house2": {"situation": "A hand-painted sign shows a polite bow. The resident only answers courteous requests.",
		"options": ["Mun t-i-por-o", "Mun t-i-por-o-ye", "Mun ma-t-i-por-o-ki"], "correct": 1,
		"words": ["mun", "por", "-ye"],
		"right": "Mun t-i-por-o-ye means Please open the door. The polite suffix -ye follows -o.",
		"wrong": "A plain command works, but this resident wants the polite ending that follows -o."},
	"house3": {"situation": "You hear soft breathing. The resident holds a finger to their lips and points to a sleeping child: Sanu i-sul-im-da.",
		"options": ["Mun t-i-por-o!", "Mun t-i-hep-o!", "Ma-t-i-por-o-ki!"], "correct": 2,
		"words": ["mun", "por", "ma- -ki"],
		"right": "Ma-t-i-por-o-ki! means Do not open it! Negation wraps the verb: ma- at the start and -ki after the command ending.",
		"wrong": "Someone is sleeping. Which command forbids opening? Negation uses ma- before and -ki after the verb."},
	"house4": {"situation": "The door stands open and a cold wind blows out. The resident shivers and gestures toward the doorway.",
		"options": ["Mun t-i-hep-o!", "Mun t-i-por-o!", "Ma-t-i-hep-o-ki!"], "correct": 0,
		"words": ["mun", "hep", "-o"],
		"right": "Mun t-i-hep-o! means Close the door! The prefix t- is you acting, and i- is it receiving the action.",
		"wrong": "The door is already open and it is cold. Which root means close?"}
}

# Where-questions: a resident asks Ti hama ta-esh-ha? and you answer by place.
const WHERE = {
	"lira": {"options": ["An tekama na-esh-da.", "An morama na-esh-da.", "An senama na-esh-da."], "correct": 0,
		"place": "the village (teka)", "gesture": "Lira spreads her arms at the rooftops and asks, eyebrows raised."},
	"tor": {"options": ["An tekama na-esh-da.", "An morama na-esh-da.", "An senama na-esh-da."], "correct": 1,
		"place": "the river (mora)", "gesture": "Tor motions at the water and asks, eyebrows raised."}
}

# Practice prompts for phrases (sentence id list used by the practice menu).
const COUNTS = {
	"cairn": {"noun": "sek", "n": 3, "numword": "mur", "en": "stones", "wrongs": ["vel", "pan"]},
	"flowers": {"noun": "fal", "n": 4, "numword": "kes", "en": "flowers", "wrongs": ["yan", "mur"]},
	"basket": {"noun": "guro", "n": 5, "numword": "pan", "en": "fruit", "wrongs": ["vel", "kes"]}
}

const SUMMARY_NOTE = "Forms marked (doc) appear in the handoff document; others are composed from its rules."
