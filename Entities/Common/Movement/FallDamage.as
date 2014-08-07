//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";

#include "FallDamageCommon.as";

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (!solid) {
        return;
    }

    if(blob !is null && (blob.hasTag("player") || blob.hasTag("no falldamage")))
    {
        return; //no falldamage when stomping
    }
    f32 cvely = Maths::Abs(this.getVelocity().y);
    f32 cvelx = Maths::Abs(this.getVelocity().x);

    f32 vely = Maths::Abs(this.getOldVelocity().y);
    f32 velx = Maths::Abs(this.getOldVelocity().x);

    if( !((velx >= 10 && cvelx < 6 )|| (vely >= 10 && cvely < 6))) { return; }

	if(this.exists("afterburner") && this.get_bool("afterburner") && getGameTime() - this.get_u32("switchTime") < getTicksASecond() ){ return; }

	f32 topvel = velx > vely ? velx : vely;

    f32 damage = FallDamageAmount(topvel);
    if(damage != 0.0f) //interesting value
    {
        bool doknockdown = true;

        if(damage > 0.0f)
        {
            // check if we aren't touching a trampoline
            CBlob@[] overlapping;

            if (this.getOverlapping( @overlapping ))
            {
                for (uint i = 0; i < overlapping.length; i++)
                {
                    CBlob@ b = overlapping[i];

                    if (b.hasTag("no falldamage"))
                    {
                        return;
                    }
                }
            }

			if (damage > 0.1f)
            {
				this.server_Hit( this, point1, normal, damage, Hitters::fall );
			}
			else
            {
				doknockdown = false;
            }
        }

        // stun on fall
        const u8 knockdown_time = 12;

        if ( doknockdown && this.exists("knocked") && this.get_u8("knocked") < knockdown_time)
        {
            if(damage < this.getHealth()) //not dead
                Sound::Play( "/BreakBone", this.getPosition() );
            else
            {
                Sound::Play( "/FallDeath.ogg", this.getPosition() );
            }

            this.set_u8("knocked",knockdown_time);
        }
    }
}
