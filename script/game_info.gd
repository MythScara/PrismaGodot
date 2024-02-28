extends Node

var species_info = {
	"Human": {
	"Description": "Humans are an immigrant race forced to evacuate their home planet Earth after it was destroyed by famine, pollution, and war. They sought refuge on Prismadiane and soon became the planets most abundant work force. Humans are dedicated and hardworking, they control most of the markets on Prismadiane giving them access to the planets best gear at exceptional prices.",
	"Bonus1": {"General Discount": "- Prisma cost for [b]General Vendor[/b] purchases is decreased by [b]10%[/b]"},
	"Bonus2": {"Summon Cooldown": "- [b]Summons[/b] cooldown reduced by [b]20%[/b]"},
	"Bonus3": {"Lucky Caches": "- Prisma gained from [b]Loot Caches[/b] increased by [b]5%[/b]"},
	"Stats": [20000, 48000, 9600, 8000, 2800, 6000, 4000, 2800, 4000, 4000, 2800, 6000]},
	"Meka": {
	"Description": "The Meka are cybernetic machines created by the Celestials who once ruled over planet Prismadiane. Their sole purpose was to aid the Celestials in battle but after being abandoned by their creators, they began to advance the weaponry in preparation for their masters’ return. The Meka are highly intelligent and are skilled craftsmen, with incredible efficiency they waste no time in the workshop or on the battlefield.",
	"Bonus1": {"Repair Discount": "- [b]Repair[/b] cost decreased by [b]20%[/b]"},
	"Bonus2": {"Forge Success": "- [b]Forge[/b] success rate increased by [b]5%[/b] and cost decreased by [b]10%[/b]"},
	"Bonus3": {"Transport Discount": "- [b]Transport[/b] cost decreased by [b]50%[/b]"},
	"Stats": [40000, 20000, 14400, 5600, 4000, 7200, 2800, 6000, 4800, 1200, 1200, 4800]},
	"Daemon": {
	"Description": "When the Demons of the underworld rose up and cast darkness upon the planet, they began to possess and absorb the civilians. As time passed, generation after generation began to develop resistance against the Demons; eventually these civilians mutated into the Demon hybrid known as Daemons. Daemons are persistent and resilient, never allowing themselves to be broken down. Their strengthened immune systems allow them to run headfirst into battle with overwhelming confidence.",
	"Bonus1": {"Corpse Siphon": "- [b]Magic Power[/b] gained from defeated enemies increased by [b]10%[/b]"},
	"Bonus2": {"Magic Library": "- [b]Magic Scrolls[/b] offer [b]1[/b] additional choice"},
	"Bonus3": {"Magical Summon": "- [b]Summons[/b] gain [b]20% MGA[/b] and [b]10% MGD[/b] while on the field"},
	"Stats": [28000, 72000, 2400, 9600, 7200, 4000, 6000, 2800, 2000, 1200, 4800, 4000]},
	"Sylph": {
	"Description": "Sylphs are distant descendants of the Celestials, and the true natives of Prismadiane. Natural power rushes through their veins and the purest magic flows in their blood. The Sylphs are known for their close bond to the planet and their flawless control over their summons. Although their power is far weaker than their ancestors’, once awakened the Sylphs can effortlessly vanquish foes with extraordinary prowess.",
	"Bonus1": {"Summon Discount": "- [b]Summons[/b] require [b]50%[/b] less [b]Summon Tokens[/b]"},
	"Bonus2": {"Healthy Summon": "- [b]Summons[/b] gain [b]20% HP[/b] and [b]10% MP[/b] while on the field"},
	"Bonus3": {"Planet Siphon": "- [b]Magic Power[/b] gained from planetary resources increased by [b]10%[/b]"},
	"Stats": [60000, 40000, 1200, 2800, 1200, 2000, 4800, 6000, 6000, 7200, 4000, 2800]},
	"Kaiju": {
	"Description": "The Kaiju are primal creatures who have evolved to the degree where they can no longer be considered simply animals. With heightened senses, Kaiju rely heavily on their instincts and are extremely prideful. The Kaiju are the planet’s most resourceful scavengers with an unmatched knowledge of their surroundings.",
	"Bonus1": {"Higher Bounties": "- Prisma reward from [b]Bounties[/b] increased by [b]20%[/b]"},
	"Bonus2": {"Lucky Corpses": "- Prisma reward from defeating enemies increased by [b]5%[/b]"},
	"Bonus3": {"Powerful Summon": "- [b]Summons[/b] gain [b]20% ATK[/b] and [b]20% DEF[/b] while on the field"},
	"Stats": [48000, 20000, 8000, 12000, 4800, 1200, 1200, 4000, 2800, 7200, 7200, 2800]}
}

