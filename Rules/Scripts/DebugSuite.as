void p(string title, Vec2f toPrint){
	string x = formatFloat(toPrint.x, "", 0, 2);
	string y = formatFloat(toPrint.y, "", 0, 2);

	print("x:" + x + " y:" + y);
}

void c(string title, Vec2f toPrint){
	string x = formatFloat(toPrint.x, "", 0, 2);
	string y = formatFloat(toPrint.y, "", 0, 2);

	client_AddToChat(title + " = " + "x:" + x + " y:" + y);
}

void p(string title, int toPrint){
	string num = formatInt(toPrint, "");

	print(title + ": " + num);
}

void p(CBlob@ blob){
	print(blob.getName());
}

