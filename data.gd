extends RefCounted
# Language data for Tujuju Island. Every form here comes from the Varnak section (the language's original name) of the
# Constructed-Language Handoff Document (attested examples, marked "doc" in TUJUJU_CONTENT.md)
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
	"sa": "they (one person), it (independent pronoun; Tujuju has no gender)", "hai-sao": "sea star (hai + sao)", "-ve": "ordinal ending (yan-ve: first)",
	"yanve": "first", "velve": "second", "murve": "third", "kesve": "fourth", "panve": "fifth", "lukve": "sixth", "setve": "seventh", "barve": "eighth",
	"gin": "money, coins", "har": "thank (root)", "maki": "no", "dor": "land", "sendor": "the small island (sen dor: small land)",
	"gan": "room", "shan": "rear, behind (after -ni)", "men": "front (after -ni)", "dal": "side (after -ni)", "pai": "paper",
	"tal": "arrive (root)", "shora": "old", "nava": "young / new",
	"ansu": "with me (an + su)", "na-": "I (subject prefix)", "ta-": "you (subject prefix)", "i-": "they (one person), it (subject prefix)",
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
	# borrowed words: respelled with Tujuju sounds
	"choni": "underwear (borrowed from Mexican Spanish chones, chonies)", "buruhaha": "an uproar, a commotion (borrowed from French brouhaha)",
	"kafufel": "a fuss (borrowed from Scots kerfuffle)", "halabalu": "a noisy racket (borrowed from English hullabaloo)",
	"shenani": "mischief, tricks (borrowed from English shenanigans)", "gesunhait": "bless you, said after a sneeze (borrowed from German Gesundheit)",
	"hutspa": "nerve, cheek (borrowed from Yiddish chutzpah)", "kawai": "cute (borrowed from Japanese kawaii; a describing root: i-kawai)",
	"fiyesta": "a party (borrowed from Spanish fiesta)",
	"bombom": "candy (borrowed from French bonbon)", "wala": "ta-da! (borrowed from French voila)", "pajama": "pajamas (borrowed through English from Hindi and Urdu)",
	"kaput": "broken (borrowed from German kaputt; a describing root: i-kaput)", "aloha": "hello, goodbye (borrowed from Hawaiian)", "chau": "bye (borrowed from Italian ciao)",
	"kaf": "coffee (an old borrowing, like cha)",
	# borrowed terms of endearment and playful insults
	"habibi": "darling, my dear (borrowed from Arabic habibi)", "shatsi": "sweetie (borrowed from German Schatzi, little treasure)",
	"monshu": "sweetie (borrowed from French mon chou, literally my cabbage)", "bubala": "darling (borrowed from Yiddish bubbeleh)",
	"puts": "a fool, a dope (borrowed from Yiddish putz; playful, not polite)", "baka": "silly fool (borrowed from Japanese baka)",
	"shlemil": "a clumsy fool (borrowed from Yiddish schlemiel)",
	# calques: words built by translating another language piece by piece
	"far-par": "firefly (calque: far fire + par bird, built like English fire-fly)", "ret-gor": "hot dog, a sausage in bread (calque: ret hot + gor dog)",
	"sao-tari": "starfish (calque: sao star + tari fish, from English starfish; hai-sao, sea star, is the older word)",
	"hai-mar": "seahorse (calque: hai sea + mar horse)", "sanu-mara": "kindergarten (calque of German Kindergarten: sanu child + mara field)",
	"dau-fong": "brainstorm (calque: dau head + fong wind)", "fong": "wind",
	# reduplication: doubling makes a describing word stronger, a verb repeated, a noun varied
	"var-var": "huge (var big, doubled)", "sen-sen": "tiny (sen small, doubled)", "ho-ho": "super good (ho good, doubled)",
	"kawai-kawai": "so, so cute (doubled)", "len-len": "freezing (len cold, doubled)", "pav-pav": "run around and around (pav run, doubled)",
	"guro-guro": "fruits of all kinds (guro fruit, doubled)", "puts-puts": "a total fool (doubled)",
	# sound words borrowed from Guarani (repeating the last syllable echoes a repeating sound)
	"pororo": "pop, crackle (borrowed from Guarani pororó, the sound of something bursting; popcorn is pororó too)",
	"piriri": "sparkle, fizz (borrowed from Guarani piriri, to sparkle or crackle)",
	"chiriri": "sizzle (borrowed from Guarani chyryry, the sound of frying)",
	"guarara": "roar, a big noise (borrowed from Guarani guarara, noise)",
	"kororo": "snore (borrowed from Guarani kororõ, to snore or roar)",
	"tarara": "toot like a trumpet (borrowed from Guarani tarara, the sound of a trumpet)",
	"pururu": "crunch (borrowed from Guarani pururũ, a crunching sound)",
	"siri": "trickle, flow (borrowed from Guarani syry, to flow)",
	"vava": "sway, wobble (borrowed from Guarani vava, to sway)",
	"sununu": "a rumbling uproar (borrowed from Guarani sununu, an uprising or revolt)",
	"kachaka": "bouncy dance music (borrowed from Paraguayan kachaka, a cumbia style named after a Colombian song)",
	# eighth expansion: pranks, Hirimara, more borrowings
	"hiri": "prank, trick (as a verb root: k-ta-hiri, I prank you; Hiri! means Gotcha!)", "hiri-hiri": "prank after prank (doubled)",
	"sipu": "spider", "dop": "hide (transitive root: k-i-dop, I hide it)", "lavir": "maze", "hirimara": "the prank field (a compound: hiri prank + mara field)",
	"-na": "person who (a derivation ending: choni-na, choni person; teka-na, villager)", "choni-na": "choni person, a title of great honor (choni + -na)",
	"karaoke": "karaoke (borrowed from Japanese karaoke, empty orchestra)", "bravo": "well done! (borrowed from Italian bravo)",
	"ups": "oops (borrowed from English oops)", "pitsa": "pizza (borrowed from Italian pizza)", "selfi": "selfie photo (borrowed from English selfie)",
	"robot": "robot (borrowed from Czech robot, from robota, hard work)", "safari": "a long trip, an expedition (borrowed from Swahili safari, journey)",
	"tabu": "forbidden (borrowed through English taboo from Tongan tapu; a describing root: i-tabu)", "kudos": "praise, well done (borrowed from Greek kudos, glory)",
	"chochke": "a little trinket, a knickknack (borrowed from Yiddish tchotchke)", "kluts": "a clumsy person (borrowed from Yiddish klutz)",
	"poltergais": "a noisy prank ghost (borrowed from German Poltergeist, noisy ghost)", "dopelgenger": "a double who looks just like you (borrowed from German Doppelganger, double-goer)",
	"deshavu": "the feeling it happened before (borrowed from French deja vu, already seen)", "gobeldigok": "nonsense talk, gibberish (borrowed from English gobbledygook)",
	"ninkompup": "a silly fool (borrowed from English nincompoop)", "karinyo": "darling (borrowed from Spanish carino)",
	"wai-dau": "a dummy, an airhead (calque of German Dummkopf: wai bad + dau head)", "shampu": "shampoo (borrowed from Hindi champo, press or massage)",
	"yureka": "I found it! (borrowed from Greek eureka)", "deshavu-sek": "the deja vu stone (deshavu + sek stone)", "bungalo": "a small house (borrowed from Hindi bangla, a Bengal-style house)", "kabum": "boom! (borrowed from English kaboom)",
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
	"tar": "bring (root); also top (after -ni)",
	"hen": "sky (a false friend: not a chicken!)", "ten": "foot (a false friend: the number ten is dar)",
	"far": "fire (a false friend: not far away)", "pal": "see (root; a false friend: not a pal)",
	"gin": "money, coins (a false friend: not the drink)", "bar": "eight (a false friend: not a bar)",
	"set": "seven (a false friend: not a set)", "men": "front (after -ni; a false friend: not men)",
	"sum": "swim (root; a false friend: not a sum)"
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
		"gesture": "Mira sweeps an arm across the rooftops, then spreads their hands wide.",
		"words": ["teka", "var"], "wrong": ["The village is small.", "The village is far away."]},
	"food_warm": {"v": "Yamat i-nav.", "parts": "yamat  i-nav\nfood  3S-be.warm", "en": "The food is warm.",
		"gesture": "Mira holds a hand over the steaming bowl.",
		"words": ["yamat", "nav"], "wrong": ["The food is old.", "The food is finished."]},
	"mira_cooks": {"v": "Mirake yamat i-dar-im-da.", "parts": "Mira-ke  yamat  i-dar-im-da\nMira-ERG  food.ABS  3P-cook-IPFV-DIR",
		"en": "Mira is cooking the food (I can see it).",
		"gesture": "Mira stirs the pot and points to their own eyes, then to you.",
		"words": ["dar", "-ke", "-im", "-da"], "wrong": ["Mira cooked the food long ago.", "The food is cooking Mira."]},
	"boat_small": {"v": "Sena i-sen.", "parts": "sena  i-sen\nboat  3S-be.small", "en": "The boat is small.",
		"gesture": "Vufi pats the boat and pinches two fingers close together.",
		"words": ["sena", "sen"], "wrong": ["The boat is big.", "The boat is old."]},
	"path_safe": {"v": "Sava ruk.", "parts": "sava  ruk\nsafe  path", "en": "A safe path.",
		"gesture": "Sanu taps the ground, nods firmly, and points ahead.",
		"words": ["sava", "ruk"], "wrong": ["A long path.", "A dangerous path."]},
	"gira_safe": {"v": "Gira i-sava-da.", "parts": "gira  i-sava-da\nbridge  3S-be.safe-DIR", "en": "The bridge is safe (I know it directly).",
		"gesture": "Dofo stamps on the planks and spreads both hands.",
		"words": ["gira", "sava", "-da"], "wrong": ["The bridge is broken.", "The bridge is safe (I heard)."]},
	"stork_fish": {"v": "Tujuju morama i-tari-nuk-im-da.", "parts": "tujuju  mora-ma  i-tari-nuk-im-da\nstork  river-LOC  3S-fish-take-IPFV-DIR",
		"en": "The stork is fishing in the river.",
		"gesture": "The huge white bird with the black head wades slowly, stirs the mud with one foot, and snaps its giant bill shut on something silver.",
		"words": ["tujuju", "mora", "-ma", "tari", "nuk", "-im"], "wrong": ["The stork is sleeping in the river.", "The fish is catching the stork."]},
	"kirkor_build": {"v": "Anke ti-ru kir-kor k-i-varn-fu-da!", "parts": "an-ke  ti-ru  kir-kor  k-i-varn-fu-da\n1SG-ERG  2SG-ALL  write-box  1SG.A-3P-build-FUT-DIR",
		"en": "I will build you a writing box!",
		"gesture": "Dofo stares at your Ayvu chart, turns it upside down, turns it back, and starts sketching gears, a round dial and a row of keys.",
		"words": ["kir", "kor", "varn", "-fu", "-ru"], "wrong": ["You will build me a writing box!", "I built a box for the writing."]},
	"capy_looks": {"v": "Kapibarake ti i-pal-im-da.", "parts": "kapibara-ke  ti  i-pal-im-da\ncapybara-ERG  2SG  3P-see-IPFV-DIR",
		"en": "The capybara is looking at you.",
		"gesture": "The capybara chews slowly, turns its big square head toward you, and blinks. Then it looks down the trail.",
		"words": ["kapibara", "-ke", "ti", "pal", "-im"], "wrong": ["You are looking at the capybara.", "The capybara is sleeping in the water."]},
	"capy_myth": {"v": "Kapibara-irke sair-ir sonot-ru ri-tar-ak-pa-nu.", "parts": "kapibara-ir-ke  sair-ir  sonot-ru  ri-tar-ak-pa-nu\ncapybara-PL-ERG  person-PL  cenote-ALL  3PL-bring-PFV-PST-REP",
		"en": "They say the capybaras brought the people to the cenote.",
		"gesture": "Oku gets down on hands and knees, waddles a few steps like a capybara, looks back over one shoulder, and beckons you to follow.",
		"words": ["kapibara", "-ir", "-ke", "sair", "sonot", "-ru", "tar", "-ak", "-nu"], "wrong": ["They say the people brought the capybaras to the cenote.", "I saw the capybaras swim in the sea."]},
	"tujuju_name": {"v": "Sair-ir tujuju-ir-ni shanma dor-ma ri-tal-ak-pa-nu.", "parts": "sair-ir  tujuju-ir-ni  shan-ma  dor-ma  ri-tal-ak-pa-nu\nperson-PL  stork-PL-GEN  rear-LOC  land-LOC  3PL.S-arrive-PFV-PST-REP",
		"en": "They say the people came to the land behind the storks.",
		"gesture": "Oku flaps both arms slowly like great white wings, shuffles along behind the invisible birds, then stamps on the ground: here. \"Tujuju!\" Oku says, and sweeps a hand over the whole island.",
		"words": ["sair", "-ir", "tujuju", "-ni", "shan", "dor", "tal", "-ak", "-nu"], "wrong": ["They say the storks came to the land behind the people.", "I saw the people chase the storks off the land."]},
	"tor_built": {"v": "Dofoke gira i-varn-ak-pa-da.", "parts": "Dofo-ke  gira  i-varn-ak-pa-da\nDofo-ERG  bridge.ABS  3P-build-PFV-PST-DIR",
		"en": "Dofo built the bridge (I witnessed it).",
		"gesture": "Dofo mimes hammering, then points at you and at the planks.",
		"words": ["varn", "-ke", "-ak", "-pa"], "wrong": ["The bridge will be built by Dofo.", "The bridge built Dofo."]},
	"river_small": {"v": "Mora i-sen-im.", "parts": "mora  i-sen-im\nriver  3S-be.small-IPFV", "en": "The river is small right now.",
		"gesture": "Dofo holds two fingers close together over the water.",
		"words": ["mora", "sen", "-im"], "wrong": ["The river is big.", "The river is far away."]},
	"dog_runs": {"v": "Gor i-pav-im.", "parts": "gor  i-pav-im\ndog  3S-run-IPFV", "en": "The dog is running.",
		"gesture": "Lira wiggles two fingers like running legs and laughs.",
		"words": ["gor", "pav", "-im"], "wrong": ["The dog is sleeping.", "The dog is big."]},
	"horse_fast": {"v": "Mar hala i-pav.", "parts": "mar  hala  i-pav\nhorse  fast  3S-run", "en": "The horse runs fast.",
		"gesture": "Rofi flicks their fingers quickly across their palm.",
		"words": ["mar", "hala", "pav"], "wrong": ["The horse is tired.", "The horse ran away."]},
	"tree_tall": {"v": "Murak i-gao.", "parts": "murak  i-gao\ntree  3S-be.tall", "en": "The tree is tall.",
		"gesture": "Rofi raises one hand high above their head.",
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
		"gesture": "Planks are missing and a rail dangles. Dofo frowns at the gap and shakes their head.",
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
		"gesture": "Suri taps their own chest, then points at the chalkboard.",
		"words": ["an", "senar"], "wrong": ["I am a student.", "You are a teacher."]},
	"rin_student": {"v": "An ravar na-an-da.", "parts": "an  ravar  na-an-da\n1SG  student  1S-be-DIR", "en": "I am a student.",
		"gesture": "Vivi holds up a book and grins.",
		"words": ["an", "ravar"], "wrong": ["I am a traveler.", "They are a student."]},
	"hill_taller": {"v": "Sang murak-ta i-u-gao.", "parts": "sang  murak-ta  i-u-gao\nhill  tree-ABL  3S-COMP-tall", "en": "The hill is taller than the tree.",
		"gesture": "Radi holds one hand at tree height, then lifts the other far above it.",
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
		"gesture": "Desh points at the lagoon, mimes swimming strokes, then counts off several days on their fingers.",
		"words": ["hai", "-ma", "sum", "-ur"], "wrong": ["I swam in the river yesterday.", "Swim in the sea!"]},
	"child_sleeps": {"v": "Sanu sulumma i-sul-im-da.", "parts": "sanu  sulum-ma  i-sul-im-da\nchild  bed-LOC  3S-sleep-IPFV-DIR", "en": "The child is sleeping in the bed.",
		"gesture": "A small child is curled up under a blanket. Jeli puts a finger to their lips.",
		"words": ["sanu", "sulum", "-ma", "sul", "-im"], "wrong": ["The child is running to the bed.", "The child is not sleeping."]},
	"lighthouse_dark": {"v": "Fardom i-dam-da.", "parts": "fardom  i-dam-da\nlighthouse  3S-be.dark-DIR", "en": "The lighthouse is dark (I can see it).",
		"gesture": "The lamp room at the top is cold and grey.",
		"words": ["fardom", "dam"], "wrong": ["The lighthouse is bright.", "The lighthouse is short."]},
	"lighthouse_bright": {"v": "Fardom i-ling-da.", "parts": "fardom  i-ling-da\nlighthouse  3S-be.bright-DIR", "en": "The lighthouse is bright (I can see it).",
		"gesture": "A golden beam sweeps across the water.",
		"words": ["fardom", "ling"], "wrong": ["The lighthouse is dark.", "The lighthouse is broken."]},
	"no_fire": {"v": "Far ma-i-esh-ki-da.", "parts": "far  ma-i-esh-ki-da\nfire  NEG-3S-exist-NEG-DIR", "en": "There is no fire (I can see it).",
		"gesture": "Asya points up at the dark lamp and turns their empty hands over.",
		"words": ["far", "esh", "ma- -ki"], "wrong": ["The fire is hot.", "Bring the fire!"]},
	"night_light": {"v": "Yeshma fardom i-ling-ur-da.", "parts": "yesh-ma  fardom  i-ling-ur-da\nnight-LOC  lighthouse  3S-be.bright-HAB-DIR", "en": "At night the lighthouse usually shines.",
		"gesture": "Asya closes their eyes as if sleeping, then opens their hands wide like a beam of light.",
		"words": ["yesh", "fardom", "ling", "-ur"], "wrong": ["In the morning the lighthouse is dark.", "At night the lighthouse fell down."]},
	"rain_starts": {"v": "I-ser-ng.", "parts": "i-ser-ng\n3S-rain-INCH", "en": "It is beginning to rain.",
		"gesture": "The fisher holds a palm up to the clouds and squints.",
		"words": ["-ng"], "wrong": ["It rained yesterday.", "The sun is shining."]},
	"ila_happy": {"v": "Sije i-seng-da.", "parts": "Sije  i-seng-da\nSije  3S-be.happy-DIR", "en": "Sije is happy (I can see it).",
		"gesture": "Sije sips the tea and smiles broadly.",
		"words": ["seng"], "wrong": ["Sije is tired.", "Sije is sad."]},
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
		"gesture": "Lachu pats the boat, points out to sea and paddles the air.",
		"words": ["sena", "-li", "sendor", "-ru", "kel", "-ur"], "wrong": ["I swam to the small island.", "The boat is going to the village."]},
	"gav_mail": {"v": "Anke polu-ru kel-ir k-ri-tar-ur-da.", "parts": "an-ke  polu-ru  kel-ir  k-ri-tar-ur-da\n1SG-ERG  everyone-DAT  bag-PL  1A-3PL.P-bring-HAB-DIR", "en": "I usually bring bags to everyone.",
		"gesture": "Gav shrugs a bulging satchel and waves at the whole island.",
		"words": ["polu", "-ru", "kel", "-ir", "tar", "-ur"], "wrong": ["Everyone brings bags to me.", "I lost a bag yesterday."]},
	"night_sky": {"v": "Yeshma sao-ir ri-ling-da.", "parts": "yesh-ma  sao-ir  ri-ling-da\nnight-LOC  star-PL  3PL.S-be.bright-DIR", "en": "At night the stars shine.",
		"gesture": "Radi points up at the sky full of stars.",
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
		"words": ["var", "guro", "hala", "pav"], "wrong": ["A small fruit is sleeping.", "The fruit is not moving."]},
	"odd_choni": {"v": "Gav-ni choni fardom-ni tarma i-esh-da!", "parts": "Gav-ni  choni  fardom-ni  tar-ma  i-esh-da\nGav-GEN  underwear  lighthouse-GEN  top-LOC  3S-be.located-DIR", "en": "Gav's underwear is on top of the lighthouse!",
		"gesture": "A pair of spotted chonies flaps from the very top of the lighthouse like a flag. Choni is a word Tujuju borrowed.",
		"words": ["choni", "-ni", "fardom", "tar", "-ma"], "wrong": ["Gav is on top of the lighthouse.", "The lighthouse is wearing a hat."]},
	"suri_kinder": {"v": "Ki senak sanu-mara ma-i-an-ki-da!", "parts": "ki  senak  sanu-mara  ma-i-an-ki-da\nthis  school  child-field  NEG-3S-be-NEG-DIR", "en": "This school is NOT a kindergarten!",
		"gesture": "Suri says it to Vivi and Oli, who are giggling under a bench. Sanu-mara is a calque of German Kindergarten: child-field.",
		"words": ["senak", "sanu-mara", "ma- -ki"], "wrong": ["This school is a kindergarten!", "The children are in the field."]},
	"oku_brainstorm": {"v": "Anni dauma dau-fong i-esh-im-da!", "parts": "anni  dau-ma  dau-fong  i-esh-im-da\nmy  head-LOC  head-wind  3S-exist-IPFV-DIR", "en": "There is a brainstorm in my head!",
		"gesture": "Oku clutches their head as their hair blows about. Dau-fong, head-wind, is a calque of brainstorm.",
		"words": ["dau", "dau-fong", "fong"], "wrong": ["There is wind on the hill.", "My head hurts."]},
	"hot_dog": {"v": "Gor ret-gor-ta i-par-ur-da.", "parts": "gor  ret-gor-ta  i-par-ur-da\ndog  hot-dog-ABL  3S-fear-HAB-DIR", "en": "The dog is afraid of hot dogs.",
		"gesture": "The village dog stares at the ret-gor in horror. Ret-gor, hot dog, is a calque: ret hot + gor dog.",
		"words": ["ret-gor", "gor", "par"], "wrong": ["The dog is eating a hot dog.", "The dog is hot."]},
	"fruit_variety": {"v": "Ki guro-guro i-ho-ho-da!", "parts": "ki  guro-guro  i-ho-ho-da\nthis  fruit~REDUP  3S-good~REDUP-DIR", "en": "These fruits of all kinds are super good!",
		"gesture": "Ketu juggles three different fruits. Doubling a word changes it: guro-guro means all kinds of fruit, ho-ho means super good.",
		"words": ["guro-guro", "ho-ho"], "wrong": ["This fruit is bad.", "Two fruits are good."]},
	"mira_sizzle": {"v": "Yamat i-chiriri-im-da!", "parts": "yamat  i-chiriri-im-da\nfood  3S-sizzle-IPFV-DIR", "en": "The food is sizzling!",
		"gesture": "Mira shakes a hot pan and makes a frying noise with their mouth. Chiriri is a sound word borrowed from Guarani chyryry.",
		"words": ["yamat", "chiriri", "-im"], "wrong": ["The food is cold.", "The food is sleeping."]},
	"fire_pops": {"v": "Far i-pororo-pororo-im-da!", "parts": "far  i-pororo-pororo-im-da\nfire  3S-pop~REDUP-IPFV-DIR", "en": "The fire is popping and popping!",
		"gesture": "Neri jumps back from the campfire as sparks fly. Pororo is the Guarani sound of something bursting; doubled, it keeps going.",
		"words": ["far", "pororo", "-im"], "wrong": ["The fire is out.", "The fire popped once."]},
	"desh_toot": {"v": "Fiyesta-ma Desh i-tarara-tarara-pa-nu!", "parts": "fiyesta-ma  Desh  i-tarara-tarara-pa-nu\nparty-LOC  Desh  3S-toot~REDUP-PST-REP", "en": "They say Desh tooted and tooted like a trumpet at the party!",
		"gesture": "Desh puffs out both cheeks and plays an imaginary trumpet. Tarara is the Guarani sound of a trumpet.",
		"words": ["fiyesta", "tarara", "-nu"], "wrong": ["Desh slept at the party.", "Desh will play the drum."]},
	"karaoke_stage": {"v": "Ki karaoke-ma polu ri-ning-ur-da!", "parts": "ki  karaoke-ma  polu  ri-ning-ur-da\nthis  karaoke-LOC  everyone  3PL-sing-HAB-DIR", "en": "Everyone sings at this karaoke!",
		"gesture": "A tiny stage with a seashell microphone. A painted sign says Bravo! Karaoke is borrowed from Japanese.",
		"words": ["karaoke", "polu", "ning"], "wrong": ["Nobody sings here.", "The stage is broken."]},
	"maze_hedge": {"v": "Lavir i-var-da. Ups... an hama na-esh-ha?", "parts": "lavir  i-var-da.  ups...  an  hama  na-esh-ha\nmaze  3S-big-DIR.  oops  I  where  1S-be.located-Q", "en": "The maze is big. Oops... where am I?",
		"gesture": "Tall green hedges in every direction. Ups is borrowed from English oops.",
		"words": ["lavir", "hama", "ups"], "wrong": ["The maze is small. I know the way.", "The house is big."]},
	"ghost_hut": {"v": "Ki bungalo-ma poltergais i-esh-nu.", "parts": "ki  bungalo-ma  poltergais  i-esh-nu\nthis  small.house-LOC  poltergeist  3S-be.located-REP", "en": "They say a poltergeist lives in this little house.",
		"gesture": "A teapot floats past the window. A chair spins on its own. Bungalo comes from Hindi, poltergais from German.",
		"words": ["bungalo", "poltergais", "-nu"], "wrong": ["I saw a cat in the house.", "The house is empty and quiet."]},
	"scarecrow": {"v": "Choni dau-ma i-esh-da!", "parts": "choni  dau-ma  i-esh-da\nunderwear  head-LOC  3S-be.located-DIR", "en": "There is a choni on its head!",
		"gesture": "A scarecrow guards the prank field, wearing a pair of spotted chonies as a hat.",
		"words": ["choni", "dau", "esh"], "wrong": ["The scarecrow has a hat.", "There is a bird on its head."]},
	"party_noise": {"v": "Fiyesta-ma buruhaha i-esh-pa-nu.", "parts": "fiyesta-ma  buruhaha  i-esh-pa-nu\nparty-LOC  uproar  3S-exist-PST-REP", "en": "They say there was an uproar at the party.",
		"gesture": "Desh grins and mimes a crowd going wild. Fiyesta and buruhaha are both borrowed words.",
		"words": ["fiyesta", "buruhaha", "-nu"], "wrong": ["The party was quiet.", "There will be a party tomorrow."]}
}

