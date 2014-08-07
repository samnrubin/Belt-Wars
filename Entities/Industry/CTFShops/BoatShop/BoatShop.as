﻿// Boat Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_dinghy = 25;
const s32 cost_longboat = 50;
const s32 cost_warboat = 250;
const s32 cost_wasp = 90;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(7,2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	AddIconToken( "$wasp$", "VehicleIcons.png", Vec2f(32,32), 6 );

	{
		ShopItem@ s = addShopItem( this, "Wasp", "$wasp$", "wasp", "A personal spacecraft", false, true );
		s.crate_icon = 4;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_wasp );
	}

	// TODO: Better information + icons like the vehicle shop, also make boats not suck
	/*{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + descriptions[10]);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_dinghy);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + descriptions[33], false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_longboat);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		s.crate_icon = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + descriptions[37], false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_warboat);
		s.crate_icon = 2;
	}*/

	this.set_u16("uraniumAmount", 10);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound("/ChaChing.ogg");
		u16 uraniumAmount = this.get_u16("uraniumAmount") - 1;
		this.set_u16("uraniumAmount",  uraniumAmount);

		if(uraniumAmount <= 0){
			this.server_Die();
		}
		else
			this.Chat(formatInt(uraniumAmount, "") + " ships left.");
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null) {
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null) {
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}
