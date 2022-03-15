#include common_scripts\utility;
#include maps\mp\_utility;

update( branch )
{
    updater_print( "Updating mod from branch: " + branch );

    manifest = httpGet( "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/" + branch + "/manifest.txt" );

    if ( !isDefined( manifest ) )
    {
        updater_print( "Failed to retrieve manifest, aborting..." );
        return;
    }

    manifest waittill( "done", success, data );

    if ( !success )
    {
        updater_print( "Manifest could not be downloaded, aborting..." );
        return;
    }

    updater_print( "Manifest successfully downloaded." );

    updates = strTok( data, "\r\n" );

    foreach ( file in updates )
    {
        updater_print( "Downloading update for file: " + file );
        content = httpGet( "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/" + branch + "/" + file );
        content waittill( "done", success, data );

        if ( !success )
        {
            updater_print( "Update for file: " + file + " could not be downloaded, skipping..." );
            continue;
        }

        if ( fileExists( file ) )
        {   
            local = fileRead( file );
            if ( local == data )
            {
                updater_print( file + " is already up to date." );
                continue;
            }
        }

        fileWrite( file, data, "write" );
        updater_print( "Updated file: " + file + ", changes will apply after map_restart." );
    }
}

updater_print( msg )
{
    printConsole( "^4[Updater] ^7" + msg + "\r\n" );
}