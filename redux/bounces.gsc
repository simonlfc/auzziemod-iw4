#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.bouncePos = [];
	level.bounceRadius = [];
	level.lastBounce = [];
	level.lastBounceTime = [];

	level.jumpHeight = getDvarFloat( "jump_height" );

	addBounce( ( -1343.02, 1008.54, -4.00832 ), "mp_nuked" );
	addBounce( ( -202.84, 145.365, 36.5384 ), "mp_nuked" );

	thread runBounces();
}

// bounceRadius = Radius in which you have to be for the bounce to activate. default = 80
// bounceMultiplier = By what your velocity multiplied by, the more; the higher you bounce. default = 1.05
// bounceRadius and bounceMultiplier will be default if value passed is 0.

addBounce( coords, mapname, bounceRadius, bounceMultiplier )
{
	if ( level.script == mapname )
	{
		num = level.bouncePos.size;
		level.bouncePos[num] = coords;

		if ( isDefined( bounceRadius ) )
			level.bounceRadius[num] = bounceRadius;

		if ( isDefined( bounceMultiplier ) )
			level.bounceMultiplier[num] = bounceMultiplier;
	}
}

runBounces()
{
	level endon( "game_ended" );
	level waittill( "prematch_over" );

	for ( ;; )
	{
		foreach ( player in level.players )
		{
			num = player getEntityNumber();

			if ( !isAlive( player ) )
				continue;

			if ( player isOnGround() || player isOnLadder() )
				continue;

			v = player getVelocity();

			if ( v[2] > 0 )
				continue;

			for ( bIndex = 0; bIndex < level.bouncePos.size; bIndex++ )
			{
				if ( !isDefined( level.bouncePos[bIndex] ) )
					continue;

				if ( isDefined( level.lastBounceTime[num] ) && isDefined( level.lastBounce[num] ) && level.lastBounce[num] == bIndex + 1 && getTime() - level.lastBounceTime[num] < 5000 )
					continue;

				radius = level.bounceRadius[bIndex];

				if ( !radius )
					radius = 80;

				if ( distance( player.origin, level.bouncePos[bIndex] ) > radius )
					continue;

				if ( player.origin[2] - level.bouncePos[bIndex][2] <= level.jumpHeight + 1 )
					continue;

				level.lastBounce[num] = bIndex+1;
				level.lastBounceTime[num] = getTime();

				bMultiplier = level.bounceMultiplier[bIndex];

				if ( !bMultiplier )
					bMultiplier = 1.05;

				player setVelocity( ( v[0], v[1], v[2] * -1 * bMultiplier ) );
			}
		}

		waitframe();
	}
}