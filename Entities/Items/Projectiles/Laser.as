
#include "Hitters.as";
#include "ShieldCommon.as";
#include "ArcherCommon.as";
#include "BombCommon.as";
#include "TeamStructureNear.as";
#include "Knocked.as";
#include "TeamColour.as";

const s32 bomb_fuse = 120;
const f32 arrowMediumSpeed = 8.0f;
const f32 arrowFastSpeed = 13.0f;
//maximum is 15 as of 22/11/12 (see ArcherCommon.as)

const f32 LASER_PUSH_FORCE = 4.0f;

const s32 FIRE_IGNITE_TIME = 5;


//Arrow logic

//blob functions
void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	//shape.SetGravityScale( 0.5f );	doesnt work
	this.Tag("projectile");

	if (!this.exists("laser type")) {
		this.set_u8("laser type", ArrowType::normal );
	}

	this.Tag("laser");
	this.Tag("ignoregravity");
	this.set_u8("custom_hitter", Hitters::muscles);

	// 20 seconds of floating around - gets cut down for fire arrow
	// in ArrowHitMap
	this.server_SetTimeToDie( 1.5 );

	const u8 arrowType = this.get_u8("laser type");

	this.SetLight(true);
	this.SetLightRadius(24.0f);
	this.SetLightColor(getTeamColor(this.getTeamNum()));

	if(this.getName() == "laserwasp"){
		this.getSprite().PlaySound("WaspLaser.ogg");
	}
	
	/*if (arrowType == ArrowType::bomb)			 // bomb arrow
	{
		SetupBomb( this, bomb_fuse, 48.0f, 1.5f, 24.0f, 0.5f, true );
		this.set_u8("custom_hitter", Hitters::bomb_arrow);
	}

	CSprite@ sprite = this.getSprite();
    //set a random frame
    {
		Animation@ anim = sprite.addAnimation("arrow",0,false);
		anim.AddFrame(XORRandom(4));
		sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("fire arrow",0,false);
		anim.AddFrame(8);
		if(arrowType == ArrowType::fire)
			sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("water arrow",0,false);
		anim.AddFrame(9);
		if(arrowType == ArrowType::water)
			sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("bomb arrow",0,false);
		anim.AddFrame(14);
		anim.AddFrame(15); //TODO flash this frame before exploding
		if(arrowType == ArrowType::bomb)
			sprite.SetAnimation(anim);
	}*/
}


void onTick( CBlob@ this )
{
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);

	f32 angle;
    if (!this.hasTag("collided")) //we haven't hit anything yet!
    {
        angle = (this.getVelocity()).Angle();
        Pierce( this ); //map
        this.setAngleDegrees(-angle);
	//	printf("vell " + shape.vellen);
    }
    
	
	/*// sticking
	if (processSticking)
    {
		//no collision
		shape.getConsts().collidable = false;
		
		if(!this.hasTag("_collisions"))
		{
			this.Tag("_collisions");
			// make everyone recheck their collisions with me
			const uint count = this.getTouchingCount();
			for (uint step = 0; step < count; ++step)
			{
				CBlob@ _blob = this.getTouchingByIndex(step);
				_blob.getShape().checkCollisionsAgain = true;
			}
		}
		
		angle = Maths::get360DegreesFrom256(this.get_u8( "angle" ));
		this.setVelocity(Vec2f(0,0));
		this.setPosition(this.get_Vec2f("lock"));
		shape.SetStatic(true);
		
    }

	const u8 arrowType = this.get_u8("laser type" );
															   
	// fire arrow
    if (arrowType == ArrowType::fire)
    {
		const s32 gametime = getGameTime();
		
		if (gametime % 6 == 0)
		{
			this.getSprite().SetAnimation("fire");
			this.Tag("fire source");

			Vec2f offset = Vec2f(this.getWidth(),0.0f);
			offset.RotateBy( -angle );
			makeFireParticle( this.getPosition() + offset, 4  );

			if (!this.isInWater())
			{
				this.SetLight(true);
				this.SetLightColor( SColor( 255, 250,215,178 ) );
				this.SetLightRadius( 20.5f );
			}
			else {
				turnOffFire(this);
			}
		}
	}*/
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && doesCollideWithBlob( this, blob ) && !this.hasTag("collided"))
    {
		if (!solid && !blob.hasTag("flesh") && (blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum()))
		{
			return;
		}

		Vec2f initVelocity = this.getOldVelocity();
		f32 vellen = initVelocity.Length();
		if (vellen < 0.1f)
			return;
		
		string laserType = this.getName();
		f32 damage = 0;
		if(laserType == "laserwasp"){
			damage = 0.75f;
		}
		
		f32 dmg = blob.getTeamNum() == this.getTeamNum() ? 0.0f : damage;
		
			
		if (dmg > 0.0f) {
			this.server_Hit( blob, point1, initVelocity, dmg, Hitters::muscles);
		}
		this.server_Die();

		//if (dmg > 0.0f) { // dont stick bomb arrows
		//}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	bool check = this.getTeamNum() != blob.getTeamNum();
	if(!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (this.getShape().isStatic() ||
			this.hasTag("collided") ||
			blob.hasTag("dead") )
		{
			return false;
		}
		else
		{
			return true;
		}
	}


	return false;
}

