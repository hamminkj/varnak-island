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
	"-shi": "apparently (inferred)", "-nu": "reportedly (hearsay)",
	# second expansion: places, people, body, directions, numbers 6 to 10
	"kur": "market", "senak": "school", "sang": "mountain / hill", "hai": "sea", "panak": "bread",
	"cha": "tea", "yok": "medicine (here, a healing herb)", "far": "fire", "fardom": "lighthouse (far + dom: fire-house)",
	"wak-kor": "water container, a well (wak + kor)", "sulum": "bed", "yesh": "night",
	"sair": "person", "sanu": "child (also a name: Sanu)", "senar": "teacher", "ravar": "student",
	"dau": "head", "mal": "hand", "ten": "foot", "tong": "pain",
	"nam": "south", "dong": "east", "sai": "west", "aru": "far side",
	"luk": "six", "set": "seven", "bar": "eight", "gov": "nine",
	"rav": "read (root)", "mai": "buy (root)", "mai-ai": "sell (root)", "tar": "bring (root)",
	"sum": "swim (root)", "ser": "rain (root)", "ning": "sing (root); also song", "nang": "walk (root)", "sul": "sleep (root)",
	"ret": "hot", "len": "cold", "ling": "bright", "dam": "dark", "seng": "happy", "dun": "short", "ho": "good",
	"ki": "this", "e": "and", "polu": "all, everyone", "hamur": "how many",
	"-ur": "usually, as a habit (habitual)", "-fu": "future tense", "-ng": "begins to (inceptive)",
	"-tir": "cause to, make (causative)", "u-": "more (comparative, before the root)",
	"puka-rav": "read books (puka + rav: the noun is incorporated into the verb)",
	"mora-ni aruma": "beyond the river (mora-ni aru-ma: on the river's far side)",
	# third expansion
	"riya": "sun", "yue": "moon", "sao": "star", "yar": "day", "salma": "dawn", "monar": "morning", "wanar": "evening",
	"sa": "he, she, it (independent pronoun)", "hai-sao": "sea star (hai + sao)", "-ve": "ordinal ending (yan-ve: first)",
	"yanve": "first", "velve": "second", "murve": "third", "kesve": "fourth", "panve": "fifth", "lukve": "sixth", "setve": "seventh", "barve": "eighth",
	"gin": "money, coins", "har": "thank (root)", "maki": "no", "dor": "land", "sendor": "the small island (sen dor: small land)",
	"gan": "room", "shan": "rear, behind (after -ni)", "men": "front (after -ni)", "dal": "side (after -ni)", "pai": "paper",
	"tal": "arrive (root)", "shora": "old", "nava": "young / new",
	"ansu": "with me (an + su)", "na-": "I (subject prefix)", "ta-": "you (subject prefix)", "i-": "he, she, it (subject prefix)",
	"ri-": "they (subject prefix)", "k-": "I (agent prefix, before the patient prefix)", "t-": "you (agent prefix)",
	"kin": "we (including you)",
	# fifth expansion: gossip and nonsense
	"mel": "speak, talk (root)", "dap": "answer (root)", "zen": "know (root); also true", "mong": "forget (root)",
	"kar": "come (root)", "wai": "bad", "dan": "but", "haku": "why", "hal-ta": "from whom? (hal + ta)", "ket": "chair",
	"yir": "clothing", "par": "bird (as a verb root, par means fear)",
	"yam": "eat (root); also salt and voice", "tovu": "story",
	"sela": "alone", "cha-kor": "teapot (cha + kor)", "-ai": "antipassive: doing something in general (pal-ai: look around)",
	"ha": "ha (a laugh)", "sir": "look for, search (root)",
	"palar": "friend", "fau": "false", "lei": "tired", "ber": "illness",
	"ti-ni": "your (ti + ni)", "ti-ru": "to you (ti + ru)",
	"ning-guro": "song-berry (ning + guro): a glowing berry that makes you speak in poems",
	"sao-dau": "star-head mushroom (sao + dau): a glowing mushroom that makes you speak in strange poems",
	"-en": "who / that (relative clause ending: i-ning-im-en par, the bird that is singing)",
	"-ka": "and then (same subject keeps going)", "shi (if)": "if (after the clause)"
}

# Glosses that replace earlier ones because the document gives a second meaning.
const GLOSS_UPDATES = {
	"dar": "cook (root); also the number ten",
	"mar": "horse (as a stative root, mar means full)",
	"kor": "container (as a verb root, kor means cross)",
	"an": "I (independent pronoun); as a verb root, an means be",
	"gao": "tall / high (as a verb root, gao means tell)",
	"tar": "bring (root); also top (after -ni)"
}

