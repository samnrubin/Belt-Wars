#include "Hitters.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){
	if(this.hasTag("inship")){
		damage = 0;
	}


	if(customData == Hitters::muscles){
		damage *= 2;
	}
	
	return damage;
}

