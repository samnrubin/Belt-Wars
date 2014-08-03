
void onInit(CBlob@ this){
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
					if(this.hasTag("facecursor")){
						bool facing = (aps[i].getAimPos().x <= this.getPosition().x);
						this.SetFacingLeft(facing);

					}

				}
			}
		}
	}
}


