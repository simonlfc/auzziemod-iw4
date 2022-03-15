#include common_scripts\utility;
#include maps\mp\_utility;

update()
{
    manifest = httpGet( "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/live/manifest.txt" );
    updater_print( "Downloading manifest..." );

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
        updater_print( "Preparing to update file: " + file );

        if ( fileExists( file ) )
            fileRemove( file );

        content = httpGet( "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/live/" + file );
        updater_print( "Downloading update for file: " + file );

        content waittill( "done", success, data );

        if ( !success )
        {
            updater_print( "Update for file: " + file + " could not be downloaded, skipping..." );
            continue;
        }

        updater_print( "Downloaded update for file: " + file );

        fileWrite( file, data, "write" );
        updater_print( "Updated file: " + file + ", changes will apply after map_restart." );
    }
}

updater_print( msg )
{
    printConsole( "^4Updater: ^7", msg );
}