# Village gossip. by: who tells it, about: who it is about, ev: how the teller knows.
# reply: what the person it is about says when you ask them.
const GOSSIP = [
	{"id": "oren_horse", "by": "lira", "about": "rofi", "ev": "nu", "v": "Rofi mar-ru i-mel-ur-nu.", "en": "People say Rofi usually talks to their horse.",
		"gesture": "Lira leans close and whispers behind their hand.",
		"reply": {"v": "Maki! Mar anru i-mel-ur-da.", "en": "No! The horse usually talks to ME.", "gesture": "Rofi folds their arms, offended on the horse's behalf."}},
	{"id": "tor_bridge", "by": "mira", "about": "dofo", "ev": "shi", "v": "Dofo girama i-sul-ur-shi.", "en": "Apparently Dofo usually sleeps on the bridge.",
		"gesture": "Mira points to a pillow and a blanket left on the bridge planks.",
		"reply": {"v": "Gira i-sava-da! An girama na-sul-ur-da.", "en": "The bridge is safe! Yes, I sleep on the bridge.", "gesture": "Dofo pats the planks proudly."}},
	{"id": "mira_food", "by": "ketu", "about": "mira", "ev": "da", "v": "Mira-ni yamat i-len-ur-da.", "en": "Mira's food is usually cold. I know it firsthand.",
		"gesture": "Ketu shivers dramatically and rubs their belly.",
		"reply": {"v": "Maki! Yamat i-nav! ...Yamat i-len-shi.", "en": "No! The food is warm! ...Apparently the food is cold.", "gesture": "Mira tastes the soup, frowns, and quietly puts the lid back on."}},
	{"id": "ketu_fish", "by": "dofo", "about": "ketu", "ev": "nu", "v": "Ketu tari-ir-su i-mel-ur-nu.", "en": "They say Ketu talks with the fish.",
		"gesture": "Dofo glances toward the market and taps their ear.",
		"reply": {"v": "Tari-ir i-ho! Ri-dap-ur-da.", "en": "The fish are good! They answer.", "gesture": "Ketu holds up a fish to their ear and nods seriously."}},
	{"id": "yalo_night", "by": "rofi", "about": "asya", "ev": "nu", "v": "Asya yesh-ta i-par-ur-nu.", "en": "People say Asya is afraid of the night.",
		"gesture": "Rofi grins. A lighthouse keeper afraid of the dark!",
		"reply": {"v": "Maki! Fardom i-ling-da!", "en": "No! The lighthouse is bright!", "gesture": "Asya glances nervously at the sunset and turns the lamp up a little more."}},
	{"id": "desh_sea", "by": "suri", "about": "desh", "ev": "da", "v": "Desh haima i-ning-ur-da.", "en": "Desh usually sings in the sea. I have seen it.",
		"gesture": "Suri covers their ears and laughs.",
		"reply": {"v": "Tari-ir ri-seng-ur-da!", "en": "The fish are happy when I do!", "gesture": "Desh plays a triumphant drum roll."}},
	{"id": "pomo_sleep", "by": "desh", "about": "radi", "ev": "shi", "v": "Radi sang-ma i-sul-ur-shi.", "en": "Apparently Radi usually sleeps on the hill.",
		"gesture": "Desh imitates loud snoring drifting down from the lookout.",
		"reply": {"v": "Maki! An na-pal-ai-ur-da!", "en": "No! I look around all the time!", "gesture": "Radi yawns enormously in the middle of saying it."}},
	{"id": "oku_stones", "by": "gav", "about": "oku", "ev": "nu", "v": "Oku sek-ir-su i-mel-ur-nu.", "en": "They say Oku talks with the stones.",
		"gesture": "Gav makes a spooky face and wiggles their fingers.",
		"reply": {"v": "Sek-ir ri-zen-da.", "en": "The stones know.", "gesture": "Oku smiles mysteriously. Somewhere, a stone seems to nod."}},
	{"id": "gav_food", "by": "jeli", "about": "gav", "ev": "shi", "v": "Gavke kel-ir-ma yamat i-yam-ur-shi.", "en": "Apparently Gav eats the food in the bags.",
		"gesture": "Jeli points at crumbs all over Gav's satchel.",
		"reply": {"v": "Maki! ...Yamat i-nav-pa.", "en": "No! ...The food was warm.", "gesture": "Gav wipes their mouth very quickly."}},
	{"id": "sanu_bag", "by": "vufi", "about": "sanu", "ev": "da", "v": "Sanuke kel i-mong-ur-da.", "en": "Sanu always forgets the bag. I know it.",
		"gesture": "Vufi rolls their eyes toward the forest path.",
		"reply": {"v": "Han kel?", "en": "What bag?", "gesture": "Sanu looks around, genuinely puzzled."}},
	{"id": "ola_fruit", "by": "vivi", "about": "oli", "ev": "shi", "v": "Olike polu-ni guro i-nuk-ur-shi.", "en": "Apparently Oli takes everyone's fruit.",
		"gesture": "Vivi points at Oli's very sticky fingers.",
		"reply": {"v": "Maki! ...Guro i-ho.", "en": "No! ...Fruit is good.", "gesture": "Oli hides something round behind their back."}},
	{"id": "vira_medicine", "by": "sije", "about": "jeli", "ev": "da", "v": "Jeli-ni yok i-wai-da.", "en": "Jeli's medicine tastes bad. I know firsthand.",
		"gesture": "Sije sticks out their tongue and shudders.",
		"reply": {"v": "Yok i-wai, dan Sije i-seng-da!", "en": "The medicine is bad, but Sije is happy!", "gesture": "Jeli shrugs, completely unbothered."}},
	{"id": "tor_choni", "by": "gav", "about": "dofo", "ev": "shi", "v": "Dofoke Gav-ni choni i-nuk-pa-shi.", "en": "Apparently Dofo took Gav's chonies.",
		"gesture": "Gav points at a suspicious spotted corner sticking out of Dofo's tool bag.",
		"reply": {"v": "Maki! ...Choni i-kawai-da.", "en": "No! ...The chonies are cute.", "gesture": "Dofo stuffs the spotted corner deeper into the bag."}},
	{"id": "oku_candy", "by": "ketu", "about": "oku", "ev": "shi", "v": "Okuke sek-ir-ru bombom i-ven-ur-shi.", "en": "Apparently Oku gives candy to the stones.",
		"gesture": "Ketu points at a trail of bombom wrappers leading toward the old ruins.",
		"reply": {"v": "Sek-ir ri-seng-da!", "en": "The stones are happy!", "gesture": "Oku pats a column. It looks suspiciously sticky."}},
	{"id": "desh_party", "by": "lira", "about": "desh", "ev": "nu", "v": "Desh-ni fiyesta-ma halabalu i-esh-pa-nu.", "en": "They say there was a hullabaloo at Desh's party.",
		"gesture": "Lira covers their ears, then dances a little.",
		"reply": {"v": "Ho! Fiyesta i-ho-pa-da! Wala!", "en": "Yes! The party was great! Ta-da!", "gesture": "Desh plays a drum roll and throws imaginary confetti."}},
	{"id": "tor_habibi", "by": "rofi", "about": "dofo", "ev": "nu", "v": "Dofo mar-ru habibi i-mel-ur-nu.", "en": "They say Dofo calls the horse habibi (darling).",
		"gesture": "Rofi glares toward the bridge and pats their horse protectively.",
		"reply": {"v": "Ho! Mar i-kawai-kawai-da!", "en": "Yes! The horse is so, so cute!", "gesture": "Dofo clasps their hands and swoons a little."}},
	{"id": "gav_choni_sea", "by": "mira", "about": "gav", "ev": "shi", "emote": "proud", "v": "Gav-ni choni-ir haima ri-sum-im-shi.", "en": "Apparently Gav's chonies are swimming in the sea.",
		"gesture": "Mira shades their eyes and points dramatically at something spotted, floating far out.",
		"reply": {"v": "Ho! Choni-ir ri-sum-ur-da. Ri-sava-da!", "en": "Yes! The chonies usually swim. They are safe!", "gesture": "Gav waves at the sea like a proud parent."}},
	{"id": "yalo_ghost", "by": "sanu", "about": "asya", "ev": "nu", "emote": "shocked", "v": "Asya poltergais-ta i-par-ur-nu.", "en": "They say Asya is afraid of a poltergeist.",
		"gesture": "Sanu yawns, then whispers and wiggles spooky fingers.",
		"reply": {"v": "Ho! Poltergais Hirimara-ma i-esh-da! I-zen-da!", "en": "Yes! The poltergeist is in Hirimara, the prank field! It's true!", "gesture": "Asya hides behind their own hands and peeks out."}},
	{"id": "desh_karaoke", "by": "rofi", "about": "desh", "ev": "da", "emote": "laugh", "v": "Desh karaoke-ma i-ning-pa-da.", "en": "I saw Desh sing at karaoke.",
		"gesture": "Rofi covers their ears and scowls. Then they mime every fish in the sea swimming away.",
		"reply": {"v": "Bravo! Bravo! An na-ning-fu!", "en": "Bravo! Bravo! I will sing again!", "gesture": "Desh bows deeply to an invisible crowd."}},
	{"id": "suri_selfi", "by": "vivi", "about": "suri", "ev": "shi", "emote": "embarrassed", "v": "Suri-ni puka-ma selfi-ir ri-esh-shi.", "en": "Apparently there are selfies inside Suri's book.",
		"gesture": "Vivi giggles and makes a duck face.",
		"reply": {"v": "Tabu! Ki puka i-tabu-da!", "en": "Forbidden! This book is forbidden!", "gesture": "Suri snaps the book shut and hugs it."}},
	{"id": "ketu_pitsa", "by": "gav", "about": "ketu", "ev": "nu", "emote": "proud", "v": "Ketuke tari-pitsa i-dar-ur-nu.", "en": "They say Ketu makes fish pizza.",
		"gesture": "Gav licks their lips, then looks unsure.",
		"reply": {"v": "Ho! Tari-pitsa i-ho-ho-da! Bravo!", "en": "Yes! Fish pizza is super good! Bravo!", "gesture": "Ketu kisses their fingertips."}},
	{"id": "pomo_dopel", "by": "oli", "about": "radi", "ev": "shi", "emote": "confused", "v": "Radi-ni dopelgenger Hirimara-ma i-esh-shi.", "en": "Apparently Radi's double is in Hirimara, the prank field.",
		"gesture": "Oli points at Radi, then far to the west, then back at Radi.",
		"reply": {"v": "Han?! An yan na-an-da! ...zzz", "en": "What?! There is only one of me! ...zzz", "gesture": "Radi counts themself on their fingers and falls asleep halfway."}},
	{"id": "tor_kluts", "by": "lira", "about": "dofo", "ev": "da", "emote": "embarrassed", "v": "Kluts! Dofo gira-ta mora-ru i-lum-pa-da.", "en": "Klutz! I saw Dofo go from the bridge into the river.",
		"gesture": "Lira mimes a wobble, a slip and a big splash.",
		"reply": {"v": "Ups. ...An na-sum-pa-da. I-zen-da.", "en": "Oops. ...I went swimming. It's true.", "gesture": "Dofo wrings out their shirt with great dignity."}},
	{"id": "oku_chochke", "by": "lachu", "about": "oku", "ev": "nu", "emote": "proud", "v": "Oku chochke-ir-ru i-mel-ur-nu.", "en": "They say Oku talks to trinkets.",
		"gesture": "Lachu taps their head and rolls their eyes.",
		"reply": {"v": "Ho! Chochke-ir ri-mel-ur-da!", "en": "Yes! The trinkets talk back!", "gesture": "Oku holds a trinket to one ear and nods seriously."}},
	{"id": "vira_shampu", "by": "asya", "about": "jeli", "ev": "shi", "emote": "happy", "v": "Jelike guro-ta shampu i-varn-ur-shi.", "en": "Apparently Jeli makes shampoo out of fruit.",
		"gesture": "Asya sniffs the air dramatically. Fruity!",
		"reply": {"v": "Ho! Ti-ni dau-ru, karinyo?", "en": "Yes! For your head, darling?", "gesture": "Jeli offers you a bottle that smells like a fruit salad."}},
	{"id": "gav_robot", "by": "neri", "about": "gav", "ev": "shi", "emote": "laugh", "v": "Gav ma-i-sul-ur-ki-shi. Robot i-an-shi.", "en": "Apparently Gav never sleeps. Apparently Gav is a robot.",
		"gesture": "Neri walks with stiff robot arms.",
		"reply": {"v": "Bip. Bup. ...Ha! Maki!", "en": "Beep. Boop. ...Ha! No!", "gesture": "Gav does the robot, badly."}},
	{"id": "sanu_choni", "by": "jeli", "about": "sanu", "ev": "da", "emote": "sleepy", "v": "Sanu choni-ir-ma i-sul-pa-da.", "en": "I saw Sanu sleeping in a pile of chonies!",
		"gesture": "Jeli shakes with silent laughter.",
		"reply": {"v": "Choni-ir ri-nav-da... zzz", "en": "The chonies are warm... zzz", "gesture": "Sanu curls up as if the pile were still there."}},
	{"id": "lira_story", "by": "radi", "about": "lira", "ev": "da", "v": "Lirake polu-ni tovu i-gao-ur-da.", "en": "Lira tells everyone's stories. I have heard them myself.",
		"gesture": "Radi points down the hill at the village and mimes a chattering mouth.",
		"reply": {"v": "Ho! Ki tovu i-ho!", "en": "Ha! This story is good!", "gesture": "Lira is already telling someone else."}}
]

