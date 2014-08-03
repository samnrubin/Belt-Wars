//#include "VehicleCommon.as"

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
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
    /*return !this.hasAttached() &&
			(!this.isInWater() || this.isOnMap()) &&
			this.getOldVelocity().LengthSquared() < 4.0f;*/
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
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	/*VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onDetach( this, v, detached, attachedPoint );*/
}		
