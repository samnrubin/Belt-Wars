#define CLIENT_ONLY

const SColor M_COLOR = SColor(0, 51, 116, 51);
int location = 0;
bool tutorialShow = true;
u32 lastMessageTime = 0;
		
string[] chats = {"Coming soon: AI Controlled Space Stations",
				 "Coming soon: New Sprites",
				 "Coming soon: Lazer Guns Pew Pew",
				 "Coming soon: Fuel Tank w/ Afterburner",
				 "Coming later: Pilotable Space Ships",
				 "Coming soon: New Backgrounds",
				 "Coming soon: New Futuristic Theme",
				 "Coming soon: Uranium",
				 "Coming soon: Gravity Generators",
				 "Think you can take on STORM in a clan war? Message Nand or Fiend",
				 "Props to Aphelion's RP for showing just how much this game can be modified",
				 //"Can you do sprite art? Shoot me a message on the forums",
				 //"Don't forget to post in the forum thread if you like the mod!",
				 //"Suggestions? Post them in the HOTR Kag2d.com forum thread",
				 "Found a bug? Please message me(Nand) on the forums",
				 "Frozen with a red circle? IT'S MY FAULT, help me fix the bug by sending me(Nand) your latest console log",
				 "This mod was created and designed by Nand",
				 "This mod was created and designed by Nand",
				 "This is a PROTOTYPE created in approximately one day. Expect bugs"
				 };

int lastPick = 0;



void onTick(CRules@ this){
	if(lastMessageTime == 0){
		lastMessageTime = getGameTime();
		client_AddToChat("Welcome to Belter Rebellion!", M_COLOR);
		client_AddToChat("A asteroid belt mod prototype designed and developed by Nand", M_COLOR);
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