# Nouns for the word workshop: root -> [singular, plural]
const NOUNS = {
	"teka": ["village", "villages"], "mora": ["river", "rivers"], "dom": ["house", "houses"],
	"sena": ["boat", "boats"], "gira": ["bridge", "bridges"], "mara": ["field", "fields"],
	"tab": ["table", "tables"], "kor": ["container", "containers"], "puka": ["book", "books"],
	"guro": ["fruit", "fruit"], "wak": ["water", "waters"], "tari": ["fish", "fish"],
	"par": ["bird", "birds"], "gor": ["dog", "dogs"], "mar": ["horse", "horses"],
	"fal": ["flower", "flowers"], "mun": ["door", "doors"], "murak": ["tree", "trees"],
	"kur": ["market", "markets"], "senak": ["school", "schools"], "sang": ["hill", "hills"],
	"hai": ["sea", "seas"], "panak": ["bread", "loaves"], "far": ["fire", "fires"],
	"fardom": ["lighthouse", "lighthouses"], "sair": ["person", "people"], "ravar": ["student", "students"],
	"sulum": ["bed", "beds"], "dau": ["head", "heads"], "mal": ["hand", "hands"], "ten": ["foot", "feet"]
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
		"words": ["mara", "var"], "wrong": ["The field is small.", "The field is dry."]},
	# ---- second expansion ----
	"ketu_sells": {"v": "Ketuke panak i-mai-ai-ur-da.", "parts": "Ketu-ke  panak  i-mai-ai-ur-da\nKetu-ERG  bread.ABS  3P-sell-HAB-DIR", "en": "Ketu usually sells bread.",
		"gesture": "Ketu pats the loaves on the stall, then sweeps a hand across the market as if to say every day.",
		"words": ["mai-ai", "panak", "-ur", "-ke"], "wrong": ["Ketu bought bread yesterday.", "Ketu is eating bread."]},
	"buy_bread": {"v": "Anke panak k-i-mai-fu.", "parts": "an-ke  panak  k-i-mai-fu\n1SG-ERG  bread.ABS  1A-3P-buy-FUT", "en": "I will buy bread.",
		"gesture": "The shopper jingles a few coins and nods toward the loaves.",
		"words": ["an", "panak", "mai", "-fu"], "wrong": ["I bought bread.", "Give me bread!"]},
	"tea_hot": {"v": "Cha i-ret.", "parts": "cha  i-ret\ntea  3S-be.hot", "en": "The tea is hot.",
		"gesture": "Steam curls from the cup. The shopper blows on it and fans their mouth.",
		"words": ["cha", "ret"], "wrong": ["The tea is cold.", "The tea is gone."]},
	"well_full": {"v": "Wak-kor i-mar-da.", "parts": "wak-kor  i-mar-da\nwater-container  3S-be.full-DIR", "en": "The well is full (I can see it).",
		"gesture": "Water brims right up to the stone rim.",
		"words": ["wak-kor", "mar", "-da"], "wrong": ["The well is empty.", "The horse is drinking water."]},
	"students_read": {"v": "Ravarir ri-puka-rav-im-da.", "parts": "ravar-ir  ri-puka-rav-im-da\nstudent-PL  3PL.S-book-read-IPFV-DIR", "en": "The students are reading.",
		"gesture": "Two students bend over their books, lips moving.",
		"words": ["ravar", "-ir", "puka-rav", "-im"], "wrong": ["The students are running.", "The teacher is reading."]},
	"suri_teacher": {"v": "An senar na-an-da.", "parts": "an  senar  na-an-da\n1SG  teacher  1S-be-DIR", "en": "I am a teacher.",
		"gesture": "Suri taps her own chest, then points at the chalkboard.",
		"words": ["an", "senar"], "wrong": ["I am a student.", "You are a teacher."]},
	"rin_student": {"v": "An ravar na-an-da.", "parts": "an  ravar  na-an-da\n1SG  student  1S-be-DIR", "en": "I am a student.",
		"gesture": "Rin holds up a book and grins.",
		"words": ["an", "ravar"], "wrong": ["I am a traveler.", "She is a student."]},
	"hill_taller": {"v": "Sang murak-ta i-u-gao.", "parts": "sang  murak-ta  i-u-gao\nhill  tree-ABL  3S-COMP-tall", "en": "The hill is taller than the tree.",
		"gesture": "Pomo holds one hand at tree height, then lifts the other far above it.",
		"words": ["sang", "murak", "-ta", "u-", "gao"], "wrong": ["The tree is taller than the hill.", "The hill is as tall as the tree."]},
	"summit_highest": {"v": "Ki sang polu-ta i-u-gao.", "parts": "ki  sang  polu-ta  i-u-gao\nthis  hill  all-ABL  3S-COMP-tall", "en": "This hill is the highest of all.",
		"gesture": "A cairn marks the top. From here every roof on the island is below you.",
		"words": ["ki", "sang", "polu", "u-", "gao"], "wrong": ["This hill is very small.", "That hill is higher."]},
	"spring_hot": {"v": "Wak i-ret.", "parts": "wak  i-ret\nwater  3S-be.hot", "en": "The water is hot.",
		"gesture": "Steam drifts off the pool. You dip a finger and pull it back fast.",
		"words": ["wak", "ret"], "wrong": ["The water is cold.", "The water is deep."]},
	"sea_cold": {"v": "Hai i-len.", "parts": "hai  i-len\nsea  3S-be.cold", "en": "The sea is cold.",
		"gesture": "A swimmer wades out of the lagoon, shivering and hugging their arms.",
		"words": ["hai", "len"], "wrong": ["The sea is warm.", "The sea is far away."]},
	"desh_swims": {"v": "An haima na-sum-ur-da.", "parts": "an  hai-ma  na-sum-ur-da\n1SG  sea-LOC  1S-swim-HAB-DIR", "en": "I usually swim in the sea.",
		"gesture": "Desh points at the lagoon, mimes swimming strokes, then counts off several days on his fingers.",
		"words": ["hai", "-ma", "sum", "-ur"], "wrong": ["I swam in the river yesterday.", "Swim in the sea!"]},
	"child_sleeps": {"v": "Sanu sulumma i-sul-im-da.", "parts": "sanu  sulum-ma  i-sul-im-da\nchild  bed-LOC  3S-sleep-IPFV-DIR", "en": "The child is sleeping in the bed.",
		"gesture": "A small child is curled up under a blanket. Vira puts a finger to her lips.",
		"words": ["sanu", "sulum", "-ma", "sul", "-im"], "wrong": ["The child is running to the bed.", "The child is not sleeping."]},
	"lighthouse_dark": {"v": "Fardom i-dam-da.", "parts": "fardom  i-dam-da\nlighthouse  3S-be.dark-DIR", "en": "The lighthouse is dark (I can see it).",
		"gesture": "The lamp room at the top is cold and grey.",
		"words": ["fardom", "dam"], "wrong": ["The lighthouse is bright.", "The lighthouse is short."]},
	"lighthouse_bright": {"v": "Fardom i-ling-da.", "parts": "fardom  i-ling-da\nlighthouse  3S-be.bright-DIR", "en": "The lighthouse is bright (I can see it).",
		"gesture": "A golden beam sweeps across the water.",
		"words": ["fardom", "ling"], "wrong": ["The lighthouse is dark.", "The lighthouse is broken."]},
	"no_fire": {"v": "Far ma-i-esh-ki-da.", "parts": "far  ma-i-esh-ki-da\nfire  NEG-3S-exist-NEG-DIR", "en": "There is no fire (I can see it).",
		"gesture": "Yalo points up at the dark lamp and turns his empty hands over.",
		"words": ["far", "esh", "ma- -ki"], "wrong": ["The fire is hot.", "Bring the fire!"]},
	"night_light": {"v": "Yeshma fardom i-ling-ur-da.", "parts": "yesh-ma  fardom  i-ling-ur-da\nnight-LOC  lighthouse  3S-be.bright-HAB-DIR", "en": "At night the lighthouse usually shines.",
		"gesture": "Yalo closes his eyes as if sleeping, then opens his hands wide like a beam of light.",
		"words": ["yesh", "fardom", "ling", "-ur"], "wrong": ["In the morning the lighthouse is dark.", "At night the lighthouse fell down."]},
	"rain_starts": {"v": "I-ser-ng.", "parts": "i-ser-ng\n3S-rain-INCH", "en": "It is beginning to rain.",
		"gesture": "The fisher holds a palm up to the clouds and squints.",
		"words": ["-ng"], "wrong": ["It rained yesterday.", "The sun is shining."]},
	"ila_happy": {"v": "Ila i-seng-da.", "parts": "Ila  i-seng-da\nIla  3S-be.happy-DIR", "en": "Ila is happy (I can see it).",
		"gesture": "Ila sips the tea and smiles broadly.",
		"words": ["seng"], "wrong": ["Ila is tired.", "Ila is sad."]},
	"sign_market": {"v": "Kur-ru.", "parts": "kur-ru\nmarket-ALL", "en": "To the market.",
		"gesture": "The arrow on the board points west down a wide path.",
		"words": ["kur", "-ru"], "wrong": ["From the market.", "In the market."]},
	"sign_school": {"v": "Senak-ru.", "parts": "senak-ru\nschool-ALL", "en": "To the school.",
		"gesture": "The arrow points toward a long building with a blue roof.",
		"words": ["senak", "-ru"], "wrong": ["From the school.", "The school is big."]},
	"sign_hill": {"v": "Sang-ru.", "parts": "sang-ru\nhill-ALL", "en": "To the hill.",
		"gesture": "The arrow points up a steep trail.",
		"words": ["sang", "-ru"], "wrong": ["From the hill.", "As far as the hill."]},
	"sign_east": {"v": "Dong-ru.", "parts": "dong-ru\neast-ALL", "en": "To the east.",
		"gesture": "The arrow points down a long road toward the morning sun.",
		"words": ["dong", "-ru"], "wrong": ["To the west.", "From the east."]},
	"sign_light": {"v": "Fardom-ru.", "parts": "fardom-ru\nlighthouse-ALL", "en": "To the lighthouse.",
		"gesture": "A tall striped tower is painted on the board.",
		"words": ["fardom", "-ru"], "wrong": ["In the lighthouse.", "From the lighthouse."]},
	"sign_lagoon": {"v": "Hai-ru.", "parts": "hai-ru\nsea-ALL", "en": "To the sea.",
		"gesture": "Painted waves curl around the arrow.",
		"words": ["hai", "-ru"], "wrong": ["From the sea.", "With the sea."]},
	"sign_beyond": {"v": "Mora-ni aruma.", "parts": "mora-ni  aru-ma\nriver-GEN  far.side-LOC", "en": "Beyond the river.",
		"gesture": "The board points across the water to the far bank and the hill.",
		"words": ["mora-ni aruma", "-ni", "aru", "-ma"], "wrong": ["Beside the river.", "Behind the house."]},
	"stones_cross": {"v": "Mora t-i-kor-o!", "parts": "mora  t-i-kor-o\nriver  2A-3P-cross-IMP", "en": "Cross the river!",
		"gesture": "Flat stones lead across the water. Someone has painted a walking figure on the first one.",
		"words": ["mora", "kor", "-o"], "wrong": ["Do not cross the river!", "The river is crossing."]},
	"log_short": {"v": "Murak-gira i-dun.", "parts": "murak-gira  i-dun\ntree-bridge  3S-be.short", "en": "The log bridge is short.",
		"gesture": "Three logs span the water. You could cross in a few steps.",
		"words": ["murak", "gira", "dun"], "wrong": ["The log bridge is long.", "The log bridge is broken."]},
	# ---- third expansion ----
	"big_fish": {"v": "Var tari haima i-esh-da.", "parts": "var  tari  hai-ma  i-esh-da\nbig  fish  sea-LOC  3S-be.located-DIR", "en": "A big fish is in the sea (I saw it).",
		"gesture": "A huge grey back rises out of the waves, then a tail slaps the water.",
		"words": ["var", "tari", "hai", "-ma"], "wrong": ["A small fish is in the river.", "The boat is in the sea."]},
	"dog_with_me": {"v": "Gor ansu i-nang-im-da.", "parts": "gor  an-su  i-nang-im-da\ndog  1SG-COM  3S-walk-IPFV-DIR", "en": "The dog is walking with me.",
		"gesture": "The dog trots at your heels, tail wagging.",
		"words": ["gor", "ansu", "-su", "nang"], "wrong": ["The dog is walking to me.", "My dog is sleeping."]},
	"thank_you": {"v": "K-ta-har-da.", "parts": "k-ta-har-da\n1A-2P-thank-DIR", "en": "I thank you.",
		"gesture": "Someone takes your hand in both of theirs and bows.",
		"words": ["har", "k-"], "wrong": ["You thank me.", "Thank them!"]},
	"ruins_old": {"v": "Ki dom i-shora.", "parts": "ki  dom  i-shora\nthis  house  3S-be.old", "en": "This house is old.",
		"gesture": "Moss covers the broken columns. Oku pats one fondly.",
		"words": ["ki", "dom", "shora"], "wrong": ["This house is new.", "This house is big."]},
	"room_behind": {"v": "Var wak-ni shanma gan i-esh-nu.", "parts": "var  wak-ni  shan-ma  gan  i-esh-nu\nbig  water-GEN  rear-LOC  room  3S-be.located-REP", "en": "They say there is a room behind the big water.",
		"gesture": "Oku leans in and whispers, glancing toward the north-east hills.",
		"words": ["var", "wak", "-ni", "shan", "gan", "-nu"], "wrong": ["There is a big room in the water.", "I saw a room behind the house."]},
	"falls": {"v": "Wak hala i-lum-im-da.", "parts": "wak  hala  i-lum-im-da\nwater  fast  3S-go-IPFV-DIR", "en": "The water is going fast.",
		"gesture": "The waterfall roars down into the pool. Behind the spray, something is dark.",
		"words": ["wak", "hala", "lum", "-im"], "wrong": ["The water is cold.", "The water is not moving."]},
	"cave_glow": {"v": "Sek-ir ri-ling-da.", "parts": "sek-ir  ri-ling-da\nstone-PL  3PL.S-be.bright-DIR", "en": "The stones are shining.",
		"gesture": "Behind the waterfall is a hidden room. Blue crystals glow in the walls.",
		"words": ["sek", "-ir", "ri-", "ling"], "wrong": ["The stones are dark.", "The stone is heavy."]},
	"treasure_map": {"v": "Gin murak-ni shanma i-esh-da.", "parts": "gin  murak-ni  shan-ma  i-esh-da\nmoney  tree-GEN  rear-LOC  3S-be.located-DIR", "en": "The money is behind the tree.",
		"gesture": "An old pai (paper) shows a small island, one tree, and a cross on the far side of the tree from the dock.",
		"words": ["gin", "murak", "-ni", "shan", "-ma"], "wrong": ["The money is in front of the tree.", "The money is beside the stone."]},
	"islet_small": {"v": "Ki dor i-sen.", "parts": "ki  dor  i-sen\nthis  land  3S-be.small", "en": "This land is small.",
		"gesture": "The whole island fits between a few palm trees. Its name, Sendor, means small land.",
		"words": ["ki", "dor", "sen", "sendor"], "wrong": ["This land is big.", "That boat is small."]},
	"tamu_ferry": {"v": "An sena-li sendor-ru na-kel-ur-da.", "parts": "an  sena-li  sendor-ru  na-kel-ur-da\n1SG  boat-INS  small.island-ALL  1S-travel-HAB-DIR", "en": "I usually travel to the small island by boat.",
		"gesture": "Tamu pats the boat, points out to sea and paddles the air.",
		"words": ["sena", "-li", "sendor", "-ru", "kel", "-ur"], "wrong": ["I swam to the small island.", "The boat is going to the village."]},
	"gav_mail": {"v": "Anke polu-ru kel-ir k-ri-tar-ur-da.", "parts": "an-ke  polu-ru  kel-ir  k-ri-tar-ur-da\n1SG-ERG  everyone-DAT  bag-PL  1A-3PL.P-bring-HAB-DIR", "en": "I usually bring bags to everyone.",
		"gesture": "Gav shrugs a bulging satchel and waves at the whole island.",
		"words": ["polu", "-ru", "kel", "-ir", "tar", "-ur"], "wrong": ["Everyone brings bags to me.", "I lost a bag yesterday."]},
	"night_sky": {"v": "Yeshma sao-ir ri-ling-da.", "parts": "yesh-ma  sao-ir  ri-ling-da\nnight-LOC  star-PL  3PL.S-be.bright-DIR", "en": "At night the stars shine.",
		"gesture": "Pomo points up at the sky full of stars.",
		"words": ["yesh", "sao", "-ir", "ling"], "wrong": ["In the day the sun shines.", "The stars are falling."]},
	# ---- fifth expansion: strange things and silly events ----
	"odd_fish": {"v": "Tari wak-korma i-esh-da!", "parts": "tari  wak-kor-ma  i-esh-da\nfish  well-LOC  3S-be.located-DIR", "en": "A fish is in the well!",
		"gesture": "A fish pokes its head out of the well and stares at you. Nobody knows how it got there.",
		"words": ["tari", "wak-kor", "-ma"], "wrong": ["A fish is in the river.", "The well is full of fruit."]},
	"odd_chair": {"v": "Ket dom-ni tarma i-esh-da!", "parts": "ket  dom-ni  tar-ma  i-esh-da\nchair  house-GEN  top-LOC  3S-be.located-DIR", "en": "A chair is on top of the house!",
		"gesture": "A chair sits on the roof, facing the sea, as if someone likes the view.",
		"words": ["ket", "dom", "-ni", "tar", "-ma"], "wrong": ["A chair is in the house.", "A chair is behind the house."]},
	"odd_clothes": {"v": "Ketu-ni yir murakma i-esh-da!", "parts": "Ketu-ni  yir  murak-ma  i-esh-da\nKetu-GEN  clothing  tree-LOC  3S-be.located-DIR", "en": "Ketu's clothes are in the tree!",
		"gesture": "A bright shirt with Ketu's market stripes flaps from a high branch.",
		"words": ["yir", "-ni", "murak", "-ma"], "wrong": ["Ketu is in the tree.", "The tree is wearing a hat."]},
	"odd_book": {"v": "Puka haima i-esh-da!", "parts": "puka  hai-ma  i-esh-da\nbook  sea-LOC  3S-be.located-DIR", "en": "A book is in the sea!",
		"gesture": "A book bobs on the waves. The title says Suri-ni puka: Suri's book.",
		"words": ["puka", "hai", "-ma"], "wrong": ["A book is on the table.", "A fish is reading a book."]},
	"odd_bed": {"v": "Sulum morama i-esh-da!", "parts": "sulum  mora-ma  i-esh-da\nbed  river-LOC  3S-be.located-DIR", "en": "A bed is in the river!",
		"gesture": "A bed floats slowly down the river. There is still a pillow on it.",
		"words": ["sulum", "mora", "-ma"], "wrong": ["A boat is in the river.", "Someone is sleeping in the river."]},
	"odd_fruit": {"v": "Var guro rukma i-esh-da!", "parts": "var  guro  ruk-ma  i-esh-da\nbig  fruit  path-LOC  3S-be.located-DIR", "en": "A giant fruit is on the path!",
		"gesture": "A fruit as big as a cart blocks half the road. It smells wonderful.",
		"words": ["var", "guro", "ruk", "-ma"], "wrong": ["A small fruit is in the basket.", "A cart is on the path."]},
	"odd_teapot": {"v": "Cha-kor girama i-esh-da!", "parts": "cha-kor  gira-ma  i-esh-da\ntea-container  bridge-LOC  3S-be.located-DIR", "en": "A teapot is on the bridge!",
		"gesture": "A teapot balances on the bridge rail, still steaming.",
		"words": ["cha-kor", "gira", "-ma"], "wrong": ["A teapot is under the bridge.", "The bridge is hot."]},
	"fish_rain": {"v": "Tari-ir hen-ta ri-kar-im-da!", "parts": "tari-ir  hen-ta  ri-kar-im-da\nfish-PL  sky-ABL  3PL.S-come-IPFV-DIR", "en": "Fish are coming from the sky!",
		"gesture": "It is raining... fish. They flop on the grass and everyone stares.",
		"words": ["tari", "-ir", "hen", "-ta", "kar"], "wrong": ["Birds are coming from the sea.", "It is raining on the fish."]},
	"rolling_fruit": {"v": "Var guro hala i-pav-im-da!", "parts": "var  guro  hala  i-pav-im-da\nbig  fruit  fast  3S-run-IPFV-DIR", "en": "A giant fruit is running fast!",
		"gesture": "A giant fruit rolls down the main path. Everyone jumps out of the way.",
		"words": ["var", "guro", "hala", "pav"], "wrong": ["A small fruit is sleeping.", "The fruit is not moving."]}
}

