#include "MakeDustParticle.as";
#include "FireParticle.as";
#include "Explosion.as";

const f32 thrust = 5.5;
const int thrustCutoffReg = 5;
const f32 weakThrust = 0.75;
const f32 powerThrustReg = 4.0;

const u32 recoverTime = getTicksASecond() * 6;
const u32 afterburnerKickinTime = getTicksASecond();
const f32 afterburnSpeedReg = 13.0f;
const u32 afterburnOverheat = getTicksASecond() * 2.5;

const int burnSwitch = getTicksASecond() / 4;

void onInit( CMovement@ this )
{
	CBlob@ blob = this.getBlob();
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	/*CShape@ shape = blob.getShape();
	shape.SetGravityScale(0.0f);*/

	blob.set_f32("fuel", 100.0f);
	blob.set_u32("lastBoostTime", getGameTime() - getTicksASecond() * 10);
	blob.set_bool("afterburner", false);
	
	blob.set_u32("afterburntime", getGameTime() - 2 * afterburnerKickinTime);
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
	Vec2f vel = blob.getVelocity();
	if(blob.hasTag("fullgravity") && vel.y <= 0 ){
		return;
	}

	Vec2f pos = blob.getPosition();

	thrustedOut(blob);
	f32 fuel = blob.get_f32("fuel");

	f32 vely = Maths::Abs(vel.y);
    f32 velx = Maths::Abs(vel.x);

	f32 topvel = velx > vely ? velx : vely;

	if(getNet().isClient() && getGameTime() % 3 == 0)
	{
		const string fallscreamtag = "_fallingscream";
		if(topvel > 0.2f)
		{
			if(topvel > 22)
			{
				if(!blob.hasTag(fallscreamtag))
				{
					blob.Tag(fallscreamtag);
					blob.getSprite().PlaySound("man_scream.ogg");
				}
			}
		}
		else
		{
			blob.Untag(fallscreamtag);
		}
	}

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
				blob.set_u32("overheatTime", 0);
				blob.getSprite().PlaySound("PowerUp.ogg", 2.0);
				
			}
			else{
				blob.getSprite().PlaySound("PowerDown.ogg", 2.0);
				blob.Untag("directionchange");
				blob.Untag("overheating");
			}
			blob.set_bool("afterburner", afterburner);
			
		}
		//const bool cutoff	= blob.isKeyPressed(key_down);

		Vec2f vel = blob.getVelocity();

		

		f32 thrustAmount = thrust;
		f32 thrustCutoff = thrustCutoffReg;
		f32 powerThrust = powerThrustReg;


		
		bool afterburning = afterburner && canAfterburn(blob);


		f32 afterburnSpeed = afterburnSpeedReg;	


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
		
		if(getGameTime() - blob.get_u32("afterburntime") == afterburnerKickinTime && afterburning){
			//makeSmallExplosionParticle(pos);
			blob.getSprite().PlaySound("Bomb.ogg", 0.40);
			//blob.getSprite().PlaySound("thud.ogg", 1.0);
			
			Vec2f distance = blob.getAimPos() - pos;
			distance.Normalize();
			blob.setVelocity(distance * afterburnSpeed);
			blob.set_u32("switchTime", getGameTime() - burnSwitch);
			blob.set_Vec2f("oldaim", distance);
		}

		if(blob.getName() == "archer"){
			afterburnSpeed++;
		}

		//Old aftrerburner code
		/*if(afterburning){
			Vec2f oldVelocity = blob.getVelocity();
			Vec2f burnVelocity = oldVelocity;
			bool noX = false;
			bool noY = false;



			if(left && oldVelocity.x > -1 * (afterburnSpeed -0.1)){
				burnVelocity.x = afterburnSpeed * -1;
			}

			if(right && oldVelocity.x < (afterburnSpeed + 0.1)){
				burnVelocity.x = afterburnSpeed;
			}

			if((left && right) || !(left || right)){
				//burnVelocity.x = oldVelocity.x;
				//print("nox");
				noX = true;
			}

			if(up && oldVelocity.y > -1 * (afterburnSpeed -0.1)){
				burnVelocity.y = afterburnSpeed * -1;
			}

			if(down && oldVelocity.y < (afterburnSpeed + 0.1)){
				burnVelocity.y = afterburnSpeed * 1;
			}

			if((up && down) || !(up || down)){
				//burnVelocity.y = oldVelocity.y;
				noY = true;
			}

			if(!noX && noY){
				burnVelocity.y = 0;
			}
			else if(!noY && noX){
				burnVelocity.x = 0;
			}
			else if(noX && noY){
				burnVelocity = oldVelocity;
			}

			blob.setVelocity(burnVelocity);
			burnVelocity.Normalize();
			blob.AddForce(vel * 1);
		}*/


		if(afterburning){
			
			Vec2f oldVelocity = blob.getVelocity();
			Vec2f aim = blob.getAimPos();

			Vec2f distance = aim - pos;

			distance.Normalize();

			if(getGameTime() % 5 == 0){
				Vec2f oldaim;
				oldaim = blob.get_Vec2f("oldaim");
				blob.set_Vec2f("oldaim", distance);
				
				if(Maths::Abs(distance.AngleWith(oldaim)) > 60){
					blob.set_u32("switchTime", getGameTime());
					blob.setVelocity(Vec2f_zero);
					blob.Tag("directionchange");
				}
				else if(!blob.hasTag("directionchange")){
					if(oldVelocity.Length() < afterburnSpeed - 1)
						blob.setVelocity(distance * afterburnSpeed);
					else{
						blob.setVelocity(distance * (oldVelocity.Length() + afterburnSpeed/(afterburnSpeedReg * 2)));
					}
				}
				else if(getGameTime() - blob.get_u32("switchTime") > burnSwitch){
					blob.Untag("directionchange");
					blob.setVelocity(distance * afterburnSpeed);
					makeSmallExplosionParticle(pos);
					blob.getSprite().PlaySound("Bomb.ogg", 0.40);
				}
				//print(formatFloat(distance.AngleWith(oldaim),""));

			}

			if(oldVelocity.Length() <= 2){
				if(!blob.exists("overheatTime")){
					blob.set_u32("overheatTime", 0);
				}
				u32 overheatTime = blob.get_u32("overheatTime");
				if(overheatTime >= afterburnOverheat ){
					blob.server_Hit(blob, pos, Vec2f_zero, 0.5f, Hitters::burn, true);
					print("overheat");
					blob.set_u32("overheatTime", 0);
				}
				else{
					blob.set_u32("overheatTime", ++overheatTime);
					blob.Sync("overheatTime", false);
				}

				if(overheatTime >= afterburnOverheat / 2 ){
					//MakeDustParticle( blob.getPosition(), "Smoke.png");
					blob.Tag("overheating");
				}
			}
			else{
				blob.set_u32("overheatTime", 0);
				blob.Untag("overheating");
			}

			if(blob.hasTag("overheating") ){
				if(getGameTime() % 15 == 0)
					makeFireParticle(pos);
					if(blob.isMyPlayer()){
						if(getGameTime() % 45 == 0)
							blob.getSprite().PlaySound("MigrantSayNo.ogg", 1.0);
					}
			}
			else if(getGameTime() % 5 == 0){
				//makeSmallExplosionParticle(pos);
				MakeDustParticle( blob.getPosition(), "Smoke.png");
			}
			
			
			
			/*bool left = aim.x < pos.x;
			bool right = aim.x > pos.x;
			bool up = aim.y < pos.y;
			bool down = aim.y > pos.y;
			



			if(left && oldVelocity.x > 4 * distance.x){
				force.x -= turnForce;
			}
			else if(right && oldVelocity.x < 4 * distance.x){
				force.x += turnForce; 
			}
			else{
				burnVelocity.x = speed.x;
			}
			if(up && oldVelocity.y > 4 * distance.y){
				force.y -= turnForce; 
			}
			else if(down && oldVelocity.y < 4 * distance.y){
				force.y += turnForce; 
			}
			else{
				burnVelocity.y = speed.y;
			}*/




			/*if(left && oldVelocity.x > 0){
				force.x -= turnForce;
			}
			else if(left && oldVelocity.x > turnCutoff * -1){
				burnVelocity.x = -1 * turnCutoff;
			}
			if(right && oldVelocity.x < 0){
				force.x += turnForce; 
			}
			else if(right && oldVelocity.x < turnCutoff){
				burnVelocity.x = turnCutoff;
			}
			if(up && oldVelocity.y > 0){
				force.y -= turnForce; 
			}
			else if(up && oldVelocity.y > turnCutoff * -1){
				burnVelocity.y = -1 * turnCutoff;
			}
			if(down && oldVelocity.y < 0){
				force.y += turnForce; 
			}
			else if(down && oldVelocity.y < turnCutoff){
				burnVelocity.y = turnCutoff;
			}*/

			//blob.setVelocity(burnVelocity);

			//blob.AddForce(force);

			
			/*


			if(left && oldVelocity.x > -1 * (afterburnSpeed -0.1)){
				burnVelocity.x = afterburnSpeed * -1;
			}

			if(right && oldVelocity.x < (afterburnSpeed + 0.1)){
				burnVelocity.x = afterburnSpeed;
			}

			if((left && right) || !(left || right)){
				//burnVelocity.x = oldVelocity.x;
				//print("nox");
				noX = true;
			}

			if(up && oldVelocity.y > -1 * (afterburnSpeed -0.1)){
				burnVelocity.y = afterburnSpeed * -1;
			}

			if(down && oldVelocity.y < (afterburnSpeed + 0.1)){
				burnVelocity.y = afterburnSpeed * 1;
			}

			if((up && down) || !(up || down)){
				//burnVelocity.y = oldVelocity.y;
				noY = true;
			}

			if(!noX && noY){
				burnVelocity.y = 0;
			}
			else if(!noY && noX){
				burnVelocity.x = 0;
			}
			else if(noX && noY){
				burnVelocity = oldVelocity;
			}

			blob.setVelocity(burnVelocity);
			burnVelocity.Normalize();
			blob.AddForce(vel * 1);*/
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
			fuel -= 1.0;
			//blob.set_u32("lastBoostTime", getGameTime());
		}
		else if(left || right || up || down){

			fuel -= 0.40;
		}


		if(afterburner && !afterburning && getGameTime() % 10 == 0 ){
				MakeDustParticle( pos, "Smoke.png");
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
			fuel += 0.35;
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
		if(blob.get_bool("afterburner") == true){
			Explode(blob, 16.0f, 0.0f);
			f32 damage = 1.0;
			if(blob.getName() == "archer"){
				damage /= 2;
			}
			blob.server_Hit(blob, pos, Vec2f_zero, damage, Hitters::explosion, true);
			blob.set_bool("afterburner", false);
			blob.Untag("directionchange");
			blob.Untag("overheating");
		}
	}
	
	if(blob.hasTag("nofuel") && getGameTime() % 10 == 0){ 
		MakeDustParticle( pos, "LargeSmoke.png");
		if(blob.isMyPlayer() && getGameTime() % 40 == 0){
			Sound::Play("depleted.ogg");

		}
	}

	if(blob.isMyPlayer() && getGameTime() % 30 == 0 && !blob.hasTag("nofuel") &&
	  (fuel <= 12.5 || (fuel <= 30.0 && blob.get_bool("afterburner")))){
		Sound::Play("depleting.ogg");
	  }
		
	blob.set_f32("fuel", fuel);
}


/*Vec2f normalize(Vec2f direction){
	f32 normalizer = Maths::Abs(direction.x) > Maths::Abs(direction.y) ? direction.x : direction.y;
	return direction / Maths::Abs(normalizer);
}*/