var element_info = {
	"SLR": {
	"Description": "Resistance value against [color='#FF0000']Solar[/color] Attacks, Pressure value using [color='#FF0000']Solar[/color] Attacks",
	"Strength": "[color='#00FF00']Nature[/color]",
	"Weakness": "[color='#00FFFF']Frost[/color]",
	"Reactions": {
		"[color='#FF0000']Burn[/color]" : "Deal [b]1% [/b]of user [b]ATK[/b] as [b]True Damage[/b] to target every second for [b]5/6/7/8/9[/b] seconds",
		"[color='#00FF00']Scorch[/color]": "Deplete [b]2% [/b]of target [b]Overshield[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#FFFF00']Blaze[/color]": "Target cannot receive any type of [b]Healing[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#AD00FF']Combust[/color]": "Prevent [b]Shield Recovery[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#0000FF']Spark[/color]" : "Target cannot receive any type of [b]Buff[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FFFF']Exhaust[/color]": "Prevent [b]Stamina Recovery[/b] for [b]10/15/20/25/30 [/b]seconds",
		"[color='#FF9600']Melt[/color]" : "Reduce target [b]DEF[/b] by [b]20% [/b]for [b]20/25/30/35/40 [/b]seconds",
		"[color='#C8C8C8']Overheat[/color]": "Deal [b]2%[/b] of [b]SLR[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"NTR": {
	"Description": "Resistance value against [color='#00FF00']Nature[/color] Attacks, Pressure value using [color='#00FF00']Nature[/color] Attacks",
	"Strength": "[color='#FFFF00']Spirit[/color]",
	"Weakness": "[color='#FF0000']Solar[/color]",
	"Reactions": {
		"[color='#FF0000']Scorch[/color]" : "Deplete [b]2% [/b]of target [b]Overshield[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#00FF00']Knock[/color]": "Cancel any [b]Buff[/b] currently on target and others within [b]2/3/4/5/6 [/b]meters",
		"[color='#FFFF00']Siphon[/color]": "User regains [b]2%[/b] of all damage dealt to target as [b]HP[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#AD00FF']Poison[/color]": "Deal [b]1% [/b]of user [b]MGA[/b] as [b]True Damage[/b] to target every second for [b]5/6/7/8/9 [/b]seconds",
		"[color='#0000FF']Thunder[/color]" : "Cancel any [b]Healing[/b] currently on target and others within [b]2/3/4/5/6 [/b]meters",
		"[color='#00FFFF']Chill[/color]": "Increase target’s [b]Stamina[/b] usage by [b]20% [/b]for [b]10/12/14/16/18[/b] seconds",
		"[color='#FF9600']Corrode[/color]" : "Increase [b]Magic Damage[/b] taken by target by [b]15% [/b]for [b]30/35/40/45/50 [/b]seconds",
		"[color='#C8C8C8']Overgrow[/color]": "Deal [b]2%[/b] of [b]NTR[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"SPR": {
	"Description": "Resistance value against [color='#FFFF00']Spirit[/color] Attacks, Pressure value using [color='#FFFF00']Spirit[/color] Attacks",
	"Strength": "[color='#AD00FF']Void[/color]",
	"Weakness": "[color='#00FF00']Nature[/color]",
	"Reactions": {
		"[color='#FF0000']Blaze[/color]" : "Target cannot receive any type of [b]Healing[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FF00']Siphon[/color]": "User regains [b]2%[/b] of all damage dealt to target as [b]HP[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#FFFF00']Blind[/color]": "Block target vision for [b]5/6/7/8/9[/b] seconds",
		"[color='#AD00FF']Curse[/color]": "Reduce target [b]ATK [/b]by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#0000FF']Radiate[/color]" : "Increase [b]Weakpoint[/b] damage on target by [b]10/15/20/25/30 %[/b] for [b]15 [/b]seconds",
		"[color='#00FFFF']Suppress[/color]": "Reduce target [b]MGA[/b] by [b]20%[/b] for the next [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']Reflect[/color]" : "Any [b]Magic[/b] used by target is reflected back at target for [b]10/15/20/25/30 [/b]seconds",
		"[color='#C8C8C8']Overload[/color]": "Deal [b]2%[/b] of [b]SPR[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"VOD": {
	"Description": "Resistance value against [color='#AD00FF']Void[/color] Attacks, Pressure value using [color='#AD00FF']Void[/color] Attacks",
	"Strength": "[color='#0000FF']Arc[/color]",
	"Weakness": "[color='#FFFF00']Spirit[/color]",
	"Reactions": {
		"[color='#FF0000']Combust[/color]" : "Prevent [b]Shield Recovery[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#00FF00']Poison[/color]": "Deal [b]1% [/b]of user [b]MGA[/b] as [b]True Damage[/b] to target every second for [b]5/6/7/8/9 [/b]seconds",
		"[color='#FFFF00']Curse[/color]": "Reduce target [b]ATK [/b]by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#AD00FF']Blight[/color]": "Next single target [b]Magic[/b] cast on target is spread to others within [b]3/4/5/6/7 [/b]meters",
		"[color='#0000FF']Null[/color]" : "Cancel any [b]Magic[/b] currently being conjured by target or others within [b]2/3/4/5/6 [/b]meters",
		"[color='#00FFFF']Petrify[/color]": "Prevent target from attacking for [b]2/3/4/5/6[/b] seconds",
		"[color='#FF9600']Decay[/color]" : "Deplete [b]2% [/b]of target [b]Magic Power[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#C8C8C8']Overweigh[/color]": "Deal [b]2%[/b] of [b]VOD[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"ARC": {
	"Description": "Resistance value against [color='#0000FF']Arc[/color] Attacks, Pressure value using [color='#0000FF']Arc[/color] Attacks",
	"Strength": "[color='#00FFFF']Frost[/color]",
	"Weakness": "[color='#AD00FF']Void[/color]",
	"Reactions": {
		"[color='#FF0000']Spark[/color]" : "Target cannot receive any type of [b]Buff[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FF00']Thunder[/color]": "Cancel any [b]Healing[/b] currently on target and others within [b]2/3/4/5/6 [/b]meters",
		"[color='#FFFF00']Radiate[/color]": "Increase [b]Weakpoint[/b] damage on target by [b]10/15/20/25/30 %[/b] for [b]15 [/b]seconds",
		"[color='#AD00FF']Null[/color]": "Cancel any [b]Magic[/b] currently being conjured by target or others within [b]2/3/4/5/6 [/b]meters",
		"[color='#0000FF']Paralyze[/color]" : "Prevent target from moving or swapping weapons for [b]2/3/4/5/6[/b] seconds",
		"[color='#00FFFF']Ionize[/color]": "User regains [b]2% [/b]of all damage dealt to target as [b]MP [/b]for [b]10/12/14/16/18 [/b]seconds",
		"[color='#FF9600']Silence[/color]" : "Prevent target from using any [b]Magic[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#C8C8C8']Overcharge[/color]": "Deal [b]2%[/b] of [b]ARC[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"FST": {
	"Description": "Resistance value against [color='#00FFFF']Frost[/color] Attacks, Pressure value using [color='#00FFFF']Frost[/color] Attacks",
	"Strength": "[color='#FF0000']Solar[/color]",
	"Weakness": "[color='#0000FF']Arc[/color]",
	"Reactions": {
		"[color='#FF0000']Exhaust[/color]" : "Prevent [b]Stamina Recovery[/b] for [b]10/15/20/25/30 [/b]seconds",
		"[color='#00FF00']Chill[/color]": "Increase target’s [b]Stamina[/b] usage by [b]20% [/b]for [b]10/12/14/16/18[/b] seconds",
		"[color='#FFFF00']Suppress[/color]": "Reduce target [b]MGA[/b] by [b]20%[/b] for the next [b]20/25/30/35/40[/b] seconds",
		"[color='#800080']Petrify[/color]": "Prevent target from attacking for [b]2/3/4/5/6[/b] seconds",
		"[color='#AD00FF']Ionize[/color]" : "User regains [b]2% [/b]of all damage dealt to target as [b]MP [/b]for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FFFF']Freeze[/color]": "Reduce target [b]AG[/b] by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']Shatter[/color]" : "Reduce target [b]MGD[/b] by [b]20% [/b]for [b]20/25/30/35/40[/b] seconds",
		"[color='#C8C8C8']Overflow[/color]": "Deal [b]2%[/b] of [b]FST[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"MTL": {
	"Description": "Resistance value against [color='#FF9600']Metal[/color] Attacks, Pressure value using [color='#FF9600']Metal[/color] Attacks",
	"Strength": "[color='#C8C8C8']Divine[/color]",
	"Weakness": "[color='#C8C8C8']Divine[/color]",
	"Reactions": {
		"[color='#FF0000']Melt[/color]" : "Reduce target [b]DEF[/b] by [b]20% [/b]for [b]20/25/30/35/40 [/b]seconds",
		"[color='#00FF00']Corrode[/color]": "Increase [b]Magic Damage[/b] taken by target by [b]15% [/b]for [b]30/35/40/45/50 [/b]seconds",
		"[color='#FFFF00']Reflect[/color]": "Any [b]Magic[/b] used by target is reflected back at target for [b]10/15/20/25/30 [/b]seconds",
		"[color='#AD00FF']Decay[/color]": "Deplete [b]2% [/b]of target [b]Magic Power[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#0000FF']Silence[/color]" : "Prevent target from using any [b]Magic[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FFFF']Shatter[/color]": "Reduce target [b]MGD[/b] by [b]20% [/b]for [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']Bleed[/color]" : "Increase [b]Physical Damage[/b] taken by target by [b]15%[/b] for [b]30/35/40/45/50 [/b]seconds",
		"[color='#C8C8C8']Overpower[/color]": "Deal [b]2%[/b] of [b]MTL[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"DVN": {
	"Description": "Resistance value against [color='#C8C8C8']Divine[/color] Attacks, Pressure value using [color='#C8C8C8']Divine[/color] Attacks",
	"Strength": "[color='#FF9600']Metal[/color]",
	"Weakness": "[color='#FF9600']Metal[/color]",
	"Reactions": {
		"[color='#FF0000']Overheat[/color]" : "Deal [b]2%[/b] of [b]SLR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FF00']Overgrow[/color]": "Deal [b]2%[/b] of [b]NTR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#FFFF00']Overload[/color]": "Deal [b]2%[/b] of [b]SPR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#AD00FF']Overweigh[/color]": "Deal [b]2%[/b] of [b]VOD[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#0000FF']Overcharge[/color]" : "Deal [b]2%[/b] of [b]ARC[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FFFF']Overflow[/color]": "Deal [b]2%[/b] of [b]FST[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#FF9600']Overpower[/color]" : "Deal [b]2%[/b] of [b]MTL[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#C8C8C8']Overwhelm[/color]": "Deal [b]2%[/b] of [b]DVN[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
}