# Village gossip. by: who tells it, about: who it is about, ev: how the teller knows.
# reply: what the person it is about says when you ask them.
const GOSSIP = [
	{"id": "oren_horse", "by": "lira", "about": "oren", "ev": "nu", "v": "Oren mar-ru i-mel-ur-nu.", "en": "People say Oren usually talks to his horse.",
		"gesture": "Lira leans close and whispers behind her hand.",
		"reply": {"v": "Maki! Mar anru i-mel-ur-da.", "en": "No! The horse usually talks to ME.", "gesture": "Oren folds his arms, offended on the horse's behalf."}},
	{"id": "tor_bridge", "by": "mira", "about": "tor", "ev": "shi", "v": "Tor girama i-sul-ur-shi.", "en": "Apparently Tor usually sleeps on the bridge.",
		"gesture": "Mira points to a pillow and a blanket left on the bridge planks.",
		"reply": {"v": "Gira i-sava-da! An girama na-sul-ur-da.", "en": "The bridge is safe! Yes, I sleep on the bridge.", "gesture": "Tor pats the planks proudly."}},
	{"id": "mira_food", "by": "ketu", "about": "mira", "ev": "da", "v": "Mira-ni yamat i-len-ur-da.", "en": "Mira's food is usually cold. I know it firsthand.",
		"gesture": "Ketu shivers dramatically and rubs his belly.",
		"reply": {"v": "Maki! Yamat i-nav! ...Yamat i-len-shi.", "en": "No! The food is warm! ...Apparently the food is cold.", "gesture": "Mira tastes the soup, frowns, and quietly puts the lid back on."}},
	{"id": "ketu_fish", "by": "tor", "about": "ketu", "ev": "nu", "v": "Ketu tari-ir-su i-mel-ur-nu.", "en": "They say Ketu talks with the fish.",
		"gesture": "Tor glances toward the market and taps his ear.",
		"reply": {"v": "Tari-ir i-ho! Ri-dap-ur-da.", "en": "The fish are good! They answer.", "gesture": "Ketu holds up a fish to his ear and nods seriously."}},
	{"id": "yalo_night", "by": "oren", "about": "yalo", "ev": "nu", "v": "Yalo yesh-ta i-par-ur-nu.", "en": "People say Yalo is afraid of the night.",
		"gesture": "Oren grins. A lighthouse keeper afraid of the dark!",
		"reply": {"v": "Maki! Fardom i-ling-da!", "en": "No! The lighthouse is bright!", "gesture": "Yalo glances nervously at the sunset and turns the lamp up a little more."}},
	{"id": "desh_sea", "by": "suri", "about": "desh", "ev": "da", "v": "Desh haima i-ning-ur-da.", "en": "Desh usually sings in the sea. I have seen it.",
		"gesture": "Suri covers her ears and laughs.",
		"reply": {"v": "Tari-ir ri-seng-ur-da!", "en": "The fish are happy when I do!", "gesture": "Desh plays a triumphant drum roll."}},
	{"id": "pomo_sleep", "by": "desh", "about": "pomo", "ev": "shi", "v": "Pomo sang-ma i-sul-ur-shi.", "en": "Apparently Pomo usually sleeps on the hill.",
		"gesture": "Desh imitates loud snoring drifting down from the lookout.",
		"reply": {"v": "Maki! An na-pal-ai-ur-da!", "en": "No! I look around all the time!", "gesture": "Pomo yawns enormously in the middle of saying it."}},
	{"id": "oku_stones", "by": "gav", "about": "oku", "ev": "nu", "v": "Oku sek-ir-su i-mel-ur-nu.", "en": "They say Oku talks with the stones.",
		"gesture": "Gav makes a spooky face and wiggles his fingers.",
		"reply": {"v": "Sek-ir ri-zen-da.", "en": "The stones know.", "gesture": "Oku smiles mysteriously. Somewhere, a stone seems to nod."}},
	{"id": "gav_food", "by": "vira", "about": "gav", "ev": "shi", "v": "Gavke kel-ir-ma yamat i-yam-ur-shi.", "en": "Apparently Gav eats the food in the bags.",
		"gesture": "Vira points at crumbs all over Gav's satchel.",
		"reply": {"v": "Maki! ...Yamat i-nav-pa.", "en": "No! ...The food was warm.", "gesture": "Gav wipes his mouth very quickly."}},
	{"id": "sanu_bag", "by": "ena", "about": "sanu", "ev": "da", "v": "Sanuke kel i-mong-ur-da.", "en": "Sanu always forgets the bag. I know it.",
		"gesture": "Ena rolls her eyes toward the forest path.",
		"reply": {"v": "Han kel?", "en": "What bag?", "gesture": "Sanu looks around, genuinely puzzled."}},
	{"id": "ola_fruit", "by": "rin", "about": "ola", "ev": "shi", "v": "Olake polu-ni guro i-nuk-ur-shi.", "en": "Apparently Ola takes everyone's fruit.",
		"gesture": "Rin points at Ola's very sticky fingers.",
		"reply": {"v": "Maki! ...Guro i-ho.", "en": "No! ...Fruit is good.", "gesture": "Ola hides something round behind her back."}},
	{"id": "vira_medicine", "by": "ila", "about": "vira", "ev": "da", "v": "Vira-ni yok i-wai-da.", "en": "Vira's medicine tastes bad. I know firsthand.",
		"gesture": "Ila sticks out her tongue and shudders.",
		"reply": {"v": "Yok i-wai, dan Ila i-seng-da!", "en": "The medicine is bad, but Ila is happy!", "gesture": "Vira shrugs, completely unbothered."}},
	{"id": "lira_story", "by": "pomo", "about": "lira", "ev": "da", "v": "Lirake polu-ni tovu i-gao-ur-da.", "en": "Lira tells everyone's stories. I have heard her.",
		"gesture": "Pomo points down the hill at the village and mimes a chattering mouth.",
		"reply": {"v": "Ho! Ki tovu i-ho!", "en": "Ha! This story is good!", "gesture": "Lira is already telling someone else."}}
]

