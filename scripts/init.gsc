init()
{
    thread redux\hooks::hooks();
    thread redux\common::init();
	thread maps\mp\bots\_bot::init();
    thread redux\bounces::init();
}