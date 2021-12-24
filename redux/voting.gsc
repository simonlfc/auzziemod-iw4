#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

CONST_MAP_VOTE_SIZE = 6;

init()
{
    level waittill( "spawning_intermission" );

    if ( !fileExists( "map_voting.cfg" ) )
    {
        iPrintLn( "map_voting.cfg not found, aborting vote..." );
        return;
    }

    foreach ( player in level.players )
    {
        if ( player isBot() )
            kick( player getEntityNumber() );

        player.vote_id = undefined;
    } 
    
    maps = [];
    
    config = strTok( fileRead( "map_voting.cfg" ), "\n" );
    for ( i = 0; i < CONST_MAP_VOTE_SIZE; i++ )
    {
        potential_map = config[ randomInt( config.size ) ];
        config[ config.size ] -= potential_map;
        maps[ maps.size ] = potential_map;
        makeDvarServerInfo( "map_vote_name_" + i, potential_map );
        makeDvarServerInfo( "map_vote_count_" + i, 0 );
    }

    foreach ( player in level.players )
    {
        self openMenu( "map_voting" );
    }
}

cast_map_vote( idx )
{
    if ( idx == self.vote_id )
    {
        self iPrintLn( "Can't vote for your currently voted map" );
        return;
    }
    if ( idx > CONST_MAP_VOTE_SIZE || idx < 0 )
    {
        self iPrintLn( "Invalid map vote index: ", idx );
        return;
    }
    
    makeDvarServerInfo( "map_vote_count_" + idx, getDvarInt( "map_vote_count_" + idx ) + 1 );
}