//#include "VehicleCommon.as"
#include "Explosion.as"

// Boat logic

void onInit(CBlob@ this )
{
    /*Vehicle_Setup( this,
                   200.0f, // move speed
                   0.31f,  // turn speed
                   Vec2f(0.0f, -2.5f), // jump out velocity
                   true  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
    this.getShape().SetOffset(Vec2f(0,9));
    this.getShape().SetCenterOfMassOffset(Vec2f(-1.5f,4.5f));
	this.getShape().getConsts().transports = true;
	this.Tag("heavy weight");*/

	this.set_f32("thrustAmount", 70);
	this.set_u32("thrustCutoffReg", 4);
	this.getShape().SetRotationsAllowed(false);
	this.Tag("facecursor");
	this.set_Vec2f("fireoffset0", Vec2f(-4, -2));
	this.set_Vec2f("fireoffset1", Vec2f(-4, 3));
	this.set_string("lasertype", "laserwasp");
	this.set_u16("firedelay", getTicksASecond() * .5);
	this.set_u8("numguns", 2);

	this.Tag("convert on sit");
}


bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

/*void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}
bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}*/

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return Vehicle_doesCollideWithBlob_boat( this, blob );
	if(this.getTeamNum() != blob.getTeamNum()){
		return true;
	}
	return false;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	/*VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onAttach( this, v, attached, attachedPoint );*/
	this.SetDamageOwnerPlayer( attached.getPlayer() );
	attached.DropCarried();
}

void onDie( CBlob@ this){
	this.SetDamageOwnerPlayer(this.getPlayerOfRecentDamage());

	AttachmentPoint@[] aps;
	
	if (this.getAttachmentPoints( @aps )){
		for (uint i = 0; i < aps.length; i++){
				AttachmentPoint@ ap = aps[i];
				CBlob@ blob = ap.getOccupied();
				if (ap.socket && blob !is null){
					blob.Untag("inship");
					this.server_Hit(blob, this.getPosition(), Vec2f_zero, 4.0f, Hitters::explosion, true);

				}
		}
	}
	Explode(this, 40.0f, 4.0f);
}
