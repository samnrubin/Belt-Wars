#include "Hitters.as"

#include "FireCommon.as"

void onInit(CBlob@ this)
{
	this.Tag("gravityGeneratorVertical");
		this.set_u8("grav_width", 50.0); 
		this.set_u8("grav_height", 150.0); 
		this.set_f32("grav_generator_intensity", 1.0);
		this.Tag("gravOn");
		this.Untag("large");

	this.set_TileType("background tile", CMap::tile_castle_back);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