void Pierce( CBlob @this )
{
    CMap@ map = this.getMap();
	Vec2f end;

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, this.getPosition() ,end))
	{
		ArrowHitMap( this, end, this.getOldVelocity(), 0.5f, Hitters::muscles );
	}
}


f32 ArrowHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData, const u8 arrowType )
{
    if (hitBlob !is null)
    {
		// check if shielded
		const bool hitShield = (hitBlob.hasTag("shielded") && blockAttack(hitBlob, velocity, 0.0f));

        CSprite@ sprite = hitBlob.getSprite();


		// play sound
		if (!hitShield)
		{
			if (hitBlob.hasTag("flesh"))
			{
				{
					if (velocity.Length() > arrowFastSpeed) {
						//this.getSprite().PlaySound( "ArrowHitFleshFast.ogg" );
					}
					else {
						//this.getSprite().PlaySound( "ArrowHitFlesh.ogg" );
					}
				}
			}
			else
			{
				if (velocity.Length() > arrowFastSpeed) {
					//this.getSprite().PlaySound( "ArrowHitGroundFast.ogg" );
				}
				else {
					//this.getSprite().PlaySound( "ArrowHitGround.ogg" );
				}
			}
		}
		else {
			if (arrowType != ArrowType::normal)
				damage = 0.0f;
		}

		if (arrowType == ArrowType::bomb )
		{
			if(!this.hasTag("dead"))
			{
				this.doTickScripts = false;
				this.server_Die(); //explode
            }
            this.Tag("dead");
		}
		else if ( arrowType == ArrowType::fire )
		{
			this.server_SetTimeToDie(0.5f);
		}
		else
        {
			this.doTickScripts = false;
            this.server_Die();
        }
    }

	return damage;
}

void ArrowHitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{
	if (velocity.Length() > arrowFastSpeed) {
		this.getSprite().PlaySound( "ArrowHitGroundFast.ogg" );
	}
	else {
		this.getSprite().PlaySound( "ArrowHitGround.ogg" );
	}

	f32 radius = this.getRadius();

	f32 angle = velocity.Angle();

	this.set_u8( "angle", Maths::get256DegreesFrom360(angle)  );

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= (1.5f * radius);
	Vec2f lock = worldPoint - norm;
	this.set_Vec2f( "lock", lock );

	this.Sync("lock",true);
	this.Sync("angle",true);

	this.setVelocity(Vec2f(0,0));
	this.setPosition(lock);
	//this.getShape().server_SetActive( false );

	this.Tag("collided");

	const u8 arrowType = this.get_u8("laser type");

	CMap@ map = getMap();

	TileType t = map.getTile(worldPoint).type;

	
	if(map.isTileCastle(t) && XORRandom(2) == 1 || map.isTileWood(t) && XORRandom(3) > 0)
		map.server_DestroyTile(worldPoint, 0.1f, this);

	this.server_Die();
	/*
	if (arrowType == ArrowType::bomb)
	{
		if(!this.hasTag("dead"))
		{
			this.Tag("dead");
			this.doTickScripts = false;
			this.server_Die(); //explode
		}
	}
	else if (arrowType == ArrowType::water)
	{
		this.server_Die();
	}
	else if (arrowType == ArrowType::fire)
	{
		this.server_SetTimeToDie( FIRE_IGNITE_TIME );
	}*/

}