# Rumor composer: pieces for open-ended sentences.
const RUMOR_PLACES = [["", "", ""], ["tekama", "in the village", ""], ["haima", "in the sea", ""], ["kurma", "at the market", ""], ["sang-ma", "on the hill", ""],
	["wak-korma", "in the well", "silly"], ["sulumma", "in bed", ""], ["girama", "on the bridge", ""], ["murakma", "in a tree", "silly"], ["fardomma", "in the lighthouse", ""], ["guro-ma", "inside a fruit", "silly"]]
# root: [base, -ing, past, he/she form]
const RUMOR_VERBS = {"sul": ["sleep", "sleeping", "slept", "sleeps"], "sum": ["swim", "swimming", "swam", "swims"], "ning": ["sing", "singing", "sang", "sings"],
	"pav": ["run", "running", "ran", "runs"], "nang": ["walk", "walking", "walked", "walks"], "mel": ["talk", "talking", "talked", "talks"],
	"tal": ["arrive", "arriving", "arrived", "arrives"], "sir": ["search", "searching", "searched", "searches"]}
const RUMOR_WHO = ["An", "Tor", "Mira", "Ketu", "Lira", "Oren", "Sanu", "Ena", "Suri", "Pomo", "Vira", "Yalo", "Desh", "Oku", "Gav", "Tamu", "Neri", "Gor", "Mar", "Par"]
const RUMOR_WHO_EN = {"An": "I", "Gor": "The dog", "Mar": "The horse", "Par": "The bird"}

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
	"basket": {"noun": "guro", "n": 5, "numword": "pan", "en": "fruit", "wrongs": ["vel", "kes"]},
	"rack": {"noun": "tari", "n": 6, "numword": "luk", "en": "fish drying", "wrongs": ["set", "pan"]},
	"loaves": {"noun": "panak", "n": 7, "numword": "set", "en": "loaves of bread", "wrongs": ["luk", "bar"]},
	"orchard": {"noun": "guro", "n": 8, "numword": "bar", "en": "fruit on the tree", "wrongs": ["set", "gov"]},
	"circle": {"noun": "sek", "n": 9, "numword": "gov", "en": "standing stones", "wrongs": ["bar", "dar"]},
	"garden": {"noun": "fal", "n": 10, "numword": "dar", "en": "flowers", "wrongs": ["gov", "luk"]}
}