# Rumor composer: pieces for open-ended sentences.
const RUMOR_PLACES = [["", "", ""], ["tekama", "in the village", ""], ["haima", "in the sea", ""], ["kurma", "at the market", ""], ["sang-ma", "on the hill", ""],
	["wak-korma", "in the well", "silly"], ["sulumma", "in bed", ""], ["girama", "on the bridge", ""], ["murakma", "in a tree", "silly"], ["fardomma", "in the lighthouse", ""], ["guro-ma", "inside a fruit", "silly"], ["fiyesta-ma", "at the party", ""], ["pajama-ma", "in pajamas", "silly"],
	["karaoke-ma", "at karaoke", ""], ["lavir-ma", "in the maze", ""], ["pitsa-ma", "on a pizza", "silly"]]
# root: [base, -ing, past, third-person singular form]
const RUMOR_VERBS = {"sul": ["sleep", "sleeping", "slept", "sleeps"], "sum": ["swim", "swimming", "swam", "swims"], "ning": ["sing", "singing", "sang", "sings"],
	"pav": ["run", "running", "ran", "runs"], "nang": ["walk", "walking", "walked", "walks"], "mel": ["talk", "talking", "talked", "talks"],
	"tal": ["arrive", "arriving", "arrived", "arrives"], "sir": ["search", "searching", "searched", "searches"],
	"kororo": ["snore", "snoring", "snored", "snores"], "tarara": ["toot like a trumpet", "tooting like a trumpet", "tooted like a trumpet", "toots like a trumpet"], "vava": ["wobble", "wobbling", "wobbled", "wobbles"]}
const RUMOR_WHO = ["An", "Dofo", "Mira", "Ketu", "Lira", "Rofi", "Sanu", "Vufi", "Suri", "Radi", "Jeli", "Asya", "Desh", "Oku", "Gav", "Lachu", "Neri", "Gor", "Mar", "Par", "Poltergais", "Robot"]
const RUMOR_WHO_EN = {"An": "I", "Gor": "The dog", "Mar": "The horse", "Par": "The bird", "Poltergais": "The poltergeist", "Robot": "The robot"}

# Door puzzles, one per house. situation is a gesture; options are Tujuju commands.
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
		"place": "the village (teka)", "gesture": "Lira spreads their arms at the rooftops and asks, eyebrows raised."},
	"dofo": {"options": ["An tekama na-esh-da.", "An morama na-esh-da.", "An senama na-esh-da."], "correct": 1,
		"place": "the river (mora)", "gesture": "Dofo motions at the water and asks, eyebrows raised."}
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

# Radi's direction questions from the hilltop. Answers use the locative -ma on a direction word.
const LOOKOUT = [
	{"q": "Fardom hama i-esh-ha?", "en": "Where is the lighthouse?", "gesture": "Radi points across the whole island toward the striped tower where the sun rises.",
		"options": ["Dongma i-esh-da.", "Saima i-esh-da.", "Namma i-esh-da."], "correct": 0, "why": "dong is east, and dong-ma means in the east."},
	{"q": "Kur hama i-esh-ha?", "en": "Where is the market?", "gesture": "Radi points down the hill toward the stalls, away from the north.",
		"options": ["Beima i-esh-da.", "Namma i-esh-da.", "Dongma i-esh-da."], "correct": 1, "why": "nam is south, the opposite of bei (north)."},
	{"q": "Hai hama i-esh-ha?", "en": "Where is the sea?", "gesture": "Radi turns you around to face the nearest water, where the sun sets.",
		"options": ["Saima i-esh-da.", "Dongma i-esh-da.", "Beima i-esh-da."], "correct": 0, "why": "sai is west, where the sun sets."}
]

# Suri's lesson on question words. kind "meaning": pick the English meaning; "answer": answer in Tujuju.
const SCHOOL = [
	{"q": "Halke puka i-rav-im-ha?", "gesture": "Suri points at Vivi, who is reading, and raises their eyebrows.",
		"options": ["Who is reading the book?", "Where is the book?", "How many books are there?"], "correct": 0,
		"why": "hal means who. The question takes -ke because the reader acts on the book, and -ha replaces the evidential."},
	{"q": "Puka hama i-esh-ha?", "gesture": "Suri hides a book behind their back and looks around, puzzled.",
		"options": ["Who has the book?", "Where is the book?", "Is the book new?"], "correct": 1,
		"why": "hama means where. esh is be located, as in Puka tabma i-esh-da."},
	{"q": "Tike han t-i-rav-im-ha?", "gesture": "Suri points at the book in your hands and tilts their head.",
		"options": ["Why are you reading?", "Who are you?", "What are you reading?"], "correct": 2,
		"why": "han means what. Tike is you acting on something, and t-i- means you act on it."},
	{"q": "Hamur ravar i-esh-ha?", "gesture": "Suri sweeps a hand toward their students and waits for you to count them.",
		"options": ["Vel ravar i-esh-da.", "Mur ravar i-esh-da.", "Yan ravar i-esh-da."], "correct": 0,
		"why": "hamur means how many. There are two students, Vivi and Oli, so vel."}
]

# Desh's lagoon game: follow the command. Each entry: command, gloss, the matching action, decoys.
const DESH = [
	{"v": "Ta-sum-o!", "en": "Swim!", "act": "You wade in and swim a few strokes.", "words": ["sum", "-o"]},
	{"v": "Ta-pav-o!", "en": "Run!", "act": "You run along the sand.", "words": ["pav", "-o"]},
	{"v": "Ta-ning-o!", "en": "Sing!", "act": "You sing a few notes.", "words": ["ning", "-o"]},
	{"v": "Ta-nang-o!", "en": "Walk!", "act": "You walk slowly along the shore.", "words": ["nang", "-o"]},
	{"v": "Ta-sul-o!", "en": "Sleep!", "act": "You lie down on the sand and close your eyes.", "words": ["sul", "-o"]},
	{"v": "Ma-ta-pav-o-ki!", "en": "Do not run!", "act": "You stand completely still.", "words": ["pav", "ma- -ki"]},
	{"v": "Ta-pav-pav-o!", "en": "Run around and around!", "act": "You run around in circles until you are dizzy.", "words": ["pav-pav"]}
]

