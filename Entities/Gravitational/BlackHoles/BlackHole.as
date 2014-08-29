void onInit(CBlob@ this){
	this.getShape().SetStatic(true);
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 10;
	this.Tag("blackHole");
	this.Tag("gravityGeneratorRadius");
	this.set_f32("strength", 10.0);
	this.Tag("gravOn");
	f32 gravRadius;
	if(this.getName() == "largeblackhole"){
		gravRadius = 384.0f;
	}
	else
		gravRadius = 128.0;
		
	this.set_f32("grav_radius", gravRadius / 2);
}