# Pomo's direction questions from the hilltop. Answers use the locative -ma on a direction word.
const LOOKOUT = [
	{"q": "Fardom hama i-esh-ha?", "en": "Where is the lighthouse?", "gesture": "Pomo points across the whole island toward the striped tower where the sun rises.",
		"options": ["Dongma i-esh-da.", "Saima i-esh-da.", "Namma i-esh-da."], "correct": 0, "why": "dong is east, and dong-ma means in the east."},
	{"q": "Kur hama i-esh-ha?", "en": "Where is the market?", "gesture": "Pomo points down the hill toward the stalls, away from the north.",
		"options": ["Beima i-esh-da.", "Namma i-esh-da.", "Dongma i-esh-da."], "correct": 1, "why": "nam is south, the opposite of bei (north)."},
	{"q": "Hai hama i-esh-ha?", "en": "Where is the sea?", "gesture": "Pomo turns you around to face the nearest water, where the sun sets.",
		"options": ["Saima i-esh-da.", "Dongma i-esh-da.", "Beima i-esh-da."], "correct": 0, "why": "sai is west, where the sun sets."}
]

# Suri's lesson on question words. kind "meaning": pick the English meaning; "answer": answer in Varnak.
const SCHOOL = [
	{"q": "Halke puka i-rav-im-ha?", "gesture": "Suri points at Rin, who is reading, and raises her eyebrows.",
		"options": ["Who is reading the book?", "Where is the book?", "How many books are there?"], "correct": 0,
		"why": "hal means who. The question takes -ke because the reader acts on the book, and -ha replaces the evidential."},
	{"q": "Puka hama i-esh-ha?", "gesture": "Suri hides a book behind her back and looks around, puzzled.",
		"options": ["Who has the book?", "Where is the book?", "Is the book new?"], "correct": 1,
		"why": "hama means where. esh is be located, as in Puka tabma i-esh-da."},
	{"q": "Tike han t-i-rav-im-ha?", "gesture": "Suri points at the book in your hands and tilts her head.",
		"options": ["Why are you reading?", "Who are you?", "What are you reading?"], "correct": 2,
		"why": "han means what. Tike is you acting on something, and t-i- means you act on it."},
	{"q": "Hamur ravar i-esh-ha?", "gesture": "Suri sweeps a hand toward her students and waits for you to count them.",
		"options": ["Vel ravar i-esh-da.", "Mur ravar i-esh-da.", "Yan ravar i-esh-da."], "correct": 0,
		"why": "hamur means how many. There are two students, Rin and Ola, so vel."}
]

