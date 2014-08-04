#include "MakeDustParticle.as";

const f32 thrust = 5;
const int thrustCutoffReg = 4;
const f32 weakThrust = 0.75;
const f32 powerThrustReg = 4.0;

const u32 recoverTime = getTicksASecond() * 6;
const u32 afterburnerKickinTime = getTicksASecond();

void onInit( CMovement@ this )
{
	CBlob@ blob = this.getBlob();
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	CShape@ shape = blob.getShape();
	shape.SetGravityScale(0.0f);

	blob.set_f32("fuel", 100.0f);
	blob.set_u32("lastBoostTime", getGameTime() - getTicksASecond() * 10);
	blob.set_bool("afterburner", false);
	
}

void thrustedOut(CBlob@ this){
	Vec2f pos = this.getPosition();

	if(pos.y < 0){
		this.setPosition(Vec2f(pos.x, pos.y + 40));
	}
}

bool canAfterburn(CBlob@ this){
	return getGameTime() - this.get_u32("afterburntime") > afterburnerKickinTime;
}

void onTick( CMovement@ this )
{
	CBlob@ blob = this.getBlob();

	thrustedOut(blob);
	f32 fuel = blob.get_f32("fuel");

	if(!blob.hasTag("nofuel")){

	//print("thrustfuel: " + formatFloat(blob.get_f32("fuel"), ""));


		//shape.SetGravityScale(0.0f);
		const bool left		= blob.isKeyPressed(key_left);
		const bool right	= blob.isKeyPressed(key_right);
		const bool up		= blob.isKeyPressed(key_up);
		const bool down		= blob.isKeyPressed(key_down);
		const bool boost	= blob.isKeyJustPressed(key_taunts);

		bool afterburner = blob.get_bool("afterburner");

		if(boost){
			afterburner = !afterburner;

			if(afterburner){
				blob.set_u32("afterburntime", getGameTime());
				blob.getSprite().PlaySound("PowerUp.ogg", 2.0);
				
			}
			else{
				blob.getSprite().PlaySound("PowerDown.ogg", 2.0);
			}
			blob.set_bool("afterburner", afterburner);
			
		}
		//const bool cutoff	= blob.isKeyPressed(key_down);

		Vec2f vel = blob.getVelocity();

		

		f32 thrustAmount = thrust;
		f32 thrustCutoff = thrustCutoffReg;
		f32 powerThrust = powerThrustReg;


		if(getGameTime() - blob.get_u32("afterburntime") == afterburnerKickinTime){
			ParticleZombieLightning(blob.getPosition());
			Vec2f vel = blob.getVelocity();
			vel.Normalize();
			blob.setVelocity(vel * 10.0);

		}
		
		bool afterburning = afterburner && canAfterburn(blob);

		if(afterburning){
			/*thrustAmount *= 2;
			thrustCutoff *= 8;
			powerThrust *= 12;
			if(!(left || right || up || down)){
				Vec2f vel = blob.getVelocity();
				vel.Normalize();
				blob.AddForce(vel * 16.0);
			}*/
		}

		
		f32 afterburnSpeed = 10.0f;


		CBlob@ carryBlob = blob.getCarriedBlob();
		if (carryBlob !is null)
		{
			if (carryBlob.hasTag("medium weight"))
			{
				thrustAmount *= 0.5f;
				afterburnSpeed *= 0.5f;
			}
			else if (carryBlob.hasTag("heavy weight"))
			{
				thrustAmount *= 0.3f;
				afterburnSpeed *= 0.3f;
			}
		}


		if(afterburning){
			Vec2f burnVelocity = Vec2f(0, 0);
			Vec2f oldVelocity = blob.getVelocity();
			if(left){
				burnVelocity.x = afterburnSpeed * -1;
			}
			else{
				burnVelocity.x = oldVelocity.x;
			}

			if(right){
				burnVelocity.x = afterburnSpeed;
			}
			else{
				burnVelocity.x = oldVelocity.x;
			}

			if(up){
				burnVelocity.y = afterburnSpeed * -1;
			}
			else{
				burnVelocity.y = oldVelocity.y;
			}

			if(down){
				burnVelocity.y = afterburnSpeed * 1;
			}
			else{
				burnVelocity.y = oldVelocity.y;
			}

			blob.setVelocity(burnVelocity);
		}
		else{
			if(left){
				f32 modifier = 1.5;
				if(vel.x < -1 * thrustCutoff)
					modifier = weakThrust;
				else if( vel.x > 0)
					modifier = powerThrust;

				if(!blob.isFacingLeft() && !afterburning){
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
				
				if(blob.isFacingLeft() && !afterburning){
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

				blob.AddForce(Vec2f(0, modifier * thrustAmount * 1.20));
			}
		}
		
		if(afterburning){
			//fuel -= 0.90;
			//blob.set_u32("lastBoostTime", getGameTime());
		}
		else if(left || right || up || down){

			fuel -= 0.30;
		}

		if(afterburning && getGameTime() % 5 == 0){
			MakeDustParticle( blob.getPosition(), "Smoke.png");
		}
		else if(afterburner && getGameTime() % 10 == 0){
			MakeDustParticle( blob.getPosition(), "Smoke.png");
		}

		/*string x = formatFloat(vel.x, "");
		string y = formatFloat(vel.y, "");
		f32 velocity = vel.x == 0 ? vel.y : vel.y == 0 ? vel.x : vel.y * vel.x;
		//printf(formatFloat(Maths::Abs(velocity), ""));
		printf("X: " + formatFloat(vel.x, ""));
		printf("Y: " + formatFloat(vel.y, ""));*/
	}

	u32 timeSinceBoost = getGameTime() - blob.get_u32("lastBoostTime");
	
	if(timeSinceBoost > recoverTime / 2){

		if(fuel < 100.0){
			fuel += 0.25;
		}
		else if(fuel > 100.0){
			fuel = 100.0;
		}

	}
	
	if(timeSinceBoost > recoverTime){
		blob.Untag("nofuel");
	}
	
	if(fuel < 0 && !blob.hasTag("nofuel")){
		fuel = 0.0;
		//MakeDustParticle( blob.getPosition(), "Smoke.png");
		blob.getSprite().PlaySound("PowerDown.ogg", 2.0);
		blob.set_u32("lastBoostTime", getGameTime());
		blob.Tag("nofuel");
		blob.set_bool("afterburner", false);
	}
	
	if(blob.hasTag("nofuel") && getGameTime() % 10 == 0){ 
		MakeDustParticle( blob.getPosition(), "Smoke.png");
		if(blob.isMyPlayer() && getGameTime() % 40 == 0){
			Sound::Play("depleted.ogg");

		}
	}

	if(blob.isMyPlayer() && getGameTime() % 30 == 0 && !blob.hasTag("nofuel") &&
	  fuel <= 12.5){
		Sound::Play("depleting.ogg");
	  }
		
	blob.set_f32("fuel", fuel);
}


/*Vec2f normalize(Vec2f direction){
	f32 normalizer = Maths::Abs(direction.x) > Maths::Abs(direction.y) ? direction.x : direction.y;
	return direction / Maths::Abs(normalizer);
}*/
