include("liomutils.jl");
local_datadir="/home/flesage/data/ioi/Y1/Fluo_100ul";
server="132.207.157.14";
server_datadir="Cong/YoungMice/Y1/IOI_Y1/Fluo_100ul";
get_data_from_server(server,server_datadir,local_datadir);

include("ioi.jl");

vessels=show_preview(local_datadir,1)