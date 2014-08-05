//get the fall damage amount for a given vertical velocity
//returns
//  0 for no damage, no stun
//  <0 for stun only
//  >0 for damage amount

f32 BaseFallSpeed()
{
    const f32 BASE_FALL_VEL = 9.0f;
    return getRules().exists("fall vel modifier") ? getRules().get_f32("fall vel modifier") * BASE_FALL_VEL : BASE_FALL_VEL;
}

f32 FallDamageAmount(float vel)
{
    const f32 base = BaseFallSpeed();
    const f32 ramp = 1.2f;
    bool doknockdown = false;

	//print(formatFloat(vely, ""));

    /*if (vely > base)
    {

        if (vely > base * ramp)
        {
            f32 damage = 0.0f;
			doknockdown = true;

            if (vely < base * Maths::Pow(ramp,1))
            {
                damage = 0.25f;
            }
            else if (vely < base * Maths::Pow(ramp,2))
            {
                damage = 0.5f;
            }
            else if (vely < base * Maths::Pow(ramp,3))
            {
                damage = 1.0f;
            }
            else if (vely < base * Maths::Pow(ramp,4)) //regular dead
            {
                damage = 2.0f;
            }
            else //very dead
            {
                damage = 100.0f;
            }

			damage *= 0.5f;

            return damage;
        }

        return -1.0f;
    }*/
	f32 damage;
	if(vel < 10){
		damage = 0.0f;
	}
	else if(vel <= 12){
		damage = -1.0f;
	}
	else if(vel <= 16){
		damage = 0.5f;
	}
	else if(vel <= 20){
		damage = 0.75f;
	}
	else if(vel <= 22){
		damage = 1.5f;
	}
	else{
		damage = 2.0f;
	}

	//10 stuns
	//12 1 heart
	//16 2 heart
	//20 3 heart
    return damage;
}
