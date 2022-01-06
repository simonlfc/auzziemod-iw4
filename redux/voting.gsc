#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

CONST_MAP_VOTE_SIZE = 6;

init()
{
    level.is_voting = false;
    if ( !fileExists( "map_voting.cfg" ) )
    {
        iPrintLn( "map_voting.cfg not found, aborting vote..." );
        return;
    }
    
    maps = [];
    
    config = strTok( fileRead( "map_voting.cfg" ), "\n" );
    if ( config.size < CONST_MAP_VOTE_SIZE )
    {
        iPrintLn( "Not enough maps specified in map_voting.cfg, aborting vote..." );
        return;
    }

    for ( i = 0; i < CONST_MAP_VOTE_SIZE; i++ )
    {
        potential_map = config[ randomInt( config.size ) ];
        config[ config.size ] -= potential_map;
        maps[ maps.size ] = potential_map;
        makeDvarServerInfo( "map_vote_name_" + i, potential_map );
        makeDvarServerInfo( "map_vote_count_" + i, 0 );
    }

    level thread monitor_intermission();
}

monitor_intermission()
{
    level waittill( "spawning_intermission" );
    level.is_voting = true;

    foreach ( player in level.players )
    {
        if ( player isBot() )
            kick( player getEntityNumber() );

        player.vote_id = undefined;
        player thread monitor_disconnect();
        player openPopupMenu( "map_voting" );
    }
}

monitor_disconnect()
{
    self waittill( "disconnect" );

    if ( isDefined( self.vote_id ) )
        makeDvarServerInfo( "map_vote_count_" + self.vote_id, getDvarInt( "map_vote_count_" + self.vote_id ) - 1 );
}

cast_map_vote( idx )
{
    if ( !level.is_voting )
        return;

    if ( isDefined( self.vote_id ) && idx == self.vote_id )
        return;

    if ( idx > CONST_MAP_VOTE_SIZE || idx < 0 )
        return;

    makeDvarServerInfo( "map_vote_count_" + self.vote_id, getDvarInt( "map_vote_count_" + self.vote_id ) - 1 );
    makeDvarServerInfo( "map_vote_count_" + idx, getDvarInt( "map_vote_count_" + idx ) + 1 );

    self.vote_id = idx;
}