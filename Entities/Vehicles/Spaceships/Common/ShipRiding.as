
void onInit(CBlob@ this){

	this.addCommandID("leave");
	this.addCommandID("enter");
	this.Tag("spaceship");

}


void onTick(CBlob@ this){
	AttachmentPoint@[] aps;		 
	if (this.getAttachmentPoints( @aps )){
		for (uint i = 0; i < aps.length; i++){
			AttachmentPoint@ ap = aps[i];

			if (ap.socket && ap.name == "DRIVER"){
				CBlob@ occ = ap.getOccupied();
				ap.SetKeysToTake( key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3 );

				if ((occ !is null)){
					this.setKeyPressed( key_left, ap.isKeyPressed( key_left ) );
					this.setKeyPressed( key_right, ap.isKeyPressed( key_right ) );
					this.setKeyPressed( key_up, ap.isKeyPressed( key_up ) );
					this.setKeyPressed( key_down, ap.isKeyPressed( key_down ) );
					this.setKeyPressed( key_action1, ap.isKeyPressed( key_action1 ) );
					if(this.hasTag("facecursor")){
						bool facing = (aps[i].getAimPos().x <= this.getPosition().x);
						this.SetFacingLeft(facing);

					}

				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller){
	AttachmentPoint@[] aps;
	if(this.isAttachedTo(caller)){
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("leave"), "Leave Ship", params);
	}
	else if (this.getAttachmentPoints( @aps )){
		for (uint i = 0; i < aps.length; i++){
			AttachmentPoint@ ap = aps[i];
			if (ap.socket && ap.getOccupied() is null){
				CBitStream params;
				params.write_u16( caller.getNetworkID() );
				params.write_u8(i);
				string posName = ap.name == "DRIVER" ? "Pilot" : "Gunner";
				caller.CreateGenericButton(11, Vec2f(8 * i, 0), this, this.getCommandID("enter"), posName, params);
			}
		}
	}
	
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("leave"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID( callerID );
		if(caller !is null && getNet().isServer()){
			this.server_DetachFrom(caller);
			
		}
	}

	if(cmd == this.getCommandID("enter")){
		u16 callerID = params.read_u16();
		u8 attachIndex = params.read_u8();
		CBlob@ caller = getBlobByNetworkID( callerID );
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints( @aps) && caller !is null ){
			if(aps[attachIndex] !is null && aps[attachIndex].getOccupied() is null){
				caller.server_DetachFromAll();
				this.server_AttachTo(caller, aps[attachIndex]);
			}
		}
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (attachedPoint.socket)
	{
		detached.setVelocity( this.getVelocity() );
	}

	this.setKeyPressed( key_left, false );
	this.setKeyPressed( key_right, false );
	this.setKeyPressed( key_up, false );
	this.setKeyPressed( key_down, false );
	this.setKeyPressed( key_action1, false );

	detached.Untag("inship");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint ){
	attached.Tag("invincible");
	attached.Tag("inship");
}