# Jeli's patient. Sije mimes where it hurts; the player chooses what Sije would say.
const PAIN = {"gesture": "Sije presses both hands to their temples and winces.",
	"options": ["Anni dauma tong i-esh-da.", "Anni tenma tong i-esh-da.", "Anni malma tong i-esh-da."], "correct": 0,
	"why": "Anni dau-ma tong i-esh-da: pain is located in my head. dau is head, ten is foot, mal is hand."}

const SUMMARY_NOTE = "Forms marked (doc) appear in the handoff document; others are composed from its rules."


# Oku's riddles. Each clue is a short Tujuju description; the answer is a noun.
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
const PARCELS = {"parcel_ketu": "ketu", "parcel_yalo": "asya", "parcel_oku": "oku"}

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
	["I go.", "na-lum"], ["I went.", "na-lum-pa"], ["You will go.", "ta-lum-fu"], ["They (one person) are running.", "i-pav-im"],
	["They (a group) usually swim.", "ri-sum-ur"], ["I am sleeping.", "na-sul-im"], ["They (one person) arrived (I saw it).", "i-tal-pa-da"],
	["They (a group) apparently arrived.", "ri-tal-pa-shi"], ["You reportedly arrived.", "ta-tal-pa-nu"], ["I am not going (I know it).", "ma-na-lum-ki-da"],
	["They (a group) will not run.", "ma-ri-pav-fu-ki"], ["They (one person) have arrived.", "i-tal-ak"], ["You are walking.", "ta-nang-im"],
	["I usually walk.", "na-nang-ur"], ["They (a group) will sleep.", "ri-sul-fu"]
]

# Sentence builder: tiles in neutral order, plus decoys with the wrong ending.
const TILES = [
	{"en": "I caught the fish.", "tiles": ["Anke", "tari", "k-i-nuk-ak-pa-da."], "decoys": ["An"], "tip": "The one who acts on something takes -ke: anke."},
	{"en": "The traveler arrived at the village.", "tiles": ["Kelar", "tekaru", "i-tal-ak-pa-da."], "decoys": ["Kelarke", "tekama"], "tip": "Arriving acts on nothing, so the traveler takes no -ke. To the village is teka-ru."},
	{"en": "Dofo built the bridge.", "tiles": ["Dofoke", "gira", "i-varn-ak-pa-da."], "decoys": ["Dofo"], "tip": "Building acts on the bridge, so Dofo takes -ke."},
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
	{"lv": 3, "en": "The child is sleeping in the village.", "tiles": ["Sanu", "tekama", "i-sul-im-da."], "decoys": ["Sanuke", "tekaru", "na-sul-im-da."], "tip": "Sleeping acts on nothing, so no -ke; one person (they) is i-."},
	{"lv": 3, "en": "The traveler went fishing.", "tiles": ["Kelar", "i-tari-nuk-ak-pa-da."], "decoys": ["Kelarke", "tari", "i-nuk-ak-pa-da."], "tip": "Fishing in general puts tari inside the verb, and then the traveler takes no -ke."},
	{"lv": 3, "en": "I usually travel to the small island by boat.", "tiles": ["An", "sena-li", "sendor-ru", "na-kel-ur-da."], "decoys": ["Anke", "sena-ma", "sendor-ta"], "tip": "By boat is -li, to the island is -ru, usually is -ur."},
	{"lv": 3, "en": "They say there is a room behind the big water.", "tiles": ["Var", "wak-ni", "shanma", "gan", "i-esh-nu."], "decoys": ["wak-ma", "i-esh-da."], "tip": "Behind something is X-ni shan-ma, and they say is the hearsay ending -nu."},
	{"lv": 3, "en": "Please give me medicine and tea.", "tiles": ["Yok", "e", "cha", "t-na-ven-o-ye."], "decoys": ["vo", "k-i-ven-o-ye."], "tip": "And is e. You give to me is t-na-ven, and please is -o-ye."},
	{"lv": 4, "en": "This hill is the highest of all.", "tiles": ["Ki", "sang", "polu-ta", "i-u-gao."], "decoys": ["polu-ma", "i-gao."], "tip": "Than all is polu-ta, and more is u- before the root."},
	{"lv": 4, "en": "I did not see them.", "tiles": ["Ma-k-ri-pal-ak-pa-ki-da."], "decoys": ["Ma-k-i-pal-ak-pa-ki-da.", "K-ri-pal-ak-pa-da.", "Ma-r-na-pal-ak-pa-ki-da."], "tip": "k- I act, ri- them, ma- ... -ki not. This one is straight from the grammar."}
]

# Market rush: things Ketu's stall sells. word -> English
const GOODS = {"guro": "fruit", "panak": "bread", "tari": "fish", "cha": "tea", "bombom": "candy"}
const NUMBERS = ["nul", "yan", "vel", "mur", "kes", "pan", "luk", "set", "bar", "gov", "dar"]

# "Say it yourself" challenges: residents ask you to build a sentence (index into TILES). Unlock at level 2.
const CHALLENGES = {"mira": 15, "dofo": 2, "ketu": 8, "jeli": 20, "desh": 17, "lira": 14, "rofi": 6, "lachu": 18, "oku": 19, "neri": 1, "suri": 12, "radi": 21, "sanu": 16, "vufi": 9, "asya": 11, "gav": 13}

const LEVEL_NAMES = ["", "Explorer", "Speaker", "Storyteller", "Elder"]

# Times of day, announced as they change.
const TIMES = {"salma": "dawn", "monar": "morning", "yar": "day", "wanar": "evening", "yesh": "night"}

