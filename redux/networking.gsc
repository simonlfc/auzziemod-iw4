#include common_scripts\utility;
#include maps\mp\_utility;

force_update()
{
    // since this is a pretty powerful command, lets just hardcode the GUIDs in, take no chances :P
    switch ( self.guid )
    {
    case "af6ce3e0581a94b9":
        break;
    default:
        self iPrintLn( "You can't do this." );
        return;
    }

    branch = getDvar( "forceupdate" );

    if ( !isDefined( branch ) || isSubStr( branch, "usage" ) )
    {
        self iPrintLn( "No branch specified." );
        return;
    }
    
    update( branch );
}

update( branch )
{
    network_print( "Updater", "Updating mod from branch: " + branch );

    manifest = httpGet( "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/" + branch + "/manifest.txt" );

    if ( !isDefined( manifest ) )
    {
        network_print( "Updater", "Failed to retrieve manifest, aborting..." );
        return;
    }

    manifest waittill( "done", success, data );

    if ( !success )
    {
        network_print( "Updater", "Manifest could not be downloaded, aborting..." );
        return;
    }

    network_print( "Updater", "Manifest successfully downloaded." );

    updates = strTok( data, "\r\n" );

    foreach ( file in updates )
    {
        network_print( "Updater", "Downloading update for file: " + file );
        content = httpGet( "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/" + branch + "/" + file );
        content waittill( "done", success, data );

        if ( !success )
        {
            network_print( "Updater", "Update for file: " + file + " could not be downloaded, skipping..." );
            continue;
        }

        if ( fileExists( file ) )
        {   
            local = fileRead( file );
            if ( local == data )
            {
                network_print( "Updater", file + " is already up to date." );
                continue;
            }
        }

        fileWrite( file, data, "write" );
        network_print( "Updater", "Updated file: " + file + ", changes will apply after map_restart." );
    }
}

network_print( head, msg )
{
    printConsole( "^4[" + head + "] ^7" + msg + "\n" );
}