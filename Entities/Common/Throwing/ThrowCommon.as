//throwing common functionality.


const f32 DEFAULT_THROW_VEL_WTF = 6.0f;

void client_SendThrowOrActivateCommand( CBlob@ this )
{
    CBlob @carried = this.getCarriedBlob();		
    if ((carried !is null || this.getInventory().getItemsCount() > 0) && this.isMyPlayer())
    {
        CBitStream params;
        params.write_Vec2f( this.getPosition() );
        params.write_Vec2f( this.getAimPos() - this.getPosition());
        params.write_Vec2f( this.getVelocity() );
        this.SendCommand( this.getCommandID("activate/throw"), params );
		if(carried !is null && carried.getName() != "keg"){
			newtonianKickback(this, carried);
		}
    }

}

void newtonianKickback(CBlob@ this, CBlob@ carried){
	
		Vec2f vel = getThrowVelocity( this, this.getAimPos() - this.getPosition(), this.getVelocity(),  this.get_f32( "throw ourvel scale") );
		f32 throwerMass = this.getMass();
		f32 thrownMass = carried.getMass();
		if(thrownMass > 68e0f){
			thrownMass = 68.0f;
		}
		Vec2f deltaV = vel * (thrownMass/throwerMass);
		//print("before: " + formatFloat(vel.x, "") + " " + formatFloat(vel.y, ""));
		this.setVelocity(this.getVelocity() -= deltaV);
		//print("after: " + formatFloat(this.getVelocity().x, "") + " " + formatFloat(this.getVelocity().y, ""))
}

void client_SendThrowCommand( CBlob@ this )
{
    CBlob @carried = this.getCarriedBlob();	 
    if (carried !is null && this.isMyPlayer())
    {
        CBitStream params;
        params.write_Vec2f( this.getPosition() );
        params.write_Vec2f( this.getAimPos() - this.getPosition() );
        params.write_Vec2f( this.getVelocity() );
        this.SendCommand( this.getCommandID("throw"), params );
		
		newtonianKickback(this, carried);
;
    }
}

void server_ActivateCommand( CBlob@ this, CBlob@ blob )
{
    if (blob !is null && getNet().isServer())
    {
        blob.SendCommand( blob.getCommandID("activate") );
        blob.Tag("activated");
    }
}

Vec2f getThrowVelocity( CBlob@ this, Vec2f vector, Vec2f selfVelocity, f32 this_vel_affect = 1.0f )
{
    Vec2f vel = vector;
    f32 len = vel.Normalize();
    vel *= DEFAULT_THROW_VEL_WTF;
    vel *= this.get_f32( "throw scale" );
    vel += selfVelocity*this_vel_affect; // blob velocity

	f32 closeDist = this.getRadius() + 64.0f;
	if (selfVelocity.getLengthSquared() < 0.1f && len < closeDist)
	{
		vel *= len / closeDist;
	}
    return vel;
}
