
#include "BuildBlock.as"
#include "Requirements.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks( BuildBlock[]@ blocks )
{
	{   // stone_block
		BuildBlock b( CMap::tile_castle, "stone_block", "$stone_block$",
						"Steel Block\nBasic building block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Iron", 10 );
		blocks.push_back( b );
	}
	{   // back_stone_block
		BuildBlock b( CMap::tile_castle_back, "back_stone_block", "$back_stone_block$",
						"Back Steel Wall\nExtra support" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Iron", 2 );
		blocks.push_back( b );
	}
	{   // stone_door
		BuildBlock b( 0, "stone_door", "$stone_door$",
						"Steel Door\nPlace next to walls" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Iron", 50 );
		blocks.push_back( b );
	}    

	{   // wood_block
		BuildBlock b( CMap::tile_wood, "wood_block", "$wood_block$",
						"Aluminum Block\nCheap block\nwatch out for fire!" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Aluminum", 10 );
		blocks.push_back( b );
	}
	{   // back_wood_block
		BuildBlock b( CMap::tile_wood_back, "back_wood_block", "$back_wood_block$",
						"Back Aluminum Wall\nCheap extra support" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Aluminum", 2 );
		blocks.push_back( b );
	}
	{   // wooden_door
		BuildBlock b( 0, "wooden_door", "$wooden_door$",
						"Aluminum Door\nPlace next to walls" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Aluminum", 30 );
		blocks.push_back( b );
	}

	{   // trap
		BuildBlock b( 0, "trap_block", "$trap_block$",
						"Trap Block\nOnly enemies can pass" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Iron", 25 );
		blocks.push_back( b );
	}	
	{   // ladder
		BuildBlock b( 0, "ladder", "$ladder$",
						"Ladder\nAnyone can climb it" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Aluminum", 10 );
		blocks.push_back( b );
	}
	{   // platform
		BuildBlock b( 0, "wooden_platform", "$wooden_platform$",
						"Aluminum Platform\nOne way platform" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Aluminum", 20 );
		blocks.push_back( b );
	}
	
	{   // spikes
		BuildBlock b( 0, "spikes", "$spikes$",
						"Spikes\nPlace on Steel Block\nfor Retracting Trap" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Iron", 30 );
		blocks.push_back( b );
	}
}
