#define CLIENT_ONLY

const SColor M_COLOR = SColor(0, 51, 116, 51);
int location = 0;
bool tutorialShow = true;
bool changelogShow = false;
u32 lastMessageTime = 0;
		
string[] chats = {"Coming soon: AI Controlled Space Stations",
				 "Coming soon: New Sprites",
				 "Coming soon: Lazer Guns Pew Pew",
				 "Coming soon: More Pilotable Space Ships",
				 //"Coming soon: More Backgrounds",
				 "Coming soon: New Futuristic Theme",
				 "Coming soon: More Gravity Generators",
				 "The Saw generates a vertical gravity field for pulling in logs or enemies!",
				 "The Saw generates a vertical gravity field for pulling in logs or enemies!",
				 "Props to Aphelion's RP for showing just how much this game can be modified",
				 //"Can you do sprite art? Shoot me a message on the forums",
				 //"Don't forget to post in the forum thread if you like the mod!",
				 //"Suggestions? Post them in the HOTR Kag2d.com forum thread",
				 "Found a bug? Please message me (Nand) on the forums",
				 "Frozen with a red circle? IT'S MY FAULT, help me fix the bug by sending me (Nand) your latest console log",
				 "Frozen with a red circle? IT'S MY FAULT, help me fix the bug by sending me (Nand) your latest console log",
				 "Frozen with a red circle? IT'S MY FAULT, help me fix the bug by sending me (Nand) your latest console log",
				 "This mod was created and designed by Nand",
				 "This mod was created and designed by Nand",
				 "Press your \"taunts\" key to activate/deactivate your afterburner (Default: \'V\')",
				 "Want to design new maps? Belt Wars uses the same map palette as regular CTF, so send me the files on the forum",
				 "Want to design new maps? Belt Wars uses the same map palette as regular CTF, so send me the files on the forum",
				 "You can rebind your afterburner key in the settings, just change what key \"taunts\" is set to",
				 "Control your afterburner with the mouse!",
				 "Control your afterburner with the mouse!",
				 "Control your afterburner with the mouse!",
				 "Press P to see the intro text again",
				 "Press L to view the change log"
				 };

int lastPick = 0;

string tutorialMain = "Welcome to Belt Wars v.(0.75)\n\n" +
					  "ATTENTION: RP is allowed but this is not an RP server\n" +
					  "Attemping to kick someone for not respecting \"peace\"\n"
					  "will earn YOU a PERMABAN\n\n"
					  "Enter/exit spaceships with \'E\' or \'s\'\n\n" +
					  "Activate your afterburner with your \"taunts\" key\n" +
					  "Default is 'V', but it can be changed in settings\n" +
					  "Control your afterburner with your mouse :D\n\n" +
					  "Press L to view the change log\n\n\n" +
					  "PRESS P TO DISMISS/BRING BACK THIS DIALOG";

string changelog = "V. 0.75\n" +
				   "Flags resprited\n" + 
				   "Black Holes added\n" + 
				   "Standard gravity map generators added\n" + 
				   "Full gravity movement system w/ booster system added\n" + 
				   "New knight sprites added (based Cubone)\n" +
				   "Bomb radius increased and explosion reworked\n" +
				   "Four new maps added, including the first\nuser submitted map! Thanks voper45!\n" +
				   "\nV. 0.65\n" +
				   "Afterburners totally reworked, now mouse controlled\n" +
				   "Wasp rebalances:Increased health, damage, explosion\n" +
				   "tile damage\n" +
				   "Ship building seperated into Uranium Refinery and\n" +
				   "Fleet Beacon. Refinery is cheaper but requires uranium\n" +
				   "Misc. Resprites and bugfixes.\n"
				   "\nV. 0.61\n" +
				   "Misc. Wasp fixes and changes\nFall damage reduced\nBugfix: RED CIRCLE THROWING BUG FIXED HURRAY\n"
				   "\nV. 0.6\n" +
				   "Wasp spacecraft added\n" +
				   "Afterburners reworked, should be much more fun\n" +
				   "Uranium resource added w/ custom mining sound\n" +
				   "Iron/Aluminum/Bedrock blocks/tiles resprited\n" +
				   "Motherload and Defensive Line maps added\n"
				   "Removed support restrictions for blocks and doors,\n" +
				   "building large structures should be much easier now\n" +
				   "\nV. 0.55\n" +
				   "Bugfix: Glitching out of map\n" +
				   "Bugfix: Gravity added to drill/trampoline\n" +
				   "Added randomly picked backgrounds\n\n\n" +
				   "PRESS L TO DISMISS/BRING BACK THIS DIALOG";



void onTick(CRules@ this){
	if (getControls().isKeyJustPressed(KEY_KEY_P)){
		changelogShow = false;
		if(tutorialShow){
			tutorialShow = false;
		}
		else{
			tutorialShow = true;
		}
	}

	if (getControls().isKeyJustPressed(KEY_KEY_L)){
		tutorialShow = false;

		if(changelogShow){
			changelogShow = false;
		}
		else{
			changelogShow = true;
		}
	}

	if(lastMessageTime == 0){
		lastMessageTime = getGameTime();
		client_AddToChat("Welcome to Belt Wars! v.(0.75)", M_COLOR);
		client_AddToChat("Design and coding by Nand, spriting by Nand/Cubone", M_COLOR);
	}

	if(getGameTime() - lastMessageTime > 180 * getTicksASecond()){
		u8 newpick = XORRandom(chats.length);
		while(chats[newpick] == chats[lastPick]){
			newpick = XORRandom(chats.length);
		}
		client_AddToChat(chats[newpick], M_COLOR);
		lastMessageTime = getGameTime();
		lastPick = newpick;
	}
}

void onRender(CRules@ this){
	if(tutorialShow || changelogShow){
		string displayText;
		if(tutorialShow){
			displayText = tutorialMain;
		}
		else if(changelogShow){
			displayText = changelog;
		}

		Vec2f size;
		GUI::GetTextDimensions(displayText, size);
		Vec2f ul = Vec2f((getScreenWidth() - size.x) / 2, (getScreenHeight() - size.y) / 2);
		GUI::DrawFramedPane(ul - Vec2f(8, 8), ul+size + Vec2f(8,-20));
		GUI::DrawText(displayText, ul, color_white);
	}
}
