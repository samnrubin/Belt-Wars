
void onInit(CBlob@ this){
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this){
	if(!(this.hasTag("gravityVertical"))){
		CShape@ shape = this.getShape();
			
		shape.SetGravityScale(0.0f);
	}
	else if(this.hasTag("gravityVertical")){
		// Generator challenges: First check to see the blob exists/is alive, then check radius/position, then check to make sure it's not currently carried
		CBlob@ generator = getBlobByNetworkID(this.get_netid("generator"));
		if(generator is null || generator.hasTag("dead") || !generator.hasTag("gravOn") || generator.hasTag("carried")){
			this.Untag("gravityVertical");
			this.Untag("fullgravity");
			return;
		}

		Vec2f ul = generator.get_Vec2f("ul");
		Vec2f lr = generator.get_Vec2f("lr");

		Vec2f pos = this.getPosition();
		
		/*if(this.hasTag("player")){
			c("player", this.getPosition());
			c("lr", lr);
		}*/


		if(pos.x < ul.x || pos.x > lr.x || pos.y < ul.y || pos.y > lr.y){
			this.Untag("gravityVertical");
			this.Untag("fullgravity");
			return;
		}


		CShape@ shape = this.getShape();
		f32 intensity = generator.get_f32("grav_generator_intensity");
		if(intensity >= 0.6){
			this.Tag("fullgravity");
			if(this.exists("afterburner") && this.get_bool("afterburner")){
				this.set_bool("afterburner", false);
				this.getSprite().PlaySound("PowerDown.ogg", 2.0);
			}
							
		}

		shape.SetGravityScale(intensity);

	}

	/*CBlob @carryBlob = this.getCarriedBlob();

	if(carryBlob !is null){

		if(carryBlob.hasTag("gravityGenerator")){
			carryBlob.Untag("gravityGenerator");
		}
		else if(carryBlob.hasTag("gravityGeneratorVertical")){
			carryBlob.Untag("gravityGeneratorVertical");
		}
	}*/
}
