using FTPClient

function get_data_from_server(server,server_datadir,local_datadir)
    ftp = FTP(hostname=server, username="liom", password="epoxy111");
    cd(ftp,server_datadir);
    img_files=filter(x->startswith(x, "img_"), readdir(ftp));
    ai_files=filter(x->startswith(x, "ai_"), readdir(ftp));
    mkpath(local_datadir);
    for file in img_files
        print("Downloading file: $file \r")
        download(ftp, file, joinpath(local_datadir,file));
    end
    for file in ai_files
        print("Downloading file: $file \r")
        download(ftp, file, joinpath(local_datadir,file));
    end
    file="info.txt"
    download(ftp, file, joinpath(local_datadir,file));
    close(ftp);
end;