# Desh's lagoon game: follow the command. Each entry: command, gloss, the matching action, decoys.
const DESH = [
	{"v": "Ta-sum-o!", "en": "Swim!", "act": "You wade in and swim a few strokes.", "words": ["sum", "-o"]},
	{"v": "Ta-pav-o!", "en": "Run!", "act": "You run along the sand.", "words": ["pav", "-o"]},
	{"v": "Ta-ning-o!", "en": "Sing!", "act": "You sing a few notes.", "words": ["ning", "-o"]},
	{"v": "Ta-nang-o!", "en": "Walk!", "act": "You walk slowly along the shore.", "words": ["nang", "-o"]},
	{"v": "Ta-sul-o!", "en": "Sleep!", "act": "You lie down on the sand and close your eyes.", "words": ["sul", "-o"]},
	{"v": "Ma-ta-pav-o-ki!", "en": "Do not run!", "act": "You stand completely still.", "words": ["pav", "ma- -ki"]}
]

# Vira's patient. Ila mimes where it hurts; the player chooses what Ila would say.
const PAIN = {"gesture": "Ila presses both hands to her temples and winces.",
	"options": ["Anni dauma tong i-esh-da.", "Anni tenma tong i-esh-da.", "Anni malma tong i-esh-da."], "correct": 0,
	"why": "Anni dau-ma tong i-esh-da: pain is located in my head. dau is head, ten is foot, mal is hand."}

const SUMMARY_NOTE = "Forms marked (doc) appear in the handoff document; others are composed from its rules."


# Oku's riddles. Each clue is a short Varnak description; the answer is a noun.
const RIDDLES = [
	{"q": "Yarma henma i-esh-da. I-ret.", "en": "In the day it is in the sky. It is hot.", "options": ["riya", "yue", "sao"], "correct": 0,
		"why": "riya, the sun. yar-ma means in the day, hen-ma in the sky."},
	{"q": "Yeshma henma i-esh-da. I-var.", "en": "At night it is in the sky. It is big.", "options": ["sao", "yue", "riya"], "correct": 1,
		"why": "yue, the moon. Stars are out at night too, but they are small."},
	{"q": "Yeshma henma ri-esh-da. Ri-sen.", "en": "At night they are in the sky. They are small.", "options": ["yue", "par", "sao"], "correct": 2,
		"why": "sao, stars. The prefix ri- means they: there are many of them."},
	{"q": "Wakma i-esh-da. Ma-i-nang-ki-da.", "en": "It is in the water. It does not walk.", "options": ["gor", "tari", "mar"], "correct": 1,
		"why": "tari, a fish. ma- ... -ki wraps the verb to say not."},
	{"q": "I-gao. Par-ir sa-ma ri-esh-ur-da.", "en": "It is tall. Birds are usually in it.", "options": ["murak", "dom", "sena"], "correct": 0,
		"why": "murak, a tree. sa-ma means in it: pronouns take case endings too."}
]

# Parcels for Gav's deliveries: parcel id -> resident.
const PARCELS = {"parcel_ketu": "ketu", "parcel_yalo": "yalo", "parcel_oku": "oku"}

# Treasure mounds on the small island. The map says the money is behind the tree.
const MOUNDS = {
	"mound_front": {"v": "Murak-ni menma.", "en": "in front of the tree", "right": false},
	"mound_behind": {"v": "Murak-ni shanma.", "en": "behind the tree", "right": true},
	"mound_side": {"v": "Sek-ni dalma.", "en": "beside the rock", "right": false}
}

const ORDINALS = ["yanve", "velve", "murve", "kesve", "panve", "lukve", "setve", "barve"]

# Verb builder: choose one piece per slot. Forms are intransitive, so only the S prefix is used.
const VERB_SLOTS = [
	["Not?", ["", "ma-"]], ["Who", ["na-", "ta-", "i-", "ri-"]], ["Action", ["lum", "pav", "sul", "sum", "tal", "nang"]],
	["Aspect", ["", "-im", "-ak", "-ur"]], ["Tense", ["", "-pa", "-fu"]], ["Evidence", ["", "-da", "-shi", "-nu"]]
]
const VERBS = [
	["I go.", "na-lum"], ["I went.", "na-lum-pa"], ["You will go.", "ta-lum-fu"], ["He or she is running.", "i-pav-im"],
	["They usually swim.", "ri-sum-ur"], ["I am sleeping.", "na-sul-im"], ["She arrived (I saw it).", "i-tal-pa-da"],
	["They apparently arrived.", "ri-tal-pa-shi"], ["You reportedly arrived.", "ta-tal-pa-nu"], ["I am not going (I know it).", "ma-na-lum-ki-da"],
	["They will not run.", "ma-ri-pav-fu-ki"], ["He or she has arrived.", "i-tal-ak"], ["You are walking.", "ta-nang-im"],
	["I usually walk.", "na-nang-ur"], ["They will sleep.", "ri-sul-fu"]
]

