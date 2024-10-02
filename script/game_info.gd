extends Node

var species_info = {
	"Human": {
	"Description": "Humans are an immigrant race forced to evacuate their home planet Earth after it was destroyed by famine, pollution, and war. They sought refuge on Prismadiane and soon became the planets most abundant work force. Humans are dedicated and hardworking, they control most of the markets on Prismadiane giving them access to the planets best gear at exceptional prices.",
	"Bonus1": {"General Discount": "Prisma cost for [b]GENERAL VENDOR[/b] purchases are decreased by [b]10%[/b]"},
	"Bonus2": {"Summon Cooldown": "[b]SUMMON[/b] cooldown reduced by [b]20%[/b]"},
	"Bonus3": {"Lucky Caches": "Prisma gained from [b]LOOT CACHE[/b] increased by [b]5%[/b]"},
	"Stats": [20000, 48000, 9600, 8000, 2800, 6000, 4000, 2800, 4000, 4000, 2800, 6000]},
	"Meka": {
	"Description": "The Meka are cybernetic machines created by the Celestials who once ruled over planet Prismadiane. Their sole purpose was to aid the Celestials in battle but after being abandoned by their creators, they began to advance the weaponry in preparation for their masters’ return. The Meka are highly intelligent and are skilled craftsmen, with incredible efficiency they waste no time in the workshop or on the battlefield.",
	"Bonus1": {"Repair Discount": "[b]REPAIR[/b] cost decreased by [b]20%[/b]"},
	"Bonus2": {"Forge Success": "[b]FORGE[/b] success rate increased by [b]5%[/b] and cost decreased by [b]10%[/b]"},
	"Bonus3": {"Transport Discount": "[b]TRANSPORT[/b] cost decreased by [b]50%[/b]"},
	"Stats": [40000, 20000, 14400, 5600, 4000, 7200, 2800, 6000, 4800, 1200, 1200, 4800]},
	"Daemon": {
	"Description": "When the Demons of the underworld rose up and cast darkness upon the planet, they began to possess and absorb the civilians. As time passed, generation after generation began to develop resistance against the Demons; eventually these civilians mutated into the Demon hybrid known as Daemons. Daemons are persistent and resilient, never allowing themselves to be broken down. Their strengthened immune systems allow them to run headfirst into battle with overwhelming confidence.",
	"Bonus1": {"Corpse Siphon": "[b]MAGIC POWER[/b] gained from defeated enemies increased by [b]10%[/b]"},
	"Bonus2": {"Magic Library": "[b]MAGIC SCROLL[/b] offers [b]1[/b] additional choice"},
	"Bonus3": {"Magical Summon": "[b]SUMMON[/b] gains [b]20% MGA[/b] and [b]10% MGD[/b] while on the field"},
	"Stats": [28000, 72000, 2400, 9600, 7200, 4000, 6000, 2800, 2000, 1200, 4800, 4000]},
	"Sylph": {
	"Description": "Sylphs are distant descendants of the Celestials, and the true natives of Prismadiane. Natural power rushes through their veins and the purest magic flows in their blood. The Sylphs are known for their close bond to the planet and their flawless control over their summons. Although their power is far weaker than their ancestors’, once awakened the Sylphs can effortlessly vanquish foes with extraordinary prowess.",
	"Bonus1": {"Summon Discount": "[b]SUMMON[/b] requires [b]50%[/b] less [b]SUMMON TOKENS[/b]"},
	"Bonus2": {"Healthy Summon": "[b]SUMMON[/b] gains [b]20% HP[/b] and [b]10% MP[/b] while on the field"},
	"Bonus3": {"Planet Siphon": "[b]MAGIC POWER[/b] gained from planetary resources increased by [b]10%[/b]"},
	"Stats": [60000, 40000, 1200, 2800, 1200, 2000, 4800, 6000, 6000, 7200, 4000, 2800]},
	"Kaiju": {
	"Description": "The Kaiju are primal creatures who have evolved to the degree where they can no longer be considered simply animals. With heightened senses, Kaiju rely heavily on their instincts and are extremely prideful. The Kaiju are the planet’s most resourceful scavengers with an unmatched knowledge of their surroundings.",
	"Bonus1": {"Higher Bounties": "Prisma reward from [b]BOUNTY[/b] increased by [b]20%[/b]"},
	"Bonus2": {"Lucky Corpses": "Prisma reward from defeating enemies increased by [b]5%[/b]"},
	"Bonus3": {"Powerful Summon": "[b]SUMMON[/b] gains [b]20% ATK[/b] and [b]20% DEF[/b] while on the field"},
	"Stats": [48000, 20000, 8000, 12000, 4800, 1200, 1200, 4000, 2800, 7200, 7200, 2800]}
}