void FireUp( CBlob@ this )
{
	Vec2f burnpos;
	Vec2f head = Vec2f(this.getRadius()*1.2f,0.0f);
	f32 angle = this.getAngleDegrees();
	head.RotateBy( -angle );
	burnpos = this.getPosition() + head;


	// this.getMap() NULL ON ONDIE!
	CMap@ map = getMap();
	if (map !is null)
	{
		// bruninate
		if (!isTeamStructureNear( this ))
		{
			map.server_setFireWorldspace( burnpos,true );
			map.server_setFireWorldspace( this.get_Vec2f( "fire pos" ) + head*0.4f,true );
			map.server_setFireWorldspace( this.getPosition() ,true); //burn where i am as well
		}
	}
}

void onDie( CBlob@ this )
{
	const u8 arrowType = this.get_u8("laser type");
	
	if (arrowType == ArrowType::fire)
	{
		FireUp(this);
	}

}

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
    if (!getNet().isServer()) {
        return;
    }

	const u8 arrowType = this.get_u8("laser type");
	if (arrowType == ArrowType::bomb)
	{
		return;
	}

    // merge arrow into mat_arrows

    for (int i = 0; i < inventoryBlob.getInventory().getItemsCount(); i++)
    {
        CBlob @blob = inventoryBlob.getInventory().getItem(i);

        if (blob !is this && blob.getName() == "mat_arrows")
        {
            blob.server_SetQuantity( blob.getQuantity() + 1 );
            this.server_Die();
            return;
        }
    }

    // mat_arrows not found
    // make arrow into mat_arrows
    CBlob @mat = server_CreateBlob( "mat_arrows" );

    if (mat !is null)
    {
        inventoryBlob.server_PutInInventory( mat );
        mat.server_SetQuantity(1);
        this.server_Die();
    }
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	const u8 arrowType = this.get_u8("laser type");

	if(customData == Hitters::sword)
	{
		return 1.0f; //CUT LAZERS
	}
	
    return damage;
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	const u8 arrowType = this.get_u8("laser type");
	if (this !is hitBlob && customData == Hitters::muscles)
	{
		// affect players velocity

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > ArcherParams::shoot_max_vel*0.5f)
		{	
			f32 force = (LASER_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass()+1);
			
			/*if (this.hasTag("bow arrow")) {
				force *= 1.3f;
			}*/

			hitBlob.AddForce( velocity * force );

			//printf("this " + this.getTickSinceCreated() );
			//printf(" " + hitBlob.isOnGround() + " " + vel.y + " " + speed);

			// stun if shot real close

			if (this.getTickSinceCreated() <= 5 && speed > ArcherParams::shoot_max_vel*0.845f &&
				hitBlob.hasTag("player") )
			{
				SetKnocked( hitBlob, 20 );
				Sound::Play("/Stun", hitBlob.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);	
			}
		}
	}
}


f32 getArrowDamage( CBlob@ this, f32 vellen = -1.0f )
{
	if(vellen < 0) //grab it - otherwise use cached
	{
		CShape@ shape = this.getShape();
		if(shape is null)
			vellen = this.getOldVelocity().Length();
		else
			vellen = this.getShape().getVars().oldvel.Length();
	}
	
    if (vellen >= arrowFastSpeed) {
        return 1.0f;
    }
    else if (vellen >= arrowMediumSpeed) {
        return 1.0f;
    }

    return 0.5f;
}