# Sentence builder: tiles in neutral order, plus decoys with the wrong ending.
const TILES = [
	{"en": "I caught the fish.", "tiles": ["Anke", "tari", "k-i-nuk-ak-pa-da."], "decoys": ["An"], "tip": "The one who acts on something takes -ke: anke."},
	{"en": "The traveler arrived at the village.", "tiles": ["Kelar", "tekaru", "i-tal-ak-pa-da."], "decoys": ["Kelarke", "tekama"], "tip": "Arriving acts on nothing, so the traveler takes no -ke. To the village is teka-ru."},
	{"en": "Tor built the bridge.", "tiles": ["Torke", "gira", "i-varn-ak-pa-da."], "decoys": ["Tor"], "tip": "Building acts on the bridge, so Tor takes -ke."},
	{"en": "A book is on the table.", "tiles": ["Puka", "tabma", "i-esh-da."], "decoys": ["tabru"], "tip": "On or at is -ma; -ru means to."},
	{"en": "The dog is walking with me.", "tiles": ["Gor", "ansu", "i-nang-im-da."], "decoys": ["anni"], "tip": "With me is an-su; an-ni means my."},
	{"en": "Mira is cooking the food.", "tiles": ["Mirake", "yamat", "i-dar-im-da."], "decoys": ["Mira"], "tip": "Mira acts on the food, so Mira takes -ke."},
	{"en": "The hill is taller than the tree.", "tiles": ["Sang", "murak-ta", "i-u-gao."], "decoys": ["murak-ma"], "tip": "The thing you compare with takes -ta (from)."},
	{"en": "The child is sleeping in the bed.", "tiles": ["Sanu", "sulumma", "i-sul-im-da."], "decoys": ["sulumru"], "tip": "In the bed is sulum-ma."},
	{"en": "Please give me three fish.", "tiles": ["Mur", "tari", "t-na-ven-o-ye."], "decoys": ["Tarike"], "tip": "The number comes before the noun, and the command ends in -o-ye."},
	{"en": "My bag.", "tiles": ["Anni", "kel"], "decoys": ["An"], "tip": "The owner comes first and takes -ni."},
	{"en": "The water is in the container.", "tiles": ["Wak", "korma", "i-esh-da."], "decoys": ["korta"], "tip": "In is -ma; -ta means from."},
	{"en": "At night the stars shine.", "tiles": ["Yeshma", "sao-ir", "ri-ling-da."], "decoys": ["i-ling-da."], "tip": "Many stars are they, so the verb takes ri-."},
	# longer sentences unlock at higher levels (lv 2 and 3)
	{"lv": 2, "en": "The woman saw the child in the village.", "tiles": ["Rumake", "sanu", "tekama", "i-pal-pa-da."], "decoys": ["Ruma", "tekaru"], "tip": "The seer takes -ke, the one seen has no ending, the place takes -ma, and the verb comes last."},
	{"lv": 2, "en": "The traveler caught the fish at the river.", "tiles": ["Kelarke", "tari", "morama", "i-nuk-ak-pa-da."], "decoys": ["Kelar", "morata"], "tip": "Agent with -ke, then the fish, then the place with -ma, then the verb."},
	{"lv": 2, "en": "I gave the bread to Ketu.", "tiles": ["Anke", "panak", "Keturu", "k-i-ven-ak-pa-da."], "decoys": ["An", "Ketuma"], "tip": "To Ketu is Ketu-ru. Order: the one acting, the thing, the place or person it goes to, the verb."},
	{"lv": 2, "en": "Mira cooked the food in the village.", "tiles": ["Mirake", "yamat", "tekama", "i-dar-ak-pa-da."], "decoys": ["Mira", "i-dar-im-da."], "tip": "Cooked is finished and past: -ak-pa."},
	{"lv": 3, "en": "The child is sleeping in the village.", "tiles": ["Sanu", "tekama", "i-sul-im-da."], "decoys": ["Sanuke", "tekaru", "na-sul-im-da."], "tip": "Sleeping acts on nothing, so no -ke; he or she is i-."},
	{"lv": 3, "en": "The traveler went fishing.", "tiles": ["Kelar", "i-tari-nuk-ak-pa-da."], "decoys": ["Kelarke", "tari", "i-nuk-ak-pa-da."], "tip": "Fishing in general puts tari inside the verb, and then the traveler takes no -ke."},
	{"lv": 3, "en": "I usually travel to the small island by boat.", "tiles": ["An", "sena-li", "sendor-ru", "na-kel-ur-da."], "decoys": ["Anke", "sena-ma", "sendor-ta"], "tip": "By boat is -li, to the island is -ru, usually is -ur."},
	{"lv": 3, "en": "They say there is a room behind the big water.", "tiles": ["Var", "wak-ni", "shanma", "gan", "i-esh-nu."], "decoys": ["wak-ma", "i-esh-da."], "tip": "Behind something is X-ni shan-ma, and they say is the hearsay ending -nu."},
	{"lv": 3, "en": "Please give me medicine and tea.", "tiles": ["Yok", "e", "cha", "t-na-ven-o-ye."], "decoys": ["vo", "k-i-ven-o-ye."], "tip": "And is e. You give to me is t-na-ven, and please is -o-ye."},
	{"lv": 4, "en": "This hill is the highest of all.", "tiles": ["Ki", "sang", "polu-ta", "i-u-gao."], "decoys": ["polu-ma", "i-gao."], "tip": "Than all is polu-ta, and more is u- before the root."},
	{"lv": 4, "en": "I did not see them.", "tiles": ["Ma-k-ri-pal-ak-pa-ki-da."], "decoys": ["Ma-k-i-pal-ak-pa-ki-da.", "K-ri-pal-ak-pa-da.", "Ma-r-na-pal-ak-pa-ki-da."], "tip": "k- I act, ri- them, ma- ... -ki not. This one is straight from the grammar."}
]

# Market rush: things Ketu's stall sells. word -> English
const GOODS = {"guro": "fruit", "panak": "bread", "tari": "fish", "cha": "tea"}
const NUMBERS = ["nul", "yan", "vel", "mur", "kes", "pan", "luk", "set", "bar", "gov", "dar"]

# "Say it yourself" challenges: residents ask you to build a sentence (index into TILES). Unlock at level 2.
const CHALLENGES = {"mira": 15, "tor": 2, "ketu": 8, "vira": 20, "desh": 17, "lira": 14, "oren": 6, "tamu": 18, "oku": 19, "neri": 1, "suri": 12, "pomo": 21, "sanu": 16, "ena": 9, "yalo": 11, "gav": 13}

const LEVEL_NAMES = ["", "Explorer", "Speaker", "Storyteller", "Elder"]

# Times of day, announced as they change.
const TIMES = {"salma": "dawn", "monar": "morning", "yar": "day", "wanar": "evening", "yesh": "night"}