var element_info = {
	"SLR": {
	"Description": "Resistance value against [color='#FF0000']SOLAR[/color] Attacks, Pressure value using [color='#FF0000']SOLAR[/color] Attacks",
	"Strength": "[color='#00FF00']NATURE[/color]",
	"Weakness": "[color='#00FFFF']FROST[/color]",
	"Reactions": {
		"[color='#FF0000']BURN[/color]" : "Take [b]2000 ELEMENTAL DAMAGE[/b] of type [b]SOLAR[/b] per second for [b]2/4/6/8/10[/b] seconds",
		"[color='#00FF00']ECLIPSE[/color]": "Target cannot [b]SUMMON[/b] or activate [b]SUMMON ABILITY[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#FFFF00']SCORCH[/color]": "Target takes [b]10%[/b] more [b]PHYSICAL DAMAGE[/b] for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#AD00FF']SIPHON[/color]": "Target cannot receive or cast any [b]HEALING[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#0000FF']BLAZE[/color]" : "Target takes [b]10%[/b] more [b]MAGIC DAMAGE[/b] for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#00FFFF']VAPORIZE[/color]": "Target cannot receive or cast any [b]BUFF[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#FF9600']MELT[/color]" : "Reduces targets [b]SLR[/b] by [b]20%[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#C8C8C8']COMBUST[/color]": "Reduces targets [b]ATK[/b] by [b]20%[/b] for [b]10/15/20/25/30[/b] seconds"
		}
	},
	"NTR": {
	"Description": "Resistance value against [color='#00FF00']NATURE[/color] Attacks, Pressure value using [color='#00FF00']NATURE[/color] Attacks",
	"Strength": "[color='#FFFF00']SPIRIT[/color]",
	"Weakness": "[color='#FF0000']SOLAR[/color]",
	"Reactions": {
		"[color='#FF0000']ECLIPSE[/color]" : "Target cannot [b]SUMMON[/b] or activate [b]SUMMON ABILITY[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#00FF00']THORN[/color]": "Take [b]2000 ELEMENTAL DAMAGE[/b] of type [b]NATURE[/b] per second for [b]2/4/6/8/10[/b] seconds",
		"[color='#FFFF00']KNOCK[/color]": "Prevents [b]EQUIPMENT[/b] and [b]TECHNIQUE[/b] use for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#AD00FF']PETRIFY[/color]": "Target cannot [b]CAST[/b] for [b]3/3.5/4/4.5/5[/b] seconds",
		"[color='#0000FF']SILENCE[/color]" : "Targets [b]HEARING[/b] is [b]IMPAIRED[/b] for [b]3/3.5/4/4.5/5[/b] seconds",
		"[color='#00FFFF']NUMB[/color]": "Target cannot [b]ATTACK[/b] for [b]3/3.5/4/4.5/5[/b] seconds",
		"[color='#FF9600']CORRODE[/color]" : "Reduces targets [b]NTR[/b] by [b]20%[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#C8C8C8']THUNDER[/color]": "Reduces targets [b]DEF[/b] by [b]20%[/b] for [b]10/15/20/25/30[/b] seconds"
		}
	},
	"SPR": {
	"Description": "Resistance value against [color='#FFFF00']SPIRIT[/color] Attacks, Pressure value using [color='#FFFF00']SPIRIT[/color] Attacks",
	"Strength": "[color='#AD00FF']VOID[/color]",
	"Weakness": "[color='#00FF00']NATURE[/color]",
	"Reactions": {
		"[color='#FF0000']SCORCH[/color]" : "Target takes [b]10%[/b] more [b]PHYSICAL DAMAGE[/b] for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#00FF00']KNOCK[/color]": "Prevents [b]EQUIPMENT[/b] and [b]TECHNIQUE[/b] use for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#FFFF00']RADIATE[/color]": "Take [b]2000 ELEMENTAL DAMAGE[/b] of type [b]SPIRIT[/b] per second for [b]2/4/6/8/10[/b] seconds",
		"[color='#AD00FF']STUN[/color]": "Prevents [b]CRITICAL HITS[/b] for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#0000FF']SPARK[/color]" : "Target takes [b]10%[/b] more [b]ELEMENTAL DAMAGE[/b] for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#00FFFF']EXHAUST[/color]": "Prevents [b]STAMINA RECOVERY[/b] for [b]5/7.5/10/12.5/15[/b] seconds",
		"[color='#FF9600']SUPPRESS[/color]" : "Reduces targets [b]SPR[/b] by [b]20%[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#C8C8C8']INTIMIDATE[/color]": "Reduces targets [b]MGA[/b] by [b]20%[/b] for [b]10/15/20/25/30[/b] seconds"
		}
	},
	"VOD": {
	"Description": "Resistance value against [color='#AD00FF']VOID[/color] Attacks, Pressure value using [color='#AD00FF']VOID[/color] Attacks",
	"Strength": "[color='#0000FF']ARC[/color]",
	"Weakness": "[color='#FFFF00']SPIRIT[/color]",
	"Reactions": {
		"[color='#FF0000']SIPHON[/color]" : "Prevent [b]Shield Recovery[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#00FF00']PETRFIY[/color]": "Deal [b]1% [/b]of user [b]MGA[/b] as [b]True Damage[/b] to target every second for [b]5/6/7/8/9 [/b]seconds",
		"[color='#FFFF00']STUN[/color]": "Reduce target [b]ATK [/b]by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#AD00FF']BLIGHT[/color]": "Next single target [b]Magic[/b] cast on target is spread to others within [b]2/3/4/5/6 [/b]meters",
		"[color='#0000FF']BLIND[/color]" : "Cancel any [b]Magic[/b] currently being conjured by target or others within [b]2/3/4/5/6 [/b]meters",
		"[color='#00FFFF']FREEZE[/color]": "Prevent target from attacking for [b]2/3/4/5/6[/b] seconds",
		"[color='#FF9600']DECAY[/color]" : "Deplete [b]2% [/b]of target [b]Magic Power[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#C8C8C8']CURSE[/color]": "Deal [b]2%[/b] of [b]VOD[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"ARC": {
	"Description": "Resistance value against [color='#0000FF']ARC[/color] Attacks, Pressure value using [color='#0000FF']ARC[/color] Attacks",
	"Strength": "[color='#00FFFF']FROST[/color]",
	"Weakness": "[color='#AD00FF']VOID[/color]",
	"Reactions": {
		"[color='#FF0000']BLAZE[/color]" : "Target cannot receive any type of [b]Buff[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FF00']SILENCE[/color]": "Cancel any [b]Healing[/b] currently on target and others within [b]2/3/4/5/6 [/b]meters",
		"[color='#FFFF00']SPARK[/color]": "Increase [b]Weakpoint[/b] damage on target by [b]10/15/20/25/30 %[/b] for [b]15 [/b]seconds",
		"[color='#AD00FF']BLIND[/color]": "Cancel any [b]Magic[/b] currently being conjured by target or others within [b]2/3/4/5/6 [/b]meters",
		"[color='#0000FF']SHOCK[/color]" : "Prevent target from moving or swapping weapons for [b]2/3/4/5/6[/b] seconds",
		"[color='#00FFFF']DAZE[/color]": "User regains [b]2% [/b]of all damage dealt to target as [b]MP [/b]for [b]10/12/14/16/18 [/b]seconds",
		"[color='#FF9600']DISCHARGE[/color]" : "Prevent target from using any [b]Magic[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#C8C8C8']PARALYZE[/color]": "Deal [b]2%[/b] of [b]ARC[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"FST": {
	"Description": "Resistance value against [color='#00FFFF']FROST[/color] Attacks, Pressure value using [color='#00FFFF']FROST[/color] Attacks",
	"Strength": "[color='#FF0000']SOLAR[/color]",
	"Weakness": "[color='#0000FF']ARC[/color]",
	"Reactions": {
		"[color='#FF0000']VAPORIZE[/color]" : "Prevent [b]Stamina Recovery[/b] for [b]10/15/20/25/30 [/b]seconds",
		"[color='#00FF00']NUMB[/color]": "Increase target’s [b]Stamina[/b] usage by [b]20% [/b]for [b]10/12/14/16/18[/b] seconds",
		"[color='#FFFF00']EXHAUST[/color]": "Reduce target [b]MGA[/b] by [b]20%[/b] for the next [b]20/25/30/35/40[/b] seconds",
		"[color='#AD00FF']FREEZE[/color]": "Prevent target from attacking for [b]2/3/4/5/6[/b] seconds",
		"[color='#0000FF']DAZE[/color]" : "User regains [b]2% [/b]of all damage dealt to target as [b]MP [/b]for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FFFF']CHILL[/color]": "Reduce target [b]AG[/b] by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']RRUSTust[/color]" : "Reduce target [b]MGD[/b] by [b]20% [/b]for [b]20/25/30/35/40[/b] seconds",
		"[color='#C8C8C8']SHATTER[/color]": "Deal [b]2%[/b] of [b]FST[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"MTL": {
	"Description": "Resistance value against [color='#FF9600']METAL[/color] Attacks, Pressure value using [color='#FF9600']METAL[/color] Attacks",
	"Strength": "[color='#C8C8C8']DIVINE[/color]",
	"Weakness": "[color='#C8C8C8']DIVINE[/color]",
	"Reactions": {
		"[color='#FF0000']MELT[/color]" : "Reduce target [b]DEF[/b] by [b]20% [/b]for [b]20/25/30/35/40 [/b]seconds",
		"[color='#00FF00']CORRODE[/color]": "Increase [b]Magic Damage[/b] taken by target by [b]15% [/b]for [b]30/35/40/45/50 [/b]seconds",
		"[color='#FFFF00']SUPPRESS[/color]": "Any [b]Magic[/b] used by target is reflected back at target for [b]10/15/20/25/30 [/b]seconds",
		"[color='#AD00FF']DECAY[/color]": "Deplete [b]2% [/b]of target [b]Magic Power[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#0000FF']DISCHARGE[/color]" : "Prevent target from using any [b]Magic[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FFFF']RUST[/color]": "Reduce target [b]MGD[/b] by [b]20% [/b]for [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']BLEED[/color]" : "Increase [b]Physical Damage[/b] taken by target by [b]15%[/b] for [b]30/35/40/45/50 [/b]seconds",
		"[color='#C8C8C8']DISABLE[/color]": "Deal [b]2%[/b] of [b]MTL[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"DVN": {
	"Description": "Resistance value against [color='#C8C8C8']DIVINE[/color] Attacks, Pressure value using [color='#C8C8C8']DIVINE[/color] Attacks",
	"Strength": "[color='#FF9600']METAL[/color]",
	"Weakness": "[color='#FF9600']METAL[/color]",
	"Reactions": {
		"[color='#FF0000']COMBUST[/color]" : "Deal [b]2%[/b] of [b]SLR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FF00']THUNDER[/color]": "Deal [b]2%[/b] of [b]NTR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#FFFF00']INTIMIDATE[/color]": "Deal [b]2%[/b] of [b]SPR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#AD00FF']PARALYZE[/color]" : "Deal [b]2%[/b] of [b]ARC[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FFFF']SHATTER[/color]": "Deal [b]2%[/b] of [b]FST[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#FF9600']DISABLE[/color]" : "Deal [b]2%[/b] of [b]MTL[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#C8C8C8']PURIFY[/color]": "Deal [b]2%[/b] of [b]DVN[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
}

var ranged_info = {
	"Assault Rifle": {"DMG": 1.50, "RNG": 45.00, "MOB": 0.90, "HND": 0.90, "AC": 45.00, "RLD": 1.25, "FR": 120.00, "MAG": 10.00, "DUR": 10.00, "WCP": 100.00,
	"CRR": 10.00, "CRD": 1.50, "INF": 1.00, "SLS": 10.00, "PRC": 10.00, "FRC": 1.00},
	
	"Sub Machine Gun": {"DMG": 1.00, "RNG": 25.00, "MOB": 0.95, "HND": 0.95, "AC": 25.00, "RLD": 1.00, "FR": 180.00, "MAG": 12.00, "DUR": 12.00, "WCP": 75.00,
	"CRR": 12.00, "CRD": 1.00, "INF": 1.00, "SLS": 12.00, "PRC": 12.00, "FRC": 1.00},
	
	"Light Machine Gun": {"DMG": 1.20, "RNG": 40.00, "MOB": 0.70, "HND": 0.70, "AC": 40.00, "RLD": 3.00, "FR": 150.00, "MAG": 30.00, "DUR": 30.00, "WCP": 200.00,
	"CRR": 30.00, "CRD": 1.20, "INF": 1.00, "SLS": 30.00, "PRC": 30.00, "FRC": 1.00},
	
	"Marksman Rifle": {"DMG": 2.00, "RNG": 60.00, "MOB": 0.90, "HND": 0.90, "AC": 60.00, "RLD": 1.50, "FR": 90.00, "MAG": 9.00, "DUR": 9.00, "WCP": 100.00,
	"CRR": 9.00, "CRD": 2.00, "INF": 1.00, "SLS": 9.00, "PRC": 9.00, "FRC": 1.00},
	
	"Sniper Rifle": {"DMG": 15.00, "RNG": 100.00, "MOB": 0.80, "HND": 0.80, "AC": 100.00, "RLD": 1.50, "FR": 12.00, "MAG": 1.00, "DUR": 1.00, "WCP": 150.00,
	"CRR": 1.00, "CRD": 15.00, "INF": 1.00, "SLS": 1.00, "PRC": 1.00, "FRC": 1.00},
	
	"Shotgun": {"DMG": 6.00, "RNG": 10.00, "MOB": 0.85, "HND": 0.85, "AC": 10.0, "RLD": 2.00, "FR": 30.00, "MAG": 4.00, "DUR": 4.00, "WCP": 125.00,
	"CRR": 4.00, "CRD": 6.00, "INF": 1.00, "SLS": 4.00, "PRC": 4.00, "FRC": 1.00},
	
	"Handgun": {"DMG": 1.50, "RNG": 30.00, "MOB": 1.00, "HND": 1.00, "AC": 30.00, "RLD": 0.75, "FR": 120.00, "MAG": 6.00, "DUR": 6.00, "WCP": 50.00,
	"CRR": 6.00, "CRD": 1.50, "INF": 1.00, "SLS": 6.00, "PRC": 6.00, "FRC": 1.00},
	
	"Machine Pistol": {"DMG": 0.75, "RNG": 15.00, "MOB": 1.00, "HND": 1.00, "AC": 15.00, "RLD": 0.75, "FR": 240.00, "MAG": 12.00, "DUR": 12.00, "WCP": 50.00,
	"CRR": 12.00, "CRD": 0.75, "INF": 1.00, "SLS": 12.00, "PRC": 12.00, "FRC": 1.00},
	
	"Launcher": {"DMG": 30.00, "RNG": 100.00, "MOB": 0.60, "HND": 0.60, "AC": 100.00, "RLD": 2.50, "FR": 6.00, "MAG": 1.00, "DUR": 1.00, "WCP": 250.00,
	"CRR": 1.00, "CRD": 30.00, "INF": 1.00, "SLS": 1.00, "PRC": 1.00, "FRC": 1.00},
	
	"Crossbow": {"DMG": 3.00, "RNG": 35.00, "MOB": 0.80, "HND": 0.80, "AC": 35.00, "RLD": 2.00, "FR": 60.00, "MAG": 8.00, "DUR": 8.00, "WCP": 150.00,
	"CRR": 8.00, "CRD": 3.00, "INF": 1.00, "SLS": 8.00, "PRC": 8.00, "FRC": 1.00},
	
	"Longbow": {"DMG": 9.00, "RNG": 70.00, "MOB": 0.85, "HND": 0.85, "AC": 70.00, "RLD": 0.75, "FR": 20.00, "MAG": 1.00, "DUR": 1.00, "WCP": 125.00,
	"CRR": 1.00, "CRD": 9.00, "INF": 1.00, "SLS": 1.00, "PRC": 1.00, "FRC": 1.00}
}

var melee_info = {
	"Long Sword": {"POW": 4.80, "RCH": 1.20, "MOB": 0.85, "HND": 0.85, "BLK": 0.30, "CHG": 1.25, "ASP": 60.00, "STE": 15.00, "DUR": 15.00, "WCP": 150.00,
	"CRR": 15.00, "CRD": 4.80, "INF": 1.00, "SLS": 15.00, "PRC": 15.00, "FRC": 1.00},
	
	"Great Sword": {"POW": 7.20, "RCH": 1.50, "MOB": 0.75, "HND": 0.75, "BLK": 0.35, "CHG": 1.50, "ASP": 40.00, "STE": 12.00, "DUR": 12.00, "WCP": 225.00,
	"CRR": 12.00, "CRD": 7.20, "INF": 1.00, "SLS": 12.00, "PRC": 12.00, "FRC": 1.00},
	
	"Katana": {"POW": 3.20, "RCH": 1.00, "MOB": 0.95, "HND": 0.95, "BLK": 0.25, "CHG": 1.00, "ASP": 90.00, "STE": 18.00, "DUR": 19.00, "WCP": 100.00,
	"CRR": 18.00, "CRD": 3.20, "INF": 1.00, "SLS": 18.00, "PRC": 18.00, "FRC": 1.00},
	
	"Dagger": {"POW": 2.40, "RCH": 0.80, "MOB": 1.00, "HND": 1.00, "BLK": 0.05, "CHG": 0.75, "ASP": 120.00, "STE": 18.00, "DUR": 18.00, "WCP": 50.00,
	"CRR": 18.00, "CRD": 2.40, "INF": 1.00, "SLS": 18.00, "PRC": 18.00, "FRC": 1.00},
	
	"Staff": {"POW": 4.80, "RCH": 1.50, "MOB": 0.90, "HND": 0.90, "BLK": 0.10, "CHG": 1.00, "ASP": 60.00, "STE": 12.00, "DUR": 12.00, "WCP": 125.00,
	"CRR": 4.80, "CRD": 1.00, "INF": 12.00, "SLS": 12.00, "PRC": 12.00, "FRC": 1.00},
	
	"Mace": {"POW": 4.80, "RCH": 1.00, "MOB": 0.80, "HND": 0.80, "BLK": 0.20, "CHG": 1.25, "ASP": 60.00, "STE": 15.00, "DUR": 15.00, "WCP": 100.00,
	"CRR": 15.00, "CRD": 4.80, "INF": 1.00, "SLS": 15.00, "PRC": 15.00, "FRC": 1.00},
	
	"Halberd": {"POW": 5.75, "RCH": 1.50, "MOB": 0.75, "HND": 0.75, "BLK": 0.30, "CHG": 1.20, "ASP": 50.00, "STE": 12.00, "DUR": 12.00, "WCP": 200.00,
	"CRR": 12.00, "CRD": 5.75, "INF": 1.00, "SLS": 12.00, "PRC": 12.00, "FRC": 1.00},
	
	"Warhammer": {"POW": 9.60, "RCH": 1.20, "MOB": 0.75, "HND": 0.75, "BLK": 0.30, "CHG": 1.50, "ASP": 30.00, "STE": 9.00, "DUR": 9.00, "WCP": 200.00,
	"CRR": 9.00, "CRD": 9.60, "INF": 1.00, "SLS": 9.00, "PRC": 9.00, "FRC": 1.00},
	
	"Battle Axe": {"POW": 7.20, "RCH": 1.50, "MOB": 0.70, "HND": 0.70, "BLK": 0.35, "CHG": 1.50, "ASP": 40.00, "STE": 12.00, "DUR": 12.00, "WCP": 225.00,
	"CRR": 12.00, "CRD": 7.20, "INF": 1.00, "SLS": 12.00, "PRC": 12.00, "FRC": 1.00},
	
	"Polearm": {"POW": 3.20, "RCH": 2.00, "MOB": 0.95, "HND": 0.95, "BLK": 0.10, "CHG": 1.50, "ASP": 90.00, "STE": 27.00, "DUR": 27.00, "WCP": 75.00,
	"CRR": 27.00, "CRD": 3.20, "INF": 1.00, "SLS": 27.00, "PRC": 27.00, "FRC": 1.00},
	
	"Scythe": {"POW": 3.80, "RCH": 1.50, "MOB": 0.85, "HND": 0.85, "BLK": 0.15, "CHG": 1.20, "ASP": 75.00, "STE": 18.00, "DUR": 18.00, "WCP": 125.00,
	"CRR": 18.00, "CRD": 3.80, "INF": 1.00, "SLS": 18.00, "PRC": 18.00, "FRC": 1.00},
	
	"Gauntlet": {"POW": 2.40, "RCH": 0.80, "MOB": 1.00, "HND": 1.00, "BLK": 0.20, "CHG": 1.00, "ASP": 120.00, "STE": 24.00, "DUR": 24.00, "WCP": 50.00,
	"CRR": 24.00, "CRD": 2.40, "INF": 1.00, "SLS": 24.00, "PRC": 24.00, "FRC": 1.00},
	
	"Shield": {"POW": 14.40, "RCH": 0.50, "MOB": 0.60, "HND": 0.60, "BLK": 0.50, "CHG": 2.25, "ASP": 20.00, "STE": 9.00, "DUR": 9.00, "WCP": 250.00,
	"CRR": 9.00, "CRD": 14.40, "INF": 1.00, "SLS": 9.00, "PRC": 9.00, "FRC": 1.00},
	
	"Spear": {"POW": 3.80, "RCH": 2.00, "MOB": 0.90, "HND": 0.90, "BLK": 0.10, "CHG": 1.00, "ASP": 75.00, "STE": 15.00, "DUR": 15.00, "WCP": 75.00,
	"CRR": 15.00, "CRD": 3.80, "INF": 1.00, "SLS": 15.00, "PRC": 15.00, "FRC": 1.00}
}

var ranged_tier = {
	"Iron": {"DMG": 1.00, "RNG": 1.00, "MOB": 0.70, "HND": 0.50, "AC": 0.82, "RLD": 1.00, "FR": 1.00, "MAG": 1.00, "DUR": 3.00, "WCP": 2.00,
	"CRR": 20.50, "CRD": 1.00, "INF": 0.55, "SLS": 0.50, "PRC": 0.50, "FRC": 0.55},
	
	"Copper": {"DMG": 1.20, "RNG": 1.05, "MOB": 0.72, "HND": 0.52, "AC": 0.84, "RLD": 0.98, "FR": 1.02, "MAG": 1.05, "DUR": 4.00, "WCP": 4.00,
	"CRR": 21.00, "CRD": 1.05, "INF": 0.60, "SLS": 1.00, "PRC": 1.00, "FRC": 0.60},
	
	"Bronze": {"DMG": 1.40, "RNG": 1.10, "MOB": 0.74, "HND": 0.54, "AC": 0.86, "RLD": 0.96, "FR": 1.04, "MAG": 1.10, "DUR": 5.00, "WCP": 6.00,
	"CRR": 21.50, "CRD": 1.10, "INF": 0.65, "SLS": 1.50, "PRC": 1.50, "FRC": 0.65},
	
	"Silver": {"DMG": 1.60, "RNG": 1.15, "MOB": 0.76, "HND": 0.56, "AC": 0.88, "RLD": 0.94, "FR": 1.06, "MAG": 1.15, "DUR": 6.00, "WCP": 8.00,
	"CRR": 22.00, "CRD": 1.15, "INF": 0.70, "SLS": 2.00, "PRC": 2.00, "FRC": 0.70},
	
	"Gold": {"DMG": 1.80, "RNG": 1.20, "MOB": 0.78, "HND": 0.58, "AC": 0.90, "RLD": 0.92, "FR": 1.08, "MAG": 1.20, "DUR": 7.00, "WCP": 10.00,
	"CRR": 22.50, "CRD": 1.20, "INF": 0.75, "SLS": 2.50, "PRC": 2.50, "FRC": 0.75},
	
	"Platinum": {"DMG": 2.00, "RNG": 1.25, "MOB": 0.80, "HND": 0.60, "AC": 0.92, "RLD": 0.90, "FR": 1.10, "MAG": 1.25, "DUR": 8.00, "WCP": 12.00,
	"CRR": 23.00, "CRD": 1.25, "INF": 0.80, "SLS": 3.00, "PRC": 3.00, "FRC": 0.80},
	
	"Diamond": {"DMG": 2.25, "RNG": 1.30, "MOB": 0.82, "HND": 0.62, "AC": 0.94, "RLD": 0.88, "FR": 1.12, "MAG": 1.30, "DUR": 9.00, "WCP": 14.00,
	"CRR": 23.50, "CRD": 1.30, "INF": 0.85, "SLS": 3.50, "PRC": 3.50, "FRC": 0.85},
	
	"Obsidian": {"DMG": 2.50, "RNG": 1.40, "MOB": 0.84, "HND": 0.64, "AC": 0.96, "RLD": 0.86, "FR": 1.14, "MAG": 1.40, "DUR": 10.00, "WCP": 16.00,
	"CRR": 24.00, "CRD": 1.35, "INF": 0.90, "SLS": 4.00, "PRC": 4.00, "FRC": 0.90},
	
	"Mithril": {"DMG": 2.75, "RNG": 1.50, "MOB": 0.86, "HND": 0.66, "AC": 0.98, "RLD": 0.84, "FR": 1.16, "MAG": 1.50, "DUR": 11.00, "WCP": 18.00,
	"CRR": 24.50, "CRD": 1.40, "INF": 0.95, "SLS": 4.50, "PRC": 4.50, "FRC": 0.95},
	
	"Adamantine": {"DMG": 3.00, "RNG": 1.60, "MOB": 0.88, "HND": 0.68, "AC": 1.00, "RLD": 0.82, "FR": 1.18, "MAG": 1.60, "DUR": 12.00, "WCP": 20.00,
	"CRR": 25.00, "CRD": 1.45, "INF": 1.00, "SLS": 5.00, "PRC": 5.00, "FRC": 1.00}
}

var melee_tier = {
	"Iron": {"POW": 1.00, "RCH": 1.00, "MOB": 0.70, "HND": 0.50, "BLK": 0.82, "CHG": 1.00, "ASP": 1.00, "STE": 1.00, "DUR": 3.00, "WCP": 2.00,
	"CRR": 20.50, "CRD": 1.00, "INF": 0.55, "SLS": 0.50, "PRC": 0.50, "FRC": 0.55},
	
	"Copper": {"POW": 1.20, "RCH": 1.05, "MOB": 0.72, "HND": 0.52, "BLK": 0.84, "CHG": 0.98, "ASP": 1.02, "STE": 1.05, "DUR": 4.00, "WCP": 4.00,
	"CRR": 21.00, "CRD": 1.05, "INF": 0.60, "SLS": 1.00, "PRC": 1.00, "FRC": 0.60},
	
	"Bronze": {"POW": 1.40, "RCH": 1.10, "MOB": 0.74, "HND": 0.54, "BLK": 0.86, "CHG": 0.96, "ASP": 1.04, "STE": 1.10, "DUR": 5.00, "WCP": 6.00,
	"CRR": 21.50, "CRD": 1.10, "INF": 0.65, "SLS": 1.50, "PRC": 1.50, "FRC": 0.65},
	
	"Silver": {"POW": 1.60, "RCH": 1.15, "MOB": 0.76, "HND": 0.56, "BLK": 0.88, "CHG": 0.94, "ASP": 1.06, "STE": 1.15, "DUR": 6.00, "WCP": 8.00,
	"CRR": 22.00, "CRD": 1.15, "INF": 0.70, "SLS": 2.00, "PRC": 2.00, "FRC": 0.70},
	
	"Gold": {"POW": 1.80, "RCH": 1.20, "MOB": 0.78, "HND": 0.58, "BLK": 0.90, "CHG": 0.92, "ASP": 1.08, "STE": 1.20, "DUR": 7.00, "WCP": 10.00,
	"CRR": 22.50, "CRD": 1.20, "INF": 0.75, "SLS": 2.50, "PRC": 2.50, "FRC": 0.75},
	
	"Platinum": {"POW": 2.00, "RCH": 1.25, "MOB": 0.80, "HND": 0.60, "BLK": 0.92, "CHG": 0.90, "ASP": 1.10, "STE": 1.25, "DUR": 8.00, "WCP": 12.00,
	"CRR": 23.00, "CRD": 1.25, "INF": 0.80, "SLS": 3.00, "PRC": 3.00, "FRC": 0.80},
	
	"Diamond": {"POW": 2.25, "RCH": 1.30, "MOB": 0.82, "HND": 0.62, "BLK": 0.94, "CHG": 0.88, "ASP": 1.12, "STE": 1.30, "DUR": 9.00, "WCP": 14.00,
	"CRR": 23.50, "CRD": 1.30, "INF": 0.85, "SLS": 3.50, "PRC": 3.50, "FRC": 0.85},
	
	"Obsidian": {"POW": 2.50, "RCH": 1.40, "MOB": 0.84, "HND": 0.64, "BLK": 0.96, "CHG": 0.86, "ASP": 1.14, "STE": 1.40, "DUR": 10.00, "WCP": 16.00,
	"CRR": 24.00, "CRD": 1.35, "INF": 0.90, "SLS": 4.00, "PRC": 4.00, "FRC": 0.90},
	
	"Mithril": {"POW": 2.75, "RCH": 1.50, "MOB": 0.86, "HND": 0.66, "BLK": 0.98, "CHG": 0.84, "ASP": 1.16, "STE": 1.50, "DUR": 11.00, "WCP": 18.00,
	"CRR": 24.50, "CRD": 1.40, "INF": 0.95, "SLS": 4.50, "PRC": 4.50, "FRC": 0.95},
	
	"Adamantine": {"POW": 3.00, "RCH": 1.60, "MOB": 0.88, "HND": 0.68, "BLK": 1.00, "CHG": 0.82, "ASP": 1.18, "STE": 1.60, "DUR": 12.00, "WCP": 20.00,
	"CRR": 25.00, "CRD": 1.45, "INF": 1.00, "SLS": 5.00, "PRC": 5.00, "FRC": 1.00}
}

var specialist_list = [
	"Mercenary", "Cavalier", "Spartan", "Ranger", "Scout", "Pirate", "Assassin", "Nomad", "Engineer", "Hunter", "Archer", "Paladin",
	"Warden", "Ronin", "Ninja", "Templar", "Rogue", "Samurai", "Valkyrie", "Inquisitor", "Druid", "Monk", "Centurion", "Sage"
	]

var slot_size = {
	"Ranged Weapon": 1,
	"Melee Weapon": 1,
	"Summon": 1,
	"Outfit": 1,
	"Ring": 10,
	"Artifact": 3,
	"Soul Stone": 1,
	"Chest Armor": 1,
	"Pad Armor": 1,
	"Belt Armor": 1,
	"Body Armor": 1,
	"Battle Item": 4,
	"Support Item": 4,
	"Battle Magic": 4,
	"Support Magic": 4,
	"Techniques": 3,
	"Specialist": 1,
	"Vehicle": 1
}

func firing_type(item):
	var attack_type = ""
	match item:
		"Assault Rifle": 
			attack_type = "Fully-Automatic"
		"Sub Machine Gun": 
			attack_type = "Fully-Automatic"
		"Light Machine Gun": 
			attack_type = "Fully-Automatic"
		"Marksman Rifle":
			attack_type = "Semi-Automatic"
		"Sniper Rifle": 
			attack_type = "Bolt-Action"
		"Shotgun": 
			attack_type = "Pump-Action"
		"Handgun": 
			attack_type = "Semi-Automatic"
		"Machine Pistol": 
			attack_type = "Fully-Automatic"
		"Launcher": 
			attack_type = "Single-Shot"
		"Crossbow": 
			attack_type = "Semi-Automatic"
		"Longbow": 
			attack_type = "Bolt-Action"
		"Long Sword": 
			attack_type = "Standard Attack"
		"Great Sword": 
			attack_type = "Heavy Attack"
		"Katana": 
			attack_type = "Light Attack"
		"Dagger": 
			attack_type = "Light Attack"
		"Staff": 
			attack_type = "Standard Attack"
		"Mace": 
			attack_type = "Standard Attack"
		"Halberd": 
			attack_type = "Heavy Attack"
		"Warhammer": 
			attack_type = "Heavy Attack"
		"Battle Axe": 
			attack_type = "Heavy Attack"
		"Polearm": 
			attack_type = "Light Attack"
		"Scythe": 
			attack_type = "Standard Attack"
		"Gauntlet": 
			attack_type = "Light Attack"
		"Shield": 
			attack_type = "Heavy Attack"
		"Spear": 
			attack_type = "Light Attack"
	
	return attack_type