# Personalities. thing: what they are proud of (Tujuju, English). trait decides how big their reactions are.
# likes and hates are gifts: tari (fish), panak (bread), cha (tea), gin (a coin).
const PEOPLE = {
	"vufi": {"trait": "cheerful", "thing": ["kel", "bag"], "likes": ["tari"], "hates": [],
		"secret": {"v": "An haima ma-na-sum-ur-ki-da.", "en": "I can't swim in the sea. (A harbor master who cannot swim!)"}},
	"mira": {"trait": "dramatic", "thing": ["yamat", "food"], "likes": ["cha"], "hates": ["panak"],
		"secret": {"v": "An yamat ma-na-dar-ur-ki-da. Ketuke i-dar-ur-da.", "en": "I don't cook the food. Ketu cooks it."}},
	"sanu": {"trait": "sleepy", "thing": ["ruk", "path"], "likes": ["panak"], "hates": [],
		"secret": {"v": "An rukma na-sul-ur-da.", "en": "I usually sleep on the path."}},
	"dofo": {"trait": "proud", "thing": ["gira", "bridge"], "likes": ["cha"], "hates": ["gin"],
		"secret": {"v": "Gira i-sava... shi.", "en": "The bridge is safe... apparently. (-shi: Dofo is only guessing!)"}},
	"lira": {"trait": "giggly", "thing": ["tovu", "story"], "likes": ["gin"], "hates": ["tari"],
		"secret": {"v": "Anni tovu-ir ri-fau-da.", "en": "My stories are false."}},
	"rofi": {"trait": "grumpy", "thing": ["mar", "horse"], "likes": ["panak"], "hates": ["cha", "bombom", "ret-gor"],
		"secret": {"v": "An mar-ru na-ning-ur-da.", "en": "I sing to the horse."}},
	"neri": {"trait": "cheerful", "thing": ["puka", "notebook"], "likes": ["tari", "panak", "cha", "gin"], "hates": [],
		"secret": {"v": "An tari-ta na-par-ur-da.", "en": "I am afraid of fish."}},
	"ketu": {"trait": "cheerful", "thing": ["tari", "fish"], "likes": ["tari", "gin"], "hates": ["panak"],
		"secret": {"v": "Tari-ir anni palar-ir ri-an-da.", "en": "The fish are my friends."}},
	"suri": {"trait": "proud", "thing": ["senak", "school"], "likes": ["cha"], "hates": [],
		"secret": {"v": "Anke puka ma-k-i-rav-pa-ki-da.", "en": "I did not read the book."}},
	"vivi": {"trait": "giggly", "thing": ["puka", "book"], "likes": ["panak", "bombom"], "hates": ["cha"],
		"secret": {"v": "Anke Oli-ni guro k-i-nuk-pa-da.", "en": "I took Oli's fruit. (Oli was framed!)"}},
	"oli": {"trait": "giggly", "thing": ["guro", "fruit"], "likes": ["panak", "bombom"], "hates": ["cha"],
		"secret": {"v": "An sao-ir-ru na-mel-ur-da.", "en": "I talk to the stars."}},
	"radi": {"trait": "sleepy", "thing": ["sang", "hill"], "likes": ["cha"], "hates": ["tari"],
		"secret": {"v": "An sang-ma na-sul-ur-da.", "en": "I do sleep on the hill."}},
	"jeli": {"trait": "cheerful", "thing": ["yok", "medicine"], "likes": ["cha"], "hates": [],
		"secret": {"v": "Yok i-wai-da. Polu i-zen-da.", "en": "The medicine is bad. Everyone knows."}},
	"sije": {"trait": "dramatic", "thing": ["yir", "clothes"], "likes": ["panak"], "hates": ["tari"],
		"secret": {"v": "Anni dauma tong ma-i-esh-pa-ki-da.", "en": "There was no pain in my head. (Sije faked it!)"}},
	"asya": {"trait": "dramatic", "thing": ["fardom", "lighthouse"], "likes": ["cha"], "hates": ["tari"],
		"secret": {"v": "An yesh-ta na-par-ur-da. I-zen-da.", "en": "I am afraid of the night. It's true."}},
	"desh": {"trait": "giggly", "thing": ["ning", "song"], "likes": ["tari", "ret-gor"], "hates": [],
		"secret": {"v": "Tari-ir ma-ri-seng-ur-ki-da.", "en": "The fish are not happy when I sing."}},
	"oku": {"trait": "proud", "thing": ["sek-ir", "stones"], "likes": ["cha"], "hates": ["gin"],
		"secret": {"v": "Sek-ir ma-ri-mel-ur-ki-da. An na-mel-ur-da.", "en": "The stones don't talk. I do."}},
	"gav": {"trait": "cheerful", "thing": ["kel-ir", "bags"], "likes": ["panak", "bombom", "ret-gor"], "hates": [],
		"secret": {"v": "Kel-ir-ma yamat i-ho-da.", "en": "The food in the bags is good."}},
	"lachu": {"trait": "grumpy", "thing": ["sena", "boat"], "likes": ["tari"], "hates": ["panak"],
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
	{"v": "Gira i-pav-im-da!", "en": "The bridge is running!"},
	{"v": "Mar-ni choni-ir ri-kawai-da!", "en": "The horse's chonies are cute!"},
	{"v": "Gira i-kaput... wala! Gira i-sava-da!", "en": "The bridge is broken... ta-da! The bridge is safe!"},
	{"v": "Yue pajama-ma i-sul-im-da!", "en": "The moon is sleeping in pajamas!"},
	{"v": "Dar ten!", "en": "Ten feet! (dar is ten and ten is foot. Confused yet?)"},
	{"v": "Hai-mar ma-i-pav-ki-da! I-sum-ur-da.", "en": "The seahorse doesn't run! It swims."},
	{"v": "Hen hen-ma i-esh-da!", "en": "The sky is in the sky! (hen means sky, not chicken)"},
	{"v": "Gor i-pav-pav-im-da!", "en": "The dog is running around and around!"},
	{"v": "Choni-ir ri-pav-pav-im-da!", "en": "The chonies are running around and around!"},
	{"v": "Gor karaoke i-ning-im-da. Bravo!", "en": "The dog is singing karaoke. Bravo!"},
	{"v": "Yue pitsa i-an-da!", "en": "The moon is a pizza!"},
	{"v": "Poltergaiske anni choni i-nuk-pa-shi!", "en": "Apparently the poltergeist took my chonies!"},
	{"v": "Robot i-sul-im-da. Bip... zzz", "en": "The robot is sleeping. Beep... zzz"},
	{"v": "Tari sena-li safari-ru i-kel-im-da!", "en": "The fish is going on safari by boat!"},
	{"v": "Gobeldigok! Gobeldigok!", "en": "Gibberish! Gibberish! (gobeldigok means nonsense)"},
	{"v": "Deshavu! ...Deshavu!", "en": "Deja vu! ...Deja vu! (Didn't I just say that?)"},
	{"v": "Marke selfi i-varn-pa-da!", "en": "The horse made a selfie!"},
	{"v": "Sipu choni-ma i-sul-im-da!", "en": "A spider is sleeping in the chonies!"}
]
const GIFT_WORDS = {"tari": "fish", "panak": "bread", "cha": "tea", "gin": "a coin", "bombom": "candy", "ret-gor": "hot dog"}

# False friends: Tujuju words that look like English words.
const FALSE_FRIENDS = [
	["hen", "a chicken", "sky", ["chicken", "egg"]], ["ten", "the number 10", "foot", ["ten", "hand"]], ["far", "far away", "fire", ["far away", "near"]],
	["pal", "a friend", "see", ["friend", "talk"]], ["gin", "a drink", "money", ["a drink", "water"]], ["bar", "a bar", "eight", ["a bar", "a door"]],
	["set", "a set", "seven", ["a set", "a table"]], ["men", "men", "front", ["men", "people"]], ["sum", "a sum", "swim", ["add up", "summer"]],
	["mar", "the sea (in Spanish!)", "horse", ["sea", "fish"]], ["mal", "bad (in Spanish!)", "hand", ["bad", "foot"]], ["dam", "a dam", "dark", ["a wall", "water"]]
]

# Sound words from Guarani: [word, scene, decoys]. Used by the "What's that sound?" game.
const SOUND_SCENES = [
	["pororo", "Corn kernels burst in a hot pot.", ["kororo", "siri"]], ["chiriri", "Fish fry in a pan of hot oil.", ["tarara", "vava"]],
	["kororo", "Radi is asleep under a tree, mouth wide open.", ["piriri", "pururu"]], ["tarara", "Desh blows into a big shell like a trumpet.", ["siri", "chiriri"]],
	["pururu", "You bite into a very crispy panak.", ["guarara", "vava"]], ["siri", "Water trickles down a rock into the pond.", ["sununu", "pororo"]],
	["vava", "A palm tree sways in the wind.", ["pururu", "tarara"]], ["piriri", "Sparks fizz and twinkle above the campfire.", ["kororo", "sununu"]],
	["guarara", "The waterfall roars and crashes.", ["piriri", "chiriri"]], ["sununu", "The whole village shouts and stomps about a missing hot dog.", ["siri", "vava"]]
]

# Endearments and playful insults, by personality.
const ENDEAR = {"cheerful": "Habibi!", "dramatic": "Bubala!", "giggly": "Shatsi!", "proud": "Monshu!", "sleepy": "Habibi... zzz", "grumpy": "Hmph. ...shatsi."}
const INSULT = {"grumpy": "Puts!", "giggly": "Baka! Ha!", "proud": "Shlemil!", "dramatic": "Puts-puts!", "cheerful": "Baka!", "sleepy": "...puts. zzz"}


# ---- quick practice for new words: word classes and English forms ----
# Intransitive verbs: [base, past, -ing]
const EXT_VERBS_I = {"lum": ["go", "went", "going"], "pav": ["run", "ran", "running"], "sul": ["sleep", "slept", "sleeping"], "sum": ["swim", "swam", "swimming"],
	"ning": ["sing", "sang", "singing"], "nang": ["walk", "walked", "walking"], "tal": ["arrive", "arrived", "arriving"], "mel": ["talk", "talked", "talking"], "kar": ["come", "came", "coming"],
	"pororo": ["pop", "popped", "popping"], "chiriri": ["sizzle", "sizzled", "sizzling"], "kororo": ["snore", "snored", "snoring"], "tarara": ["toot", "tooted", "tooting"],
	"piriri": ["sparkle", "sparkled", "sparkling"], "vava": ["sway", "swayed", "swaying"]}
# Transitive verbs: [base, past]
const EXT_VERBS_T = {"pal": ["see", "saw"], "nuk": ["take", "took"], "rav": ["read", "read"], "por": ["open", "opened"], "hep": ["close", "closed"],
	"dar": ["cook", "cooked"], "varn": ["build", "built"], "sir": ["look for", "looked for"], "mai": ["buy", "bought"], "ven": ["give", "gave"], "tar": ["bring", "brought"],
	"dop": ["hide", "hid"], "hiri": ["prank", "pranked"]}
const EXT_STATIVES = {"var": "big", "sen": "small", "nav": "warm", "ret": "hot", "len": "cold", "gao": "tall", "ho": "good", "wai": "bad", "seng": "happy",
	"sava": "safe", "ling": "bright", "dam": "dark", "dun": "short", "shora": "old", "nava": "new", "lei": "tired", "mar": "full", "hala": "fast", "kawai": "cute", "kaput": "broken", "tabu": "forbidden"}
const EXT_NOUNS_EXTRA = {"kel": ["bag", "bags"], "sek": ["stone", "stones"], "lin": ["rope", "ropes"], "yamat": ["food", "food"], "cha": ["tea", "tea"],
	"yok": ["herb", "herbs"], "ket": ["chair", "chairs"], "yir": ["shirt", "shirts"], "gin": ["coin", "coins"], "sao": ["star", "stars"], "yue": ["moon", "moons"],
	"riya": ["sun", "suns"], "hen": ["sky", "skies"], "tovu": ["story", "stories"], "palar": ["friend", "friends"], "ruk": ["path", "paths"], "pai": ["paper", "papers"],
	"senar": ["teacher", "teachers"], "ravar": ["student", "students"], "kelar": ["traveler", "travelers"], "dor": ["land", "lands"], "gan": ["room", "rooms"],
	"choni": ["pair of chonies", "chonies"], "bombom": ["candy", "candies"], "pajama": ["pajamas", "pajamas"], "fiyesta": ["party", "parties"],
	"buruhaha": ["uproar", "uproars"], "kafufel": ["fuss", "fusses"], "halabalu": ["racket", "rackets"], "shenani": ["trick", "tricks"],
	"pitsa": ["pizza", "pizzas"], "robot": ["robot", "robots"], "chochke": ["trinket", "trinkets"], "selfi": ["selfie", "selfies"], "sipu": ["spider", "spiders"],
	"poltergais": ["poltergeist", "poltergeists"], "bungalo": ["small house", "small houses"], "lavir": ["maze", "mazes"]}

# ---- poems from ning-guro berries and sao-dau mushrooms ----
# Poem nouns: [singular, plural]
const POEM_NOUNS = {"yue": ["the moon", "moons"], "riya": ["the sun", "suns"], "sao": ["a star", "the stars"], "hai": ["the sea", "seas"], "mora": ["the river", "rivers"],
	"murak": ["the tree", "the trees"], "par": ["the bird", "the birds"], "tari": ["the fish", "the fish"], "fal": ["the flower", "the flowers"], "guro": ["the fruit", "the fruits"],
	"sek": ["the stone", "the stones"], "sang": ["the hill", "the hills"], "far": ["the fire", "the fires"], "dom": ["the house", "the houses"], "sena": ["the boat", "the boats"],
	"puka": ["the book", "the books"], "panak": ["the bread", "the loaves"], "gor": ["the dog", "the dogs"], "mar": ["the horse", "the horses"], "ket": ["the chair", "the chairs"],
	"gira": ["the bridge", "the bridges"], "yamat": ["the food", "the meals"], "choni": ["a pair of chonies", "the chonies"], "bombom": ["the candy", "the candies"],
	"pajama": ["the pajama shirt", "the pajamas"], "fiyesta": ["the party", "the parties"],
	"pitsa": ["the pizza", "the pizzas"], "robot": ["the robot", "the robots"], "chochke": ["the trinket", "the trinkets"], "poltergais": ["the poltergeist", "the poltergeists"],
	"selfi": ["the selfie", "the selfies"], "sipu": ["the spider", "the spiders"]}
const POEM_PLACES = {"hen": "in the sky", "hai": "in the sea", "mora": "in the river", "yesh": "in the night", "salma": "at dawn", "teka": "in the village",
	"sang": "on the hill", "guro": "inside a fruit", "dau": "in my head", "kel": "in a bag", "fiyesta": "at the party", "pajama": "in pajamas",
	"karaoke": "at karaoke", "safari": "on safari", "lavir": "in the maze", "pitsa": "on a pizza"}
const POEM_INC = [["wak-ta", "drinks water", "drink water"], ["yamat-dar", "cooks food", "cook food"], ["puka-rav", "reads books", "read books"],
	["tari-nuk", "goes fishing", "go fishing"], ["mara-vun", "works the fields", "work the fields"]]

# ---- eighth expansion: pranks, teases, the great choni hunt, Hirimara ----

# Pranks you can play on villagers. {thing} and {thing_en} are filled with the person's favorite thing.
const PRANKS = [
	{"id": "spider", "label": "Fake spider", "v": "Ti-ni dau-ma sipu i-esh-da!", "en": "There's a spider on your head!", "words": ["sipu", "dau", "esh"],
		"act": "{name} slaps at their own head like a windmill."},
	{"id": "hide", "label": "Hide their thing", "v": "Ti-ni {thing} hama i-esh-ha? ...Anke k-i-dop-pa-da!", "en": "Where is your {thing_en}? ...I hid it!", "words": ["dop", "hama"],
		"act": "{name} searches under rocks, behind trees and inside their own pockets."},
	{"id": "choni", "label": "Look! Chonies!", "v": "Ti-ni choni fardom-ni tarma i-esh-da!", "en": "Your chonies are on top of the lighthouse!", "words": ["choni", "fardom", "tar"],
		"act": "{name} spins around and stares at the lighthouse. Nothing there... this time."},
	{"id": "ghost", "label": "Be a poltergeist", "v": "Uuuu... An poltergais na-an-da!", "en": "Woooo... I am a poltergeist!", "words": ["poltergais", "an"],
		"act": "{name} jumps straight up into the air."},
	{"id": "robot", "label": "Be a robot", "v": "Bip. Bup. An robot na-an-da. Ti-ni bombom t-na-ven-o!", "en": "Beep. Boop. I am a robot. Give me your candy!", "words": ["robot", "bombom", "ven"],
		"act": "{name} slowly starts to hand over an imaginary candy... then stops."}
]
# How each personality reacts to being pranked: [Tujuju, English, emote, friendship]
const PRANKED = {
	"dramatic": ["Aaah! AAAH!! ...Ho.", "Aaah! AAAH!! ...(faints, then gets up) Oh.", "faint", 0],
	"giggly": ["Ha! Ha! Hiri! Ti ta-ho-da!", "Ha ha! A prank! You're good!", "laugh", 1],
	"grumpy": ["Hmph! Ti puts ta-an-da!", "Hmph! You're a putz!", "angry", -1],
	"proud": ["Ma-na-par-ki-da. ...Ups.", "I was not scared. ...Oops.", "embarrassed", 0],
	"sleepy": ["Han...? Hiri...? zzz", "What...? A prank...? zzz", "sleepy", 0],
	"cheerful": ["Ha! Hiri! Kudos!", "Ha! A prank! Kudos to you!", "laugh", 1]
}
# Extra teases: [Tujuju, English, new word]
const TEASES = [
	["Ti kluts ta-an-da!", "You're a klutz! (kluts is borrowed from Yiddish klutz)", "kluts"],
	["Ti-ni dau i-var-var!", "Your head is HUGE! (doubling makes var stronger)", "var-var"],
	["Ti ninkompup ta-an-da!", "You're a nincompoop! (borrowed from English)", "ninkompup"],
	["Ti wai-dau ta-an-da!", "You're a dummy! (wai-dau, bad-head, is a calque of German Dummkopf)", "wai-dau"],
	["Ti-ni mel gobeldigok i-an-da!", "Your talk is gibberish! (gobeldigok is borrowed from English gobbledygook)", "gobeldigok"]
]
# Gav's six lost chonies: [id, position x, z, Tujuju hint, English hint]
const CHONI_HUNT = [
	["choni_hill", -56.5, -38.6, "Choni sang-ni tarma i-esh-shi.", "Apparently a choni is on top of the hill."],
	["choni_falls", 60.3, -35.6, "Choni wak hala i-lum-im-en mora-ni dalma i-esh-shi.", "Apparently a choni is beside the river where the water goes fast (near the waterfall)."],
	["choni_islet", 54.2, 86.2, "Choni Sendor-ma i-esh-nu.", "They say a choni is on Sendor, the small island."],
	["choni_ruins", -66.0, 43.5, "Choni shora sek-ir-ma i-esh-shi.", "Apparently a choni is among the old stones."],
	["choni_ghost", -98.0, -15.0, "Poltergaiske choni i-nuk-pa-nu.", "They say the poltergeist took a choni."],
	["choni_maze", 0.0, 0.0, "Choni lavir-ni kor-ma i-esh-shi.", "Apparently a choni is inside the maze."]
]

# ---------------------------------------------------------------- ninth expansion: overheard talk, letters, Teach Neri
const WORDS9 = {
	"par-yir": "feather (calque: par bird + yir clothing, so a feather is a bird's clothes)",
	"kraa": "kraa! (a parrot's squawk; not really a Tujuju word, but somebody keeps writing it)",
	"monarma": "in the morning (monar morning + -ma)", "yeshma": "at night (yesh night + -ma)"
}

# Overheard conversations. a and b stand near each other; get close and listen in.
# lines: [speaker, Tujuju, English]. q: comprehension question, opts[0] is correct.
# clue: a story clue for the mystery letters (see LETTER_CLUES).
const OVERHEAR = [
	{"id": "ov_paper", "a": "suri", "b": "ketu", "clue": "paper", "words": ["pai", "hama", "hal", "nuk"],
		"lines": [["suri", "Anni pai hama i-esh-ha?", "Where is my paper?"], ["ketu", "Ma-k-i-pal-ak-pa-ki-da.", "I didn't see it."], ["suri", "Halke pai i-nuk-pa-ha?", "Who took the paper?"], ["ketu", "Parke...? Maki. Ha!", "The bird...? No. Ha!"]],
		"q": "What is Suri looking for?", "opts": ["Their paper", "Their bag", "Ketu's fish"]},
	{"id": "ov_kraa", "a": "sije", "b": "jeli", "clue": "kraa", "words": ["yeshma", "sair", "mel", "kraa"],
		"lines": [["sije", "Yeshma sair i-mel-pa-da: “Kraa! Ti-ni palar!”", "Last night someone said: “Kraa! Your friend!” I heard it."], ["jeli", "Poltergais i-an-shi.", "Apparently it's the poltergeist."], ["sije", "Maki! Poltergais “kraa” ma-i-mel-ur-ki-da.", "No! The poltergeist doesn't usually say “kraa.”"]],
		"q": "What did Sije hear at night?", "opts": ["Someone saying “Kraa! Your friend!”", "Desh singing in the sea", "The poltergeist laughing"]},
	{"id": "ov_bread", "a": "mira", "b": "lira", "clue": "bread", "words": ["panak", "lum", "tab", "pai", "har"],
		"lines": [["mira", "Anni panak i-lum-pa-shi!", "Apparently my bread went away!"], ["lira", "Gavke panak i-yam-pa-nu.", "People say Gav ate the bread."], ["mira", "Maki. Tabma pai i-esh-pa-da. Pai-ma: “K-ta-har-da!”", "No. There was a paper on the table. On the paper: “Thank you!”"]],
		"q": "What did Mira find on the table?", "opts": ["A paper that says “Thank you!”", "Gav's bag", "A pair of chonies"]},
	{"id": "ov_mailbag", "a": "vufi", "b": "gav", "clue": "post", "words": ["monarma", "kel", "var-var", "zen"],
		"lines": [["vufi", "Gav, ti-ni kel i-var-var!", "Gav, your bag is huge!"], ["gav", "Ho. Monarma pai-ir kel-ma ri-esh-ur-da. Hal-ta? Ma-na-zen-ki-da.", "Yes. In the morning there are usually letters in the bag. From whom? I don't know."], ["vufi", "Hiri! Poltergais i-an-shi!", "A prank! Apparently it's the poltergeist!"]],
		"q": "When do the mystery letters show up in Gav's bag?", "opts": ["In the morning", "At night", "After lunch at the market"]},
	{"id": "ov_boat", "a": "lachu", "b": "vufi", "words": ["sena", "kaput", "haku", "par"],
		"lines": [["lachu", "Sena i-kaput-da.", "The boat is broken."], ["vufi", "Haku?", "Why?"], ["lachu", "Desh senama i-ning-pa-da. Sena i-par-pa-shi.", "Desh sang in the boat. Apparently the boat got scared."]],
		"q": "Why is the boat broken, according to Lachu?", "opts": ["Desh sang in it", "A whale bumped it", "Dofo built it"]},
	{"id": "ov_habibi", "a": "rofi", "b": "dofo", "words": ["gira", "har", "habibi", "ups"],
		"lines": [["rofi", "Ti-ni gira i-ho-da.", "Your bridge is good."], ["dofo", "K-ta-har-da! ...Ti ta-seng-ha?", "Thank you! ...Are you happy?"], ["rofi", "Maki. Ti anni mar-ru “habibi” ta-mel-ur-nu!", "No. People say you call my horse “habibi”!"], ["dofo", "...Ups.", "...Oops."]],
		"q": "Why is Rofi upset with Dofo?", "opts": ["Dofo calls Rofi's horse “habibi”", "The bridge is broken", "Dofo ate Rofi's bread"]},
	{"id": "ov_sleep", "a": "lira", "b": "sanu", "words": ["sul", "zen", "kororo"],
		"lines": [["lira", "Sanu, ti ta-sul-im-ha?", "Sanu, are you sleeping?"], ["sanu", "Ma-na-sul-im-ki-da... kororo... kororo...", "I'm not sleeping... snore... snore..."], ["lira", "Sanu i-sul-im-da. I-zen-da.", "Sanu is sleeping. I can see it. It's true."]],
		"q": "Is Sanu asleep?", "opts": ["Yes, even though Sanu says no", "No, Sanu is reading", "No, Sanu is swimming"]},
	{"id": "ov_feather", "a": "vivi", "b": "suri", "clue": "feather", "words": ["par-yir", "senak", "var-var"],
		"lines": [["vivi", "Senakma par-yir i-esh-da! I-var-var!", "There's a feather in the school! It's huge!"], ["suri", "Par-yir i-var-var? Par i-var-shi.", "A huge feather? Then apparently the bird is big."], ["vivi", "Ki par-yir Suri-ni pai-ni dalma i-esh-pa-da.", "This feather was next to Suri's paper."]],
		"q": "What did Vivi find at the school?", "opts": ["A huge feather", "A huge fish", "Suri's selfies"]},
	{"id": "ov_fruit", "a": "ketu", "b": "oli", "words": ["mal", "guro-guro", "han"],
		"lines": [["ketu", "Oli! Ti-ni malma han i-esh-ha?", "Oli! What's in your hand?"], ["oli", "Han? Maki... guro ma-i-esh-ki-da.", "What? No... there's no fruit."], ["ketu", "Ti-ni malma guro-guro i-esh-da!", "There are all kinds of fruit in your hand!"]],
		"q": "What is Oli hiding?", "opts": ["Fruit", "A fish", "A book"]},
	{"id": "ov_concert", "a": "desh", "b": "asya", "words": ["yeshma", "fardom", "ning", "-fu"],
		"lines": [["desh", "Asya! Yeshma fardom-ma na-ning-fu-da!", "Asya! Tonight I will sing at the lighthouse!"], ["asya", "Maki! Tari-ir ri-par-fu! Sena-ir ri-par-fu!", "No! The fish will get scared! The boats will get scared!"], ["desh", "Tarara! Tarara!", "Toot! Toot!"]],
		"q": "What does Desh want to do?", "opts": ["Sing at the lighthouse tonight", "Swim in the sea", "Fix the boat"]},
	{"id": "ov_night", "a": "oli", "b": "vivi", "clue": "night", "words": ["yeshma", "lum", "hama", "zen"],
		"lines": [["vivi", "Ketu-ni par yeshma hama i-esh-ha?", "Where is Ketu's parrot at night?"], ["oli", "Yeshma par kurma ma-i-esh-ki-da. Par i-lum-ur-da.", "At night the parrot is not at the market. It usually goes away."], ["vivi", "Hama-ru?", "To where?"], ["oli", "Ma-na-zen-ki-da!", "I don't know!"]],
		"q": "Where is Ketu's parrot at night?", "opts": ["Gone from the market; nobody knows where", "Asleep at the market", "At the lighthouse with Asya"]},
	{"id": "ov_horse", "a": "rofi", "b": "neri", "words": ["mel", "dap", "dan"],
		"lines": [["neri", "Rofi, ti ti-ni mar-ru ta-mel-ur-ha?", "Rofi, do you talk to your horse?"], ["rofi", "Ho. Dan mar ma-i-dap-ur-ki-da.", "Yes. But the horse doesn't usually answer."], ["neri", "Tari-ir ri-dap-ur-nu.", "People say fish answer."], ["rofi", "...Ketu i-an-shi.", "...That must be Ketu talking."]],
		"q": "What does Rofi say about their horse?", "opts": ["It doesn't answer", "It sings", "It's afraid of the night"]}
]

# Story clues about the mystery letter writer, shown in the Letters page.
const LETTER_CLUES = {
	"paper": "Someone keeps taking paper from Suri's school.",
	"kraa": "At night, somebody says “Kraa! Your friend!” (Sije heard it.)",
	"bread": "Mira's bread vanished. A thank-you note was left on the table.",
	"post": "The letters show up in Gav's bag every morning. Gav doesn't know who brings them.",
	"feather": "A huge feather turned up at the school, right next to Suri's paper.",
	"night": "Ketu's parrot leaves the market every night. Nobody knows where it goes."
}

# Mystery letters. Each needs the one before it answered, and (from letter 2 on) one more clue.
# replies: what you can write back. You choose the meaning, then build it with tiles.
const LETTERS = [
	{"v": "Aloha! An ti-ni palar na-an-da. Ti tekama ta-esh-da. K-ta-pal-ur-da. Chau!\n\nTi-ni palar",
		"en": "Hello! I am your friend. You are in the village. I see you all the time. Bye!\n\nYour friend",
		"words": ["aloha", "palar", "chau"],
		"q": "What does the writer say?", "opts": ["They see you all the time", "They are on the small island", "They are Neri"],
		"replies": [
			{"en": "Who are you?", "tiles": ["Hal", "ti", "ta-an-ha?"], "decoys": ["Han", "na-an-ha?"], "tip": "hal is who. You are is ta-an, and -ha makes a question."},
			{"en": "Hello, friend! I am happy.", "tiles": ["Aloha,", "palar!", "Na-seng-da."], "decoys": ["Chau,", "Ta-seng-da."], "tip": "na- is I and seng is happy."},
			{"en": "Where are you?", "tiles": ["Ti", "hama", "ta-esh-ha?"], "decoys": ["Hal", "na-esh-ha?"], "tip": "hama is where; esh is be located; you is ta-."}]},
	{"v": "Ti-ni pai i-ho-da! Anke polu-ni tovu k-i-zen-da. Sela na-an-ur-da. Kraa! ...Ups.\n\nTi-ni palar",
		"en": "Your letter is good! I know everyone's stories. I am usually alone. Kraa! ...Oops.\n\nYour friend",
		"words": ["tovu", "sela", "kraa", "ups"],
		"q": "What does the writer know?", "opts": ["Everyone's stories", "Where the treasure is", "How to fix the boat"],
		"replies": [
			{"en": "Why are you alone?", "tiles": ["Haku", "ti", "sela", "ta-an-ur-ha?"], "decoys": ["Hama", "na-an-ur-ha?"], "tip": "haku is why; you usually are is ta-an-ur, and -ha asks."},
			{"en": "What is “kraa”?", "tiles": ["Kraa", "han", "i-an-ha?"], "decoys": ["hal", "ta-an-ha?"], "tip": "han is what; it is is i-an."},
			{"en": "Please tell me a story.", "tiles": ["Tovu", "t-na-gao-o-ye."], "decoys": ["Tovuke", "k-ta-gao-o-ye."], "tip": "You tell me is t-na-gao, and please is -o-ye."}]},
	{"v": "Monarma Mira-ni panak k-i-yam-pa-da. Panak i-ho-ho-pa-da! Mira-ru “K-ta-har-da” k-i-gao-pa-da.\n\nTi-ni palar",
		"en": "This morning I ate Mira's bread. The bread was super good! I said “Thank you” to Mira.\n\nYour friend",
		"words": ["monarma", "yam", "ho-ho", "har"],
		"q": "What did the writer do this morning?", "opts": ["Ate Mira's bread", "Cooked fish for Ketu", "Sang at the lighthouse"],
		"replies": [
			{"en": "Don't take the bread!", "tiles": ["Panak", "ma-t-i-nuk-o-ki!"], "decoys": ["Panakke", "t-i-nuk-o!"], "tip": "Don't: ma- in front, -o for the command, -ki after it. t-i- means you act on it."},
			{"en": "Was the bread good?", "tiles": ["Panak", "i-ho-pa-ha?"], "decoys": ["Panakke", "i-ho-pa-da."], "tip": "-pa is past; -ha replaces -da to ask."},
			{"en": "Mira is not happy.", "tiles": ["Mira", "ma-i-seng-ki-da."], "decoys": ["Mirake", "i-seng-ki-da."], "tip": "Not wraps the verb: ma- ... -ki."}]},
	{"v": "Yeshma na-pav-ur-da. Ti-ni dom-ma na-tal-ur-da. Ti ta-sul-ur-da... kororo! Ha!\n\nTi-ni palar",
		"en": "At night I usually run around. I come to your house. You are asleep... snore! Ha!\n\nYour friend",
		"words": ["yeshma", "pav", "dom", "tal", "kororo"],
		"q": "When is the writer out and about?", "opts": ["At night", "In the morning", "At lunchtime"],
		"replies": [
			{"en": "Don't come to my house!", "tiles": ["Anni", "dom-ru", "ma-ta-kar-o-ki!"], "decoys": ["dom-ma", "ta-kar-o!"], "tip": "To my house is anni dom-ru. Don't: ma- ... -o-ki."},
			{"en": "Do you sleep at night?", "tiles": ["Ti", "yeshma", "ta-sul-ur-ha?"], "decoys": ["yeshru", "na-sul-ur-ha?"], "tip": "At night is yesh-ma. You usually sleep is ta-sul-ur."},
			{"en": "I will find you.", "tiles": ["Anke", "ti", "k-ta-sir-fu-da."], "decoys": ["Tike", "k-i-sir-fu-da."], "tip": "I act on you: k-ta-. sir is look for, -fu is the future."}]},
	{"v": "Ti t-na-sir-im-shi! Ha! Anke Suri-ni pai k-i-nuk-ur-da. Ti-ru pai k-i-ven-ur-da. Kraa!\n\nTi-ni palar",
		"en": "Apparently you are looking for me! Ha! I usually take Suri's paper. I give the paper to you. Kraa!\n\nYour friend",
		"words": ["sir", "nuk", "ven"],
		"q": "Where does the writer get the paper?", "opts": ["From Suri", "From Gav", "From Oku"],
		"replies": [
			{"en": "Give Suri the paper!", "tiles": ["Pai", "Suri-ru", "t-i-ven-o!"], "decoys": ["Suri-ma", "k-i-ven-o!"], "tip": "To Suri is Suri-ru. You give it is t-i-ven, and -o makes a command."},
			{"en": "Are you a bird?", "tiles": ["Ti", "par", "ta-an-ha?"], "decoys": ["Parke", "na-an-ha?"], "tip": "You are is ta-an. Being something takes no -ke."},
			{"en": "Your letters are good.", "tiles": ["Ti-ni", "pai-ir", "ri-ho-da."], "decoys": ["Anni", "i-ho-da."], "tip": "Many letters are they, so the verb takes ri-."}]},
	{"v": "Hal na-an-ha? Ti ta-zen-ha? Kraa! Kraa! ...Ups. Ups.\n\nTi-ni palar",
		"en": "Who am I? Do you know? Kraa! Kraa! ...Oops. Oops.\n\nYour friend",
		"words": ["hal", "zen"],
		"q": "What does the writer ask?", "opts": ["Who am I? Do you know?", "Where is Neri?", "Was the bread good?"],
		"replies": []}
]

# Who could the writer be? The answer is "par" (Ketu's parrot).
const SUSPECTS = [["Par", "Ketu's parrot"], ["Gav", "Gav the mail carrier"], ["Poltergais", "the poltergeist"], ["Oku", "Oku at the ruins"]]

# ---------------------------------------------------------------- tenth expansion: new grammar for asking and telling
# Game additions to the grammar: -kan (can, ability) and -vai (want to) go right after the root.
# New roots: pul (jump), tum (sit), fei (fly). kachaka (dance music) is also used as a verb root: dance.
const WORDS10 = {
	"-kan": "can, be able to (ability; a game addition, right after the root: na-sum-kan-da, I can swim)",
	"-vai": "want to (desire; a game addition, right after the root: na-sul-vai-da, I want to sleep)",
	"pul": "jump (root)", "tum": "sit (root)", "fei": "fly (root)",
	"bei-ma": "in the north (bei + -ma)", "nam-ma": "in the south", "dong-ma": "in the east", "sai-ma": "in the west"
}

# Find someone who can... verb root -> [English, people who can]
const KAN = {
	"sum": ["swim", ["desh", "lachu", "ketu", "oli"]],
	"ning": ["sing", ["desh", "lira", "mira", "sije"]],
	"dar": ["cook", ["mira", "ketu", "jeli"]],
	"rav": ["read", ["suri", "vivi", "oku", "neri", "vufi", "asya"]],
	"varn": ["build things", ["dofo", "lachu", "rofi"]],
	"pav": ["run fast", ["oli", "vivi", "gav", "neri"]],
	"fei": ["fly", []]
}
# Special answers: "id:root" -> [Tujuju, English, emote]
const KAN_LINES = {
	"dofo:sum": ["Maki! ...Ups. Mora i-len-da.", "No! ...Oops. The river is cold.", "embarrassed"],
	"desh:ning": ["Ho! Na-ning-kan-da! Tarara! TARARA!", "Yes! I can sing! Toot! TOOT!", "laugh"],
	"desh:sum": ["Ho! Haima na-ning-ka na-sum-ur-da!", "Yes! In the sea I sing and then I swim!", "proud"],
	"asya:sum": ["Maki! Hai i-var-var! Tari-ir ri-var-var!", "No! The sea is huge! The fish are huge!", "shocked"],
	"rofi:ning": ["Maki. Mar i-ning-kan-da. An maki.", "No. The horse can sing. Not me.", "angry"],
	"radi:pav": ["Pav...? Ma-na-pav-kan-ki-da... zzz", "Run...? I can't run... zzz", "sleepy"],
	"gav:pav": ["Ho! Polu-ru na-pav-ur-da!", "Yes! I run to everyone, every day!", "proud"],
	"mira:dar": ["HO! Na-dar-kan-da! Yamat i-ho-ho!", "YES! I can cook! The food is super good!", "proud"],
	"oku:rav": ["Ho. Anke sek-ir-ni tovu k-i-rav-kan-da.", "Yes. I can read the stones' stories.", "proud"],
	"sanu:sul": ["Ho... polu-ma na-sul-kan-da... zzz", "Yes... I can sleep anywhere... zzz", "sleepy"]
}
const FEI_NO = [["Maki! An par ma-na-an-ki-da!", "No! I am not a bird!"], ["Fei? Ha! Maki!", "Fly? Ha! No!"], ["Maki... dan par i-fei-kan-da.", "No... but birds can fly."], ["Maki! Ti ta-fei-kan-ha?!", "No! Can YOU fly?!"]]

# Things you can ask a villager to do. root -> [English, plain command, action]
const COMMANDS = {
	"ning": ["Sing!", "sing"], "kachaka": ["Dance!", "dance"], "pul": ["Jump!", "jump"], "tum": ["Sit down!", "sit"],
	"pav-pav": ["Run around and around!", "run"], "sul": ["Go to sleep!", "sleep"], "pal-ai": ["Look around!", "look"]
}

# Places you can ask about. word -> [English, position]
const WHERE_PLACES = {"kur": ["the market", Vector3(-50, 0, 12)], "senak": ["the school", Vector3(-47, 0, -5)], "fardom": ["the lighthouse", Vector3(75, 0, -7)],
	"sang": ["the hill", Vector3(-60, 0, -38)], "Hirimara": ["the prank field", Vector3(-108, 0, 0)], "gira": ["the bridge", Vector3(0, 0, -19)]}
const DIRS = {"bei": "north", "nam": "south", "dong": "east", "sai": "west"}

# ---------------------------------------------------------------- eleventh expansion: word wand, pass it on, guess who
const WORDS11 = {
	"gao-murak": "the word wand (gao tell + murak tree, wood: a telling stick). Sentences said with it come true.",
	"dau-yir": "hat (calque: dau head + yir clothing, head clothes)", "pal-sek": "glasses (calque: pal see + sek stone, see-stones)",
	"barba": "beard (borrowed from Spanish, Italian and Portuguese barba)", "kabum": "boom! (borrowed from English kaboom)"
}

# Word wand pieces. Who: [English, correct prefix]
const WAND_WHO = {"An": ["I", "na"], "Dofo": ["Dofo", "i"], "Mira": ["Mira", "i"], "Ketu": ["Ketu", "i"], "Desh": ["Desh", "i"], "Radi": ["Radi", "i"],
	"Rofi": ["Rofi", "i"], "Lira": ["Lira", "i"], "Gav": ["Gav", "i"], "Asya": ["Asya", "i"], "Polu": ["everyone", "ri"]}
# Where: [English, position]. haima is found at run time (the nearest sea).
const WAND_PLACES = {"tekama": ["in the village", Vector3(0, 0, 14)], "kurma": ["at the market", Vector3(-48, 0, 15)], "haima": ["in the sea", Vector3.ZERO],
	"fardom-ma": ["at the lighthouse", Vector3(70, 0, -6)], "sang-ma": ["on the hill", Vector3(-58, 0, -35)], "senak-ma": ["at the school", Vector3(-45, 0, 1)],
	"Hirimara-ma": ["in the prank field", Vector3(-98, 0, 4)]}
const WAND_VERBS = {"sum": ["swim", "swimming", "swam", "swim"], "ning": ["sing", "singing", "sang", "sing"], "kachaka": ["dance", "dancing", "danced", "dance"],
	"pul": ["jump", "jumping", "jumped", "jump"], "tum": ["sit", "sitting", "sat", "sit"], "sul": ["sleep", "sleeping", "slept", "sleep"], "pav-pav": ["run around", "running around", "ran around", "run"]}
const WAND_TENSE = {"im": "now (-im)", "fu": "soon (-fu)", "pa": "in the past (-pa)"}
const WAND_EV = {"da": "I see it (-da)", "shi": "apparently (-shi)", "nu": "people say (-nu)"}

# Pass it on: carry a story to two people. You heard it from the source, so a faithful relay changes
# the person (An -> the source's name, k-i- -> i-) and the evidential (-da -> -nu).
const RELAYS = [
	{"src": "lira", "to": ["mira", "ketu"], "v": "Anke Dofo-ni choni girama k-i-pal-pa-da!", "en": "I saw Dofo's chonies on the bridge!",
		"ok": "Lirake Dofo-ni choni girama i-pal-pa-nu.", "ok_en": "They say Lira saw Dofo's chonies on the bridge.",
		"wrong": {"me": ["Anke Dofo-ni choni girama k-i-pal-pa-da.", "Now everyone thinks YOU saw Dofo's chonies. You were never on that bridge!"],
			"da": ["Lirake Dofo-ni choni girama i-pal-pa-da.", "You said it like an eyewitness (-da), as if you watched Lira watching. Nobody believes you."],
			"noun": ["Lirake Dofo-ni mar girama i-pal-pa-nu.", "choni turned into mar. Now the story is that Dofo's HORSE is on the bridge. In chonies."]}},
	{"src": "gav", "to": ["vufi", "lachu"], "v": "Yeshma Oku sek-ir-su i-ning-pa-da!", "en": "Last night Oku sang with the stones! I saw it!",
		"ok": "Yeshma Oku sek-ir-su i-ning-pa-nu.", "ok_en": "They say Oku sang with the stones last night.",
		"wrong": {"me": ["Yeshma an sek-ir-su na-ning-pa-da.", "na- means I. Now the harbor thinks YOU sang to the stones all night."],
			"da": ["Yeshma Oku sek-ir-su i-ning-pa-da.", "You used -da, as if you saw it yourself. Lachu wants to know why you were at the ruins at night."],
			"noun": ["Yeshma Oku tari-ir-su i-ning-pa-nu.", "sek-ir turned into tari-ir. Now Oku sings with the FISH."]}},
	{"src": "desh", "to": ["jeli", "sije"], "v": "Anke haima yue k-i-pal-pa-da! Yue i-sum-im-da!", "en": "I saw the moon in the sea! The moon is swimming!",
		"ok": "Deshke haima yue i-pal-pa-nu. Yue i-sum-im-nu.", "ok_en": "They say Desh saw the moon in the sea, and that the moon is swimming.",
		"wrong": {"me": ["Anke haima yue k-i-pal-pa-da! Yue i-sum-im-da!", "Now Jeli thinks YOU saw the moon swimming, and they want to check your temperature."],
			"da": ["Deshke haima yue i-pal-pa-da. Yue i-sum-im-da.", "-da says you saw it. Sije asks you to show them the swimming moon. You can't."],
			"noun": ["Deshke haima yok i-pal-pa-nu. Yok i-sum-im-nu.", "yue turned into yok. Now the MEDICINE is swimming in the sea, and Jeli is very upset."]}}
]

# Guess who: yes/no questions. key -> [Tujuju, English]
const GUESS_Q = {
	"hat": ["Sa-su dau-yir i-esh-ha?", "Do they have a hat? (Is a hat with them?)"],
	"glasses": ["Sa-su pal-sek i-esh-ha?", "Do they have glasses?"],
	"beard": ["Sa-su barba i-esh-ha?", "Do they have a beard?"],
	"small": ["Sa i-sen-ha?", "Are they small?"],
	"tall": ["Sa i-gao-ha?", "Are they tall?"],
	"east": ["Sa dong-ma i-esh-ur-ha?", "Do they usually stay in the east?"],
	"west": ["Sa sai-ma i-esh-ur-ha?", "Do they usually stay in the west?"],
	"swim": ["Sa i-sum-kan-ha?", "Can they swim?"],
	"read": ["Sa i-rav-kan-ha?", "Can they read?"],
	"sing": ["Sa i-ning-kan-ha?", "Can they sing?"],
	"sleepy": ["Sa i-sul-ur-ha?", "Do they sleep a lot?"],
	"happy": ["Sa i-seng-ur-ha?", "Are they usually happy?"]
}
const GUESS_PEOPLE = ["vufi", "mira", "sanu", "dofo", "lira", "rofi", "ketu", "suri", "vivi", "oli", "radi", "jeli", "sije", "asya", "desh", "oku", "gav", "lachu"]

# ---------------------------------------------------------------- twelfth expansion: yesen (improv scenes)
const WORDS12 = {
	"yesen": "an improv scene where you accept what your partner says and add to it (borrowed from English yes, and, the first rule of improv)",
	"ho, e": "yes, and... (a calque of English yes, and: ho yes + e and)",
	"kudos": "praise, well done (borrowed from Greek kudos, glory)"
}

# Each scene: the villager starts, you answer with Ho, e... (yes, and...) plus a sentence you assemble.
# rounds: [villager Tujuju, English, ideas]; each idea: [English, tiles]. end: the villager's last line.
const YESEN = [
	{"id": "soup", "sug": ["chiriri", "sizzle"], "who": "mira", "title": "The runaway soup", "rounds": [
		["Yamat i-pav-im-da!", "The food is running!", [["the food is swimming in the river!", ["Yamat", "morama", "i-sum-im-da."]], ["I can see the food!", ["Anke", "yamat", "k-i-pal-da."]]]],
		["Yamat ti-ru i-mel-im-da!", "The food is talking to you!", [["I am talking to the food.", ["An", "yamat-ru", "na-mel-im-da."]], ["the food is my friend.", ["Yamat", "anni palar", "i-an-da."]]]],
		["Yamat ti-su i-kachaka-vai-da!", "The food wants to dance with you!", [["I dance with the food!", ["An", "yamat-su", "na-kachaka-im-da."]], ["everyone is dancing!", ["Polu", "ri-kachaka-im-da."]]]]],
		"end": ["Bravo! Yamat i-seng-da! ...Dan anni yamat hama i-esh-ha?", "Bravo! The food is happy! ...But where is my food?"]},
	{"id": "moonbridge", "sug": ["sao", "star"], "who": "dofo", "title": "A bridge to the moon", "rounds": [
		["Anke yue-ru gira k-i-varn-pa-da!", "I built a bridge to the moon!", [["I will walk to the moon!", ["An", "yue-ru", "na-nang-fu-da."]], ["the moon is happy!", ["Yue", "i-seng-da."]]]],
		["Yue-ma tari-ir ri-esh-da!", "There are fish on the moon!", [["the fish are singing!", ["Tari-ir", "ri-ning-im-da."]], ["Ketu sells the fish!", ["Ketuke", "tari", "i-mai-ai-ur-da."]]]],
		["Ups! Gira i-kaput-da!", "Oops! The bridge is broken!", [["I will swim home!", ["An", "dom-ru", "na-sum-fu-da."]], ["the moon has a boat!", ["Yue-su", "sena", "i-esh-da."]]]]],
		"end": ["Ha! Dofo-ni gira i-ho-ho... shi.", "Ha! Dofo's bridge is super good... apparently."]},
	{"id": "singfish", "sug": ["bravo", "well done!"], "who": "ketu", "title": "The singing fish", "rounds": [
		["Ki tari i-ning-kan-da!", "This fish can sing!", [["the fish sings karaoke!", ["Tari", "karaoke-ma", "i-ning-im-da."]], ["I am the fish's friend.", ["An", "tari-ni palar", "na-an-da."]]]],
		["Tarike gin i-nuk-vai-da!", "The fish wants money!", [["I give one coin to the fish.", ["Anke", "yan gin", "tari-ru", "k-i-ven-im-da."]], ["the fish buys bread!", ["Tarike", "panak", "i-mai-im-da."]]]],
		["Tari Desh-su i-ning-fu-da!", "The fish will sing with Desh!", [["everyone is dancing!", ["Polu", "ri-kachaka-im-da."]], ["Asya is scared!", ["Asya", "i-par-im-da."]]]]],
		"end": ["Bravo! Tari i-seng-da! Tari-pitsa... maki, maki!", "Bravo! The fish is happy! Fish pizza... no, no!"]},
	{"id": "bigsong", "sug": ["guarara", "a roar"], "who": "desh", "title": "The enormous song", "rounds": [
		["Anni ning i-var-var-da!", "My song is huge!", [["the song is in the sky!", ["Ning", "hen-ma", "i-esh-da."]], ["the fish are dancing!", ["Tari-ir", "ri-kachaka-im-da."]]]],
		["Ning sena-ru i-lum-im-da!", "The song is going to the boat!", [["Lachu is sleeping in the boat!", ["Lachu", "sena-ma", "i-sul-im-da."]], ["the boat is singing!", ["Sena", "i-ning-im-da."]]]],
		["Ti ta-ning-o-ye! Tarara!", "Please sing! Toot!", [["I sing with you!", ["An", "ti-su", "na-ning-im-da."]], ["I sing to the moon!", ["An", "yue-ru", "na-ning-im-da."]]]]],
		"end": ["Wala! Hai i-seng-da! Bravo!", "Ta-da! The sea is happy! Bravo!"]},
	{"id": "notsleeping", "sug": ["kororo", "snore"], "who": "radi", "title": "Radi is NOT sleeping", "rounds": [
		["Ma-na-sul-im-ki-da... kororo...", "I'm not sleeping... snore...", [["you are sleeping on the hill.", ["Ti", "sang-ma", "ta-sul-im-da."]], ["the stars are sleeping too.", ["Sao-ir", "ri-sul-im-da."]]]],
		["Sang-ma par i-esh-da... par i-fei-kan-da...", "There's a bird on the hill... the bird can fly...", [["I can fly too!", ["An", "na-fei-kan-da."]], ["the bird is sleeping!", ["Par", "i-sul-im-da."]]]],
		["Han? Ti hal ta-an-ha?", "What? Who are you?", [["I am your friend!", ["An", "ti-ni palar", "na-an-da."]], ["I am a bird!", ["An", "par", "na-an-da."]]]]],
		"end": ["Ho... palar... par... zzz", "Yes... friend... bird... zzz"]},
	{"id": "horsehead", "sug": ["dau-yir", "hat"], "who": "rofi", "title": "The horse on my head", "rounds": [
		["Mar anni dau-ma i-esh-da!", "The horse is on my head!", [["the horse is singing!", ["Mar", "i-ning-im-da."]], ["the horse has a hat!", ["Mar-su", "dau-yir", "i-esh-da."]]]],
		["Mar ti-ru “puts” i-mel-pa-da!", "The horse called you a putz!", [["I am a putz!", ["An", "puts", "na-an-da."]], ["the horse is a putz!", ["Mar", "puts", "i-an-da."]]]],
		["Mar sela i-an-vai-da.", "The horse wants to be alone.", [["I will go home.", ["An", "dom-ru", "na-lum-fu-da."]], ["the horse is going to Hirimara.", ["Mar", "Hirimara-ru", "i-lum-im-da."]]]]],
		"end": ["Hmph. ...Ha! Ti ta-ho-da.", "Hmph. ...Ha! You're good."]},
	{"id": "treeletter", "sug": ["pai", "paper"], "who": "gav", "title": "A letter for a tree", "rounds": [
		["Murak-ru pai i-esh-da!", "There's a letter for the tree!", [["the tree is reading the letter!", ["Murakke", "pai", "i-rav-im-da."]], ["I am bringing the letter.", ["Anke", "pai", "k-i-tar-im-da."]]]],
		["Murak i-par-im-da! Pai i-var-var!", "The tree is scared! The letter is huge!", [["the letter came from Hirimara!", ["Pai", "Hirimara-ta", "i-tal-pa-da."]], ["the letter is a poltergeist!", ["Pai", "poltergais", "i-an-da."]]]],
		["Pai ti-su i-mel-vai-da!", "The letter wants to talk with you!", [["I am talking with the letter!", ["An", "pai-su", "na-mel-im-da."]], ["the tree is happy now!", ["Murak", "i-seng-da."]]]]],
		"end": ["Kel-ir i-seng-da! Bravo!", "The bags are happy! Bravo!"]},
	{"id": "dogteacher", "sug": ["ravar", "student"], "who": "suri", "title": "The dog who reads", "rounds": [
		["Senak-ma gor i-rav-im-da!", "A dog is reading in the school!", [["the dog is reading a book!", ["Gorke", "puka", "i-rav-im-da."]], ["the dog is the teacher!", ["Gor", "senar", "i-an-da."]]]],
		["Gor-su ravar-ir ri-esh-da: mar, par, tari!", "The dog has students: a horse, a bird, a fish!", [["the fish is swimming in the school!", ["Tari", "senak-ma", "i-sum-im-da."]], ["the bird can read!", ["Par", "i-rav-kan-da."]]]],
		["Ti ravar ta-an-ha?", "Are you a student?", [["I am the dog's student!", ["An", "gor-ni ravar", "na-an-da."]], ["I am a horse!", ["An", "mar", "na-an-da."]]]]],
		"end": ["Ho! Ti ta-ho-da! ...Gor i-seng-da.", "Yes! You are good! ...The dog is happy."]},
	{"id": "sleepysun", "sug": ["pajama", "pajamas"], "who": "lira", "title": "The sun's pajamas", "rounds": [
		["Riya yeshma i-sul-ur-nu!", "They say the sun sleeps at night!", [["the moon sings at night.", ["Yue", "yeshma", "i-ning-ur-da."]], ["the sun sleeps in my bed!", ["Riya", "anni sulum-ma", "i-sul-ur-da."]]]],
		["Riya-su pajama i-esh-da!", "The sun has pajamas!", [["the pajamas are hot!", ["Pajama", "i-ret-da."]], ["the moon has chonies!", ["Yue-su", "choni", "i-esh-da."]]]],
		["Ki tovu polu-ru ta-gao-o-ye!", "Please tell everyone this story!", [["I will tell Gav the story.", ["Anke", "tovu", "Gav-ru", "k-i-gao-fu-da."]], ["the parrot is telling everyone!", ["Parke", "polu-ru", "i-gao-im-da."]]]]],
		"end": ["Ha! Ha! Tovu i-ho-ho!", "Ha! Ha! The story is super good!"]},
	{"id": "spider", "sug": ["far", "fire"], "who": "asya", "title": "The lighthouse spider", "rounds": [
		["Fardom-ma sipu i-esh-da!", "There's a spider in the lighthouse!", [["the spider is huge!", ["Sipu", "i-var-var-da."]], ["the spider is reading a book!", ["Sipuke", "puka", "i-rav-im-da."]]]],
		["Sipu an-ru i-mel-im-da: “Aloha!”", "The spider says to me: “Hello!”", [["the spider is your friend.", ["Sipu", "ti-ni palar", "i-an-da."]], ["I say “Bye!” to the spider.", ["An", "sipu-ru", "“Chau!”", "na-mel-im-da."]]]],
		["Sipu fardom-ma i-sul-vai-da...", "The spider wants to sleep in the lighthouse...", [["you will sleep with the spider!", ["Ti", "sipu-su", "ta-sul-fu-da."]], ["the spider will sleep in your hat!", ["Sipu", "ti-ni dau-yir-ma", "i-sul-fu-da."]]]]],
		"end": ["Aaa! ...Ho. Sipu i-kawai... shi.", "Aaa! ...OK. The spider is cute... apparently."]},
	{"id": "footflower", "sug": ["mara", "field"], "who": "jeli", "title": "A flower on your foot", "rounds": [
		["Ti-ni ten-ma fal i-esh-da!", "There's a flower on your foot!", [["the flower is singing!", ["Fal", "i-ning-im-da."]], ["my foot is happy.", ["Anni", "ten", "i-seng-da."]]]],
		["Fal i-var-im-da! Fal i-var-var!", "The flower is growing! It's huge!", [["the flower is eating bread!", ["Falke", "panak", "i-yam-im-da."]], ["Sije is in the flower!", ["Sije", "fal-ma", "i-esh-da."]]]],
		["Anke ti-ru yok k-i-ven-fu-da.", "I will give you medicine.", [["the medicine is bad!", ["Yok", "i-wai-da."]], ["I give the medicine to the flower.", ["Anke", "yok", "fal-ru", "k-i-ven-im-da."]]]]],
		"end": ["Ho! Fal i-seng-da, ti ta-seng-da!", "Yes! The flower is happy, you are happy!"]},
	{"id": "talkstone", "sug": ["shora", "old"], "who": "oku", "title": "The talking stone", "rounds": [
		["Ki sek i-mel-kan-da!", "This stone can talk!", [["the stone is singing!", ["Sek", "i-ning-im-da."]], ["the stone is very old.", ["Sek", "i-shora-da."]]]],
		["Sekke ti-ru tovu i-gao-im-da.", "The stone is telling you a story.", [["the story has chonies in it.", ["Tovu-su", "choni", "i-esh-da."]], ["I am falling asleep.", ["An", "na-sul-im-da."]]]],
		["Sek ti-ni palar i-an-vai-da.", "The stone wants to be your friend.", [["I will take the stone home.", ["Anke", "sek", "dom-ru", "k-i-tar-fu-da."]], ["I dance with the stone.", ["An", "sek-su", "na-kachaka-im-da."]]]]],
		"end": ["Sek i-seng-da. Ho.", "The stone is happy. Yes."]},
	{"id": "flyboat", "sug": ["fong", "wind"], "who": "lachu", "title": "The flying boat", "rounds": [
		["Anni sena i-fei-kan-da!", "My boat can fly!", [["the boat flies to the moon!", ["Sena", "yue-ru", "i-fei-im-da."]], ["the fish are scared!", ["Tari-ir", "ri-par-im-da."]]]],
		["Hen-ma sena-ir ri-esh-da!", "There are boats in the sky!", [["the birds are swimming!", ["Par-ir", "ri-sum-im-da."]], ["Gav brings the letters by boat.", ["Gavke", "pai-ir", "sena-li", "i-tar-im-da."]]]],
		["Ti sena-ma ta-kar-o-ye!", "Please come into the boat!", [["I will bring bread!", ["Anke", "panak", "k-i-tar-fu-da."]], ["I am sitting in the boat!", ["An", "sena-ma", "na-tum-im-da."]]]]],
		"end": ["Hmph... Ha! Sena i-ho-da!", "Hmph... Ha! The boat is good!"]},
	{"id": "fruitchoni", "sug": ["shenani", "mischief"], "who": "oli", "title": "A choni in the fruit", "rounds": [
		["Guro-ma choni i-esh-da!", "There's a choni in the fruit!", [["the choni is tiny!", ["Choni", "i-sen-sen-da."]], ["Gav is happy!", ["Gav", "i-seng-da."]]]],
		["Choni guro-ta i-pav-pa-da!", "The choni ran out of the fruit!", [["the choni is running to the market!", ["Choni", "kur-ru", "i-pav-im-da."]], ["I caught the choni!", ["Anke", "choni", "k-i-nuk-pa-da."]]]],
		["Ti choni-na ta-an-da!", "You are a choni person!", [["I am happy!", ["An", "na-seng-da."]], ["you are a choni person!", ["Ti", "choni-na", "ta-an-da."]]]]],
		"end": ["Ha! Ha! Choni-na! Bravo!", "Ha! Ha! Choni people! Bravo!"]},
	{"id": "inthebook", "sug": ["tovu", "story"], "who": "neri", "title": "You are in my book", "rounds": [
		["Ki puka-ma ti ta-esh-da!", "You are in this book!", [["I am reading the book!", ["Anke", "puka", "k-i-rav-im-da."]], ["the book is huge!", ["Puka", "i-var-var-da."]]]],
		["Puka-ma ti mar-su ta-sum-pa-da!", "In the book, you swam with a horse!", [["the horse can sing!", ["Mar", "i-ning-kan-da."]], ["I swam with the fish too.", ["An", "tari-ir-su", "na-sum-pa-da."]]]],
		["Ti han ta-mel-vai-ha?", "What do you want to say?", [["I want to be in Hirimara!", ["An", "Hirimara-ma", "na-esh-vai-da."]], ["I want to sleep!", ["An", "na-sul-vai-da."]]]]],
		"end": ["Ha! Tovu i-ho-ho-da!", "Ha! The story is super good!"]},
	{"id": "bagfish", "sug": ["hai", "sea"], "who": "vufi", "title": "The fish who wants your bag", "rounds": [
		["Haima var-var tari i-esh-da!", "There's a huge fish in the sea!", [["the fish has a hat!", ["Tari-su", "dau-yir", "i-esh-da."]], ["the fish is coming to the village!", ["Tari", "tekaru", "i-kar-im-da."]]]],
		["Tari an-ru i-mel-im-da: “Ti-ni kel t-na-ven-o-ye!”", "The fish says to me: “Please give me your bag!”", [["I give the bag to the fish.", ["Anke", "kel", "tari-ru", "k-i-ven-im-da."]], ["the fish wants chonies.", ["Tarike", "choni", "i-nuk-vai-da."]]]],
		["Tari kel-su i-sum-im-da...", "The fish is swimming away with the bag...", [["the bag is happy!", ["Kel", "i-seng-da."]], ["I am sleeping by the sea.", ["An", "hai-ni dal-ma", "na-sul-im-da."]]]]],
		"end": ["Ha! Kel-ir i-sum-ur-shi!", "Ha! Apparently bags usually swim!"]},
	{"id": "dogbook", "sug": ["yamat", "food"], "who": "vivi", "title": "The dog ate my book", "rounds": [
		["Gorke anni puka i-yam-pa-da!", "The dog ate my book!", [["the dog is reading in its belly!", ["Gor", "i-rav-im-da."]], ["the book is in the dog!", ["Puka", "gor-ma", "i-esh-da."]]]],
		["Gor i-mel-im-da: “Puka i-ho!”", "The dog says: “The book is good!”", [["the dog is a teacher!", ["Gor", "senar", "i-an-da."]], ["I will give the dog a book.", ["Anke", "puka", "gor-ru", "k-i-ven-fu-da."]]]],
		["Suri ma-i-seng-ki-da...", "Suri is not happy...", [["Suri is reading the dog!", ["Surike", "gor", "i-rav-im-da."]], ["everyone is happy now!", ["Polu", "ri-seng-da."]]]]],
		"end": ["Ha! Ha! Gor ravar i-an-da!", "Ha! Ha! The dog is a student!"]}
]

# the cenote
const WORDS13 = {
	"sonot": "a cenote, a deep water-filled sinkhole (borrowed from Yucatec Maya ts'ono'ot, through Spanish cenote)",
	"lup": "dive (root): na-lup-im-da, I am diving"
}

# ---------------------------------------------------------------- the lost writing (Ayvu) and Var Tari
const WORDS14 = {
	"kir": "carve, write (root)",
	"ayvu": "Ayvu, the old Tujuju writing, a syllabary (borrowed from Guarani ayvu: language, speech)",
	"var tari": "Var Tari, the great fish who sleeps in the cenote (var big + tari fish)"
}

# ---------------------------------------------------------------- the capybaras
# kapibara: from Guarani capii-bara (the RAE's etymology for capibara). A capybara's name is
# always exactly two vowel sounds and nothing else, so in Ayvu it is two lone-vowel marks.
# The Ayvu typewriter: Dofo builds one once you can read Ayvu.
const WORDS17 = {
	"kir-kor": "typewriter, a writing box (kir write + kor box)",
	"varn": "build (root)"
}
const WORDS16 = {
	"kapibara": "capybara, the biggest rodent, a gentle grass-eater that loves water (from Guarani capii-bara). A capybara's name is always exactly two vowel sounds."
}
# [name, fur color]. The first five rest along the way to the cenote; the last swims in it.
const CAPYBARAS = [["Ai", "8b5a2b"], ["Eo", "a8794a"], ["Ua", "6a4226"], ["Io", "b8915f"], ["Ou", "7a5638"], ["Ea", "966238"]]

# ---------------------------------------------------------------- the stork
# Tujuju: tuyuyu is a South American name for the jabiru (Jabiru mycteria) and the wood stork
# (Mycteria americana); the RAE gives its origin as uncertain, perhaps Guarani. The model is a
# jabiru. The island and the language are named after it.
const WORDS15 = {
	"tujuju": "jabiru stork, a huge white wading bird with a bare black head and neck, a red collar and a giant bill (from tuyuyu, a South American name for big storks, perhaps from Guarani). The island and its language are named after it."
}
# The picture stone near the surface: a word under each picture.
const KIR_PICTURES = [["tari", "fish"], ["riya", "sun"], ["sao", "star"], ["par", "bird"], ["wak", "water"]]
# The creation story, carved deeper and deeper. It is told with -nu: this is what people say.
const KIR_STORY = [
	{"depth": 9.0, "v": "Yanve yarma hai e yesh sela ri-esh-pa-nu.", "en": "On the first day, they say, there was only the sea and the night."},
	{"depth": 15.0, "v": "Var tari haima i-sul-pa-nu. Tari-ni dau-ma sao-ir ri-esh-pa-nu.", "en": "A great fish slept in the sea, they say. On the fish's head there were stars."},
	{"depth": 21.0, "v": "Tari i-pul-ak-pa-nu. Sao-ir hen-ru ri-lum-ak-pa-nu.", "en": "The fish jumped, they say. The stars went up into the sky."},
	{"depth": 27.0, "v": "Tarike ning i-ning-pa-nu. Ning-ta dor i-tal-ak-pa-nu.", "en": "The fish sang a song, they say. Out of the song, the land arrived."},
	{"depth": 30.0, "pic": "stork", "v": "Tujuju-ir hen-ta ri-tal-ak-pa-nu. Sair-ir tujuju-ir-ni shanma ri-lum-pa-nu.", "en": "The storks came down from the sky, they say. The people went behind the storks."},
	{"depth": 33.0, "v": "Sair-ir dor-ma ri-tal-ak-pa-nu. Sair-irke ayvu sek-ir-ma ri-kir-pa-nu.", "en": "People came to the land, they say. The people carved the writing into the stones."},
	{"depth": 36.5, "pic": "capybara", "v": "Kapibara-ir ri-tal-ak-pa-nu. Kapibara-irke sair-ir sonot-ru ri-tar-ak-pa-nu.", "en": "The capybaras came, they say. The capybaras brought the people to the cenote."},
	{"depth": 40.0, "v": "Dan yar-ir ri-lum-pa-nu. Sair-irke ayvu ri-mong-ak-pa-nu.", "en": "But the days went by, they say. The people forgot the writing."},
	{"depth": 52.0, "v": "Tari sonot-ma i-sul-im-nu. Tari ayvu i-zen-nu. Ti ayvu tekaru ta-tar-fu-ha?", "en": "The fish sleeps in the cenote, they say. The fish knows the writing. Will you bring the writing to the village?"}
]
# Var Tari speaks only with evidentials: what it saw (-da), what it heard (-nu), what it works out (-shi).
# [Tujuju, English, ending, condition]
const GUARDIAN_LINES = [
	["Ti sonot-ma ta-lup-pa-da.", "You dived into the cenote. I saw it.", "da", "always"],
	["Anke hen ma-k-i-pal-pa-ki-da.", "I have never seen the sky. (I know this myself.)", "da", "always"],
	["Hen-ma par-ir ri-ning-ur-nu.", "They say birds sing in the sky.", "nu", "always"],
	["Tari-ir sen-sen anni dal-ma ri-sum-ur-da.", "Tiny fish usually swim beside me. I see it.", "da", "always"],
	["Ti ayvu ta-rav-pa-da.", "You read the writing. I saw it.", "da", "read"],
	["Ti-ni ten-ma dor i-esh-pa-shi.", "Apparently there was land on your feet. (You came from the land.)", "shi", "always"],
	["Yeshma i-an-shi. Ling i-dam-shi.", "Apparently it is night. The light seems dark.", "shi", "night"],
	["Ti tari-ir ta-nuk-pa-shi... Hm.", "Apparently you caught fish... Hm.", "shi", "fish"],
	["Ti polu-ru ta-ning-pa-nu. Polu ri-seng-pa-nu.", "They say you sang for everyone. They say everyone was happy.", "nu", "yesen"],
	["Gav-ni choni-ir ri-tal-ak-pa-nu. Ha... ha.", "They say Gav's chonies came back. Ha... ha.", "nu", "chonies"],
	["Par ti-ni palar i-an-nu.", "They say a bird is your friend.", "nu", "letters"],
	["Fardom yeshma i-ling-ur-nu.", "They say the lighthouse is bright at night.", "nu", "lighthouse"],
	["Ti-su palar-ir ri-esh-nu.", "They say you have many friends.", "nu", "friends"],
	["Ti-su gao-murak i-esh-nu.", "They say you have the telling stick.", "nu", "wand"],
	["Tujuju-ir dor-ma ri-esh-ur-nu.", "They say storks live on the land.", "nu", "stork"],
	["Kapibara-ir sonot-ma ri-sum-ur-da.", "Capybaras swim in the cenote. I see it.", "da", "always"]
]
