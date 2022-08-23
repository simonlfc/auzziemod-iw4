#include common_scripts\utility;
#include maps\mp\_utility;

check_for_updates()
{
    console_print( "Updater", "Checking for updates..." );
    download = httpGet( "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/master/version.txt" );
    download waittill( "done", success, data );
    if ( !success )
    {
        console_print( "Updater", "Failed to check for updates." );
        return;
    }

    remote_version = int( data );

    if ( getDvarInt( "auzziemod_version" ) == remote_version )
        console_print( "Updater", "Up to date." );
    else if ( getDvarInt( "auzziemod_version" ) > remote_version )
        console_print( "Updater", "^3Current version is higher than the latest available version." );
    else if ( getDvarInt( "auzziemod_version" ) < remote_version )
        console_print( "Updater", "^1An update is available, head to github.com/simonlfc/auzziemod-iw4 to download the latest version." );
}

console_print( head, msg )
{
    printConsole( "^6[" + head + "] ^7" + msg + "\n" );
}