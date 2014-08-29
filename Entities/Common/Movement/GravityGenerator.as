#include "DebugSuite.as"

void onInit(CBlob@ this){
	calculateField(this);

}

void calculateField(CBlob@ this){
	Vec2f pos = this.getPosition();
	f32 gravwidth = 8 * this.get_u8("grav_width");
	f32 gravheight = 8 * this.get_u8("grav_height");

	f32 width = this.getWidth();
	f32 height = this.getHeight() / 2;

	this.set_Vec2f("ul", Vec2f(pos.x - gravwidth, pos.y + height - gravheight)); 
	this.set_Vec2f("lr", Vec2f(pos.x + gravwidth, pos.y + height)); 

}

void onTick (CBlob@ this){
	//Carried blobs shouldn't generate gravity
	if(this.isAttached()){
		this.Tag("carried");
	}
	else if(this.hasTag("carried")){
		this.Untag("carried");
	}
	else if(this.getName() == "saw"){
		calculateField(this);
	}
		

	if(!this.hasTag("gravOn") || this.hasTag("carried")){
		return;
	}

	if(this.hasTag("gravityGeneratorVertical")){
		if(this.hasTag("moveable")){
			Vec2f pos = this.getPosition();
			CBlob@[] blobs;
			f32 radius = 8 * this.get_u8("grav_radius");
			f32 width = this.getWidth();
			f32 height = this.getHeight();
			getMap().getBlobsInRadius( pos, radius, @blobs );
			for(uint i = 0; i < blobs.length; i++){
				CBlob@ blob = blobs[i];
				Vec2f blobPos = blobs[i].getPosition();
				/*if(!(blob.getName() == this.getName())){
					print("inradius");
				}*/
				if(this.hasTag("team_gravity") && blob.getTeamNum() == this.getTeamNum()){
					continue;
				}
				if(!(blob.hasTag("gravity") || blob.hasTag("gravityVertical")) &&
					Maths::Abs(blobPos.x - pos.x) <= width / 2 &&
					(pos.y + height/2) + 8 >= blobPos.y 
				){
					blob.Tag("gravityVertical");
					blob.set_netid("generator", this.getNetworkID());
				}


			}
		

		}
		else{
			this.getCurrentScript().tickFrequency = 30;

			
			CBlob@[] blobs;
			Vec2f ul = this.get_Vec2f("ul");
			Vec2f lr = this.get_Vec2f("lr");
			getMap().getBlobsInBox( ul, lr, @blobs );
			for(uint i = 0; i < blobs.length; i++){
				CBlob@ blob = blobs[i];
				Vec2f blobPos = blobs[i].getPosition();
				/*if(!(blob.getName() == this.getName())){
					print("inradius");
				}*/
				if((this.hasTag("team_gravity") && blob.getTeamNum() == this.getTeamNum()) ||
					blob.getShape().isStatic() || blob.hasTag("gravityVertical") ){
					continue;
				}

				blob.Tag("gravityVertical");
				blob.set_netid("generator", this.getNetworkID());
			}
		}
	}
	else if(this.hasTag("gravityGeneratorRadius")){
		bool storage = this.getName() == "storage";
		this.getCurrentScript().tickFrequency = 1;
		Vec2f center = this.getPosition();
		CBlob@[] blobs;
		f32 radius =  this.get_f32("grav_radius");
		if(getMap().getBlobsInRadius(center, radius * 4 , @blobs )){
			f32 strength = this.get_f32("strength");
				for(uint i = 0; i < blobs.length; i++){
					CBlob@ blob = blobs[i];
					if(!blob.getShape().isStatic() && blob.getName() != "ctf_flag" ){
						if(storage && (!blob.hasTag("material") || blob.getName() == "mat_arrows")){
							continue;
						}

						// Calculate the pull using the base proportion mass of a knight
						Vec2f distance = blob.getPosition() - center;
						f32 dist = distance.Length();
						if(dist == 0){
							dist = 0.1;
						}
						f32 gravStrength = strength * blob.getMass() / 68 * (radius * radius) / (dist * dist);

						/*if(dist <= radius / 4){
							gravStrength = strength;
						}
						else{
							dist -= radius / 4;
							gravStrength = strength * (1.0 - (dist / (radius * 0.75)) );
						}*/
						
						// Gravity effects
						distance.Normalize();
						if(dist < radius / 4.0 && !storage){
							blob.server_Die();
						}
						else if(dist < radius){

							if(blob.exists("afterburner") && blob.get_bool("afterburner")){
								blob.set_bool("afterburner", false);
								blob.getSprite().PlaySound("PowerDown.ogg", 2.0);
							}

						}
						//if(gravStrength > 1.0){
							blob.AddForce(distance * gravStrength * -1);
						//}
					}
				}
		}
	}
}
