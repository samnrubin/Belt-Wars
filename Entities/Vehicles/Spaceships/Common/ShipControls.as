const f32 weakThrust = 0.75;
const f32 powerThrust = 4.0;

void onTick(CMovement@ this){
	CBlob@ blob = this.getBlob();

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	const bool boost	= blob.isKeyJustPressed(key_taunts);
	const bool fire		= blob.isKeyPressed(key_action1);

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

	if(fire){
		string laserType = blob.get_string("lasertype");
		if (getNet().isServer()){

			if(!blob.exists("lastfired") || getGameTime() - blob.get_u32("lastfired") >= blob.get_u16("firedelay")){
				Vec2f fireOffset;

				u8 numguns = blob.get_u8("numguns");
				
				if(numguns > 1){
					uint gunToFire;
					if(!blob.exists("lastgunfired")){
						gunToFire = 0;
					 }
					 else{
						gunToFire = blob.get_u8("lastgunfired") + 1;
						
						if(gunToFire >= numguns){
							gunToFire = 0;
						}
					 }
					 fireOffset = blob.get_Vec2f("fireoffset" + formatInt(gunToFire, ""));
					//print(formatFloat(fireOffset.y, ""));
					 blob.set_u8("lastgunfired", gunToFire);
				}
				else
					fireOffset = blob.get_Vec2f("fireoffset");

				if(blob.isFacingLeft()){
					fireOffset.x *= -1;
				}


				CBlob@ laser = server_CreateBlobNoInit(laserType);
				if(laser !is null){
					laser.server_setTeamNum( blob.getTeamNum() );
					laser.Init();
					laser.IgnoreCollisionWhileOverlapped( blob );
					laser.SetDamageOwnerPlayer( blob.getDamageOwnerPlayer() );
					laser.setPosition( blob.getPosition() + fireOffset );
					//print(formatFloat(firePos.x, ""));
					f32 velocityx = blob.isFacingLeft() ? -10 : 10;
					laser.setVelocity( Vec2f(blob.getVelocity().x + velocityx, 0) );
					blob.set_u32("lastfired", getGameTime());
				}
			}
		}
	}
}
