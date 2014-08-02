void onTick (CBlob@ this){
	if(this.hasTag("gravityGeneratorVertical")){
		Vec2f pos = this.getPosition();
		CBlob@[] blobs;
		f32 radius = 8 * this.get_u8("grav_radius");
		f32 width = this.getWidth();
		f32 height = this.getHeight();
		getMap().getBlobsInRadius( pos, radius, @blobs );
		for(uint i = 0; i < blobs.length; i++){
			CBlob@ blob = blobs[i];
			Vec2f blobPos = blobs[i].getPosition();
			if(!(blob.hasTag("gravity") || blob.hasTag("gravityVertical")) &&
				Maths::Abs(blobPos.x - pos.x) <= width / 2 &&
				(pos.y + height/2) + 8 >= blobPos.y 
			){
				blob.Tag("gravityVertical");
				blob.set_netid("generator", this.getNetworkID());
				print("gravset");
			}


		}
		
	}
}
