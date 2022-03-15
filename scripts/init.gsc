init()
{
    thread redux\networking::update( "live" );
    thread redux\common::init();
}