# Personalities. thing: what they are proud of (Varnak, English). trait decides how big their reactions are.
# likes and hates are gifts: tari (fish), panak (bread), cha (tea), gin (a coin).
const PEOPLE = {
	"ena": {"trait": "cheerful", "thing": ["kel", "bag"], "likes": ["tari"], "hates": [],
		"secret": {"v": "An haima ma-na-sum-ur-ki-da.", "en": "I can't swim in the sea. (A harbor master who cannot swim!)"}},
	"mira": {"trait": "dramatic", "thing": ["yamat", "food"], "likes": ["cha"], "hates": ["panak"],
		"secret": {"v": "An yamat ma-na-dar-ur-ki-da. Ketuke i-dar-ur-da.", "en": "I don't cook the food. Ketu cooks it."}},
	"sanu": {"trait": "sleepy", "thing": ["ruk", "path"], "likes": ["panak"], "hates": [],
		"secret": {"v": "An rukma na-sul-ur-da.", "en": "I usually sleep on the path."}},
	"tor": {"trait": "proud", "thing": ["gira", "bridge"], "likes": ["cha"], "hates": ["gin"],
		"secret": {"v": "Gira i-sava... shi.", "en": "The bridge is safe... apparently. (-shi: Tor is only guessing!)"}},
	"lira": {"trait": "giggly", "thing": ["tovu", "story"], "likes": ["gin"], "hates": ["tari"],
		"secret": {"v": "Anni tovu-ir ri-fau-da.", "en": "My stories are false."}},
	"oren": {"trait": "grumpy", "thing": ["mar", "horse"], "likes": ["panak"], "hates": ["cha"],
		"secret": {"v": "An mar-ru na-ning-ur-da.", "en": "I sing to the horse."}},
	"neri": {"trait": "cheerful", "thing": ["puka", "notebook"], "likes": ["tari", "panak", "cha", "gin"], "hates": [],
		"secret": {"v": "An tari-ta na-par-ur-da.", "en": "I am afraid of fish."}},
	"ketu": {"trait": "cheerful", "thing": ["tari", "fish"], "likes": ["tari", "gin"], "hates": ["panak"],
		"secret": {"v": "Tari-ir anni palar-ir ri-an-da.", "en": "The fish are my friends."}},
	"suri": {"trait": "proud", "thing": ["senak", "school"], "likes": ["cha"], "hates": [],
		"secret": {"v": "Anke puka ma-k-i-rav-pa-ki-da.", "en": "I did not read the book."}},
	"rin": {"trait": "giggly", "thing": ["puka", "book"], "likes": ["panak"], "hates": ["cha"],
		"secret": {"v": "Anke Ola-ni guro k-i-nuk-pa-da.", "en": "I took Ola's fruit. (Ola was framed!)"}},
	"ola": {"trait": "giggly", "thing": ["guro", "fruit"], "likes": ["panak"], "hates": ["cha"],
		"secret": {"v": "An sao-ir-ru na-mel-ur-da.", "en": "I talk to the stars."}},
	"pomo": {"trait": "sleepy", "thing": ["sang", "hill"], "likes": ["cha"], "hates": ["tari"],
		"secret": {"v": "An sang-ma na-sul-ur-da.", "en": "I do sleep on the hill."}},
	"vira": {"trait": "cheerful", "thing": ["yok", "medicine"], "likes": ["cha"], "hates": [],
		"secret": {"v": "Yok i-wai-da. Polu i-zen-da.", "en": "The medicine is bad. Everyone knows."}},
	"ila": {"trait": "dramatic", "thing": ["yir", "clothes"], "likes": ["panak"], "hates": ["tari"],
		"secret": {"v": "Anni dauma tong ma-i-esh-pa-ki-da.", "en": "There was no pain in my head. (She faked it!)"}},
	"yalo": {"trait": "dramatic", "thing": ["fardom", "lighthouse"], "likes": ["cha"], "hates": ["tari"],
		"secret": {"v": "An yesh-ta na-par-ur-da. I-zen-da.", "en": "I am afraid of the night. It's true."}},
	"desh": {"trait": "giggly", "thing": ["ning", "song"], "likes": ["tari"], "hates": [],
		"secret": {"v": "Tari-ir ma-ri-seng-ur-ki-da.", "en": "The fish are not happy when I sing."}},
	"oku": {"trait": "proud", "thing": ["sek-ir", "stones"], "likes": ["cha"], "hates": ["gin"],
		"secret": {"v": "Sek-ir ma-ri-mel-ur-ki-da. An na-mel-ur-da.", "en": "The stones don't talk. I do."}},
	"gav": {"trait": "cheerful", "thing": ["kel-ir", "bags"], "likes": ["panak"], "hates": [],
		"secret": {"v": "Kel-ir-ma yamat i-ho-da.", "en": "The food in the bags is good."}},
	"tamu": {"trait": "grumpy", "thing": ["sena", "boat"], "likes": ["tari"], "hates": ["panak"],
		"secret": {"v": "An sena-li ma-na-kel-ur-ki-da. Na-sum-ur-da.", "en": "I don't travel by boat. I swim."}}
}

# Jokes you can tell. Silly sentences built from words you have met.
const JOKES = [
	{"v": "Mar wak-korma i-esh-da!", "en": "The horse is in the well!"},
	{"v": "Yue guro i-an-shi!", "en": "Apparently the moon is a fruit!"},
	{"v": "Gor ket-ma i-sul-im-da!", "en": "The dog is sleeping on a chair!"},
	{"v": "Par sena-li i-kel-ur-da!", "en": "The bird usually travels by boat!"},
	{"v": "Sek-ir ri-ning-ur-nu!", "en": "They say the stones usually sing!"},
	{"v": "Tari-ir dom-ma ri-sul-ur-da!", "en": "The fish usually sleep in the house!"},
	{"v": "Gira i-pav-im-da!", "en": "The bridge is running!"}
]
const GIFT_WORDS = {"tari": "fish", "panak": "bread", "cha": "tea", "gin": "a coin"}


# ---- quick practice for new words: word classes and English forms ----
# Intransitive verbs: [base, past, -ing]
const EXT_VERBS_I = {"lum": ["go", "went", "going"], "pav": ["run", "ran", "running"], "sul": ["sleep", "slept", "sleeping"], "sum": ["swim", "swam", "swimming"],
	"ning": ["sing", "sang", "singing"], "nang": ["walk", "walked", "walking"], "tal": ["arrive", "arrived", "arriving"], "mel": ["talk", "talked", "talking"], "kar": ["come", "came", "coming"]}
# Transitive verbs: [base, past]
const EXT_VERBS_T = {"pal": ["see", "saw"], "nuk": ["take", "took"], "rav": ["read", "read"], "por": ["open", "opened"], "hep": ["close", "closed"],
	"dar": ["cook", "cooked"], "varn": ["build", "built"], "sir": ["look for", "looked for"], "mai": ["buy", "bought"], "ven": ["give", "gave"], "tar": ["bring", "brought"]}
const EXT_STATIVES = {"var": "big", "sen": "small", "nav": "warm", "ret": "hot", "len": "cold", "gao": "tall", "ho": "good", "wai": "bad", "seng": "happy",
	"sava": "safe", "ling": "bright", "dam": "dark", "dun": "short", "shora": "old", "nava": "new", "lei": "tired", "mar": "full", "hala": "fast"}
const EXT_NOUNS_EXTRA = {"kel": ["bag", "bags"], "sek": ["stone", "stones"], "lin": ["rope", "ropes"], "yamat": ["food", "food"], "cha": ["tea", "tea"],
	"yok": ["herb", "herbs"], "ket": ["chair", "chairs"], "yir": ["shirt", "shirts"], "gin": ["coin", "coins"], "sao": ["star", "stars"], "yue": ["moon", "moons"],
	"riya": ["sun", "suns"], "hen": ["sky", "skies"], "tovu": ["story", "stories"], "palar": ["friend", "friends"], "ruk": ["path", "paths"], "pai": ["paper", "papers"],
	"senar": ["teacher", "teachers"], "ravar": ["student", "students"], "kelar": ["traveler", "travelers"], "dor": ["land", "lands"], "gan": ["room", "rooms"]}

# ---- poems from ning-guro berries and sao-dau mushrooms ----
# Poem nouns: [singular, plural]
const POEM_NOUNS = {"yue": ["the moon", "moons"], "riya": ["the sun", "suns"], "sao": ["a star", "the stars"], "hai": ["the sea", "seas"], "mora": ["the river", "rivers"],
	"murak": ["the tree", "the trees"], "par": ["the bird", "the birds"], "tari": ["the fish", "the fish"], "fal": ["the flower", "the flowers"], "guro": ["the fruit", "the fruits"],
	"sek": ["the stone", "the stones"], "sang": ["the hill", "the hills"], "far": ["the fire", "the fires"], "dom": ["the house", "the houses"], "sena": ["the boat", "the boats"],
	"puka": ["the book", "the books"], "panak": ["the bread", "the loaves"], "gor": ["the dog", "the dogs"], "mar": ["the horse", "the horses"], "ket": ["the chair", "the chairs"],
	"gira": ["the bridge", "the bridges"], "yamat": ["the food", "the meals"]}
const POEM_PLACES = {"hen": "in the sky", "hai": "in the sea", "mora": "in the river", "yesh": "in the night", "salma": "at dawn", "teka": "in the village",
	"sang": "on the hill", "guro": "inside a fruit", "dau": "in my head", "kel": "in a bag"}
const POEM_INC = [["wak-ta", "drinks water", "drink water"], ["yamat-dar", "cooks food", "cook food"], ["puka-rav", "reads books", "read books"],
	["tari-nuk", "goes fishing", "go fishing"], ["mara-vun", "works the fields", "work the fields"]]