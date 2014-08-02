void onTick(CBlob@ this){
	if(!(this.hasTag("gravity") || this.hasTag("gravityVertical"))){
		CShape@ shape = this.getShape();
			
		shape.SetGravityScale(0.0f);
	}
	else if(this.hasTag("gravityVertical")){
		// Generator challenges: First check to see the blob exists/is alive, then check radius/position
		CBlob@ generator = getBlobByNetworkID(this.get_netid("generator"));
		if(generator is null || generator.hasTag("dead") || !generator.hasTag("gravityGeneratorVertical")){
			this.Untag("gravityVertical");
			return;
		}

		f32 radius = 8 * generator.get_u8("grav_radius");
		f32 width = generator.getWidth() / 2;

		if(Maths::Abs(generator.getPosition().x - this.getPosition().x) > width || 
		   this.getDistanceTo(generator) > radius){
			this.Untag("gravityVertical");
			return;
		}
		/*if(this.hasTag("player")){
			print("gravcheck");
		}*/


		CShape@ shape = this.getShape();
		shape.SetGravityScale(generator.get_f32("grav_generator_intensity"));
	}

	CBlob @carryBlob = this.getCarriedBlob();

	if(carryBlob !is null){

		if(carryBlob.hasTag("gravityGenerator")){
			carryBlob.Untag("gravityGenerator");
		}
		else if(carryBlob.hasTag("gravityGeneratorVertical")){
			carryBlob.Untag("gravityGeneratorVertical");
		}
	}
}