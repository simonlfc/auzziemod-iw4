init()
{
    thread redux\networking::update( "live" );
    thread redux\hooks::hooks();
    thread redux\common::init();
}