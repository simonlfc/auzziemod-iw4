init()
{
    thread redux\networking::update( "main" );
    thread redux\hooks::hooks();
    thread redux\common::init();
}