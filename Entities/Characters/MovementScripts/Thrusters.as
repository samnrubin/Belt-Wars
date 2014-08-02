void onInit( CMovement@ this )
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	CShape@ shape = this.getBlob().getShape();
	shape.SetGravityScale(0.0f);
	
}

void onTick( CMovement@ this )
{
	CBlob@ blob = this.getBlob();

	if(!blob.hasTag("gravity")){


		//shape.SetGravityScale(0.0f);
		const bool left		= blob.isKeyPressed(key_left);
		const bool right	= blob.isKeyPressed(key_right);
		const bool up		= blob.isKeyPressed(key_up);
		const bool down		= blob.isKeyPressed(key_down);
		const bool cutoff	= blob.isKeyPressed(key_down);

		Vec2f vel = blob.getVelocity();

		

		f32 thrustAmount = 5;
		int thrustCutoff = 4;
		f32 weakThrust = 0.75;
		f32 powerThrust = 4.0;


		CBlob@ carryBlob = blob.getCarriedBlob();
		if (carryBlob !is null)
		{
			if (carryBlob.hasTag("medium weight"))
			{
				thrustAmount *= 0.5f;
			}
			else if (carryBlob.hasTag("heavy weight"))
			{
				thrustAmount *= 0.3f;
			}
		}


		if(left){
			f32 modifier = 1.5;
			if(vel.x < -1 * thrustCutoff)
				modifier = weakThrust;
			else if( vel.x > 0)
				modifier = powerThrust;

			if(!blob.isFacingLeft()){
				modifier * 0.8;
			}


				
			blob.AddForce(Vec2f(modifier * thrustAmount * -1, 0));
		}
		if(right){
			f32 modifier = 1.5;
			if(vel.x > thrustCutoff)
				modifier = weakThrust;
			else if( vel.x < 0)
				modifier = powerThrust;
			
			if(blob.isFacingLeft()){
				modifier * 0.8;
			}
			
			blob.AddForce(Vec2f(modifier * thrustAmount, 0));

		}
		if(up){
			f32 modifier = 1.5;
			if(vel.y < -1 * thrustCutoff)
				modifier = weakThrust;
			else if( vel.y > 0)
				modifier = powerThrust;

			blob.AddForce(Vec2f(0, modifier * thrustAmount * -1));

		}
		if(down){
			f32 modifier = 1.5;
			if(vel.y > thrustCutoff)
				modifier = weakThrust;
			else if( vel.y < 0)
				modifier = powerThrust;

			blob.AddForce(Vec2f(0, modifier * thrustAmount * 1.35));
		}

		/*string x = formatFloat(vel.x, "");
		string y = formatFloat(vel.y, "");
		f32 velocity = vel.x == 0 ? vel.y : vel.y == 0 ? vel.x : vel.y * vel.x;
		//printf(formatFloat(Maths::Abs(velocity), ""));
		printf("X: " + formatFloat(vel.x, ""));
		printf("Y: " + formatFloat(vel.y, ""));*/
	}
		
}
