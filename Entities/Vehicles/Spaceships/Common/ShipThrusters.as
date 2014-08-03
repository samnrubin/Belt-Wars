const f32 weakThrust = 0.75;
const f32 powerThrust = 4.0;

void onTick(CMovement@ this){
	CBlob@ blob = this.getBlob();

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	const bool boost	= blob.isKeyJustPressed(key_taunts);

	Vec2f vel = blob.getVelocity();


	

	f32 thrustAmount = blob.get_f32("thrustAmount");
	f32 thrustCutoff = blob.get_u32("thrustCutoffReg");

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

		blob.AddForce(Vec2f(0, modifier * thrustAmount * 1.30));
	}
}
