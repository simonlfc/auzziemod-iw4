init()
{
    makeDvarServerInfo( "auzziemod_version", 1 );

    thread redux\hooks::hooks();
    thread redux\common::init();
    thread thirdparty\bot_warfare\_bot::init();
    thread redux\bounces::init();
}