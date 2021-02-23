using DelimitedFiles
using Glob
using Images
using Statistics
using Plots

struct IOIinfo
    nx :: Int32
    ny :: Int32
end

struct IOIheader
    version :: Int32
    nx :: Int32
    ny :: Int32
    firstImageNo :: Int32
    nimages :: Int32
end

struct IOIImageIterator
    nfiles :: Int32
    nimages_per_file :: Int32
    imagefiles :: Any
    current_stack :: Array
    current_index :: Int32
end


function create_image_iterator(datadir)
    imagefiles=glob("img_*.bin",datadir);
    filename=imagefiles[1];
    imgs=read_image_file(filename);
    mean_img=mean(imgs,dims=3);
    imgs = (imgs.-mean_img) ./mean_img;    
    nfiles=size(imagefiles)[1];  
    image_iterator = IOIImageIterator(nfiles,size(imgs)[3],imagefiles, imgs,1);
    #image_iterator = IOIImageIterator(nfiles,5,imagefiles, imgs,1);
end

function Base.iterate(I::IOIImageIterator, state=1)
    if state == I.nimages_per_file + 1
        return nothing
    end
    f=takemap(scaleminmax, I.current_stack[:,:,state])

    (Gray.(f.(I.current_stack[:,:,state])),state+1)
end

function read_image_file(filename)
    s = open(filename,"r")
    d = Ref{IOIheader}()
    read!(s, d)
    header = d[]
    image_stack=Array{UInt16}(undef,header.nx,header.ny,header.nimages);
    tmp_image=Array{UInt16}(undef,header.nx,header.ny)
    # Read all images in filename
    for i in 1:header.nimages
        skip(s,24)
        read!(s,tmp_image)
        image_stack[:,:,i]=tmp_image;
    end
    close(s)
    return image_stack;
end

function show_preview(datadir, n_files)
    fringefiles=glob("img_*.bin",datadir);
    filename=fringefiles[1];
    imgs=read_image_file(filename);
    img_trace=zeros(Int32,size(imgs)[1],size(imgs)[2])

    nfiles=size(fringefiles)[1];
    for i_file=1:min(nfiles,n_files)
        filename=fringefiles[i_file];
        imgs=read_image_file(filename);
    
        mean_img=mean(imgs,dims=3);
        imgs = (imgs.-mean_img) ./mean_img;    
        #print("Processing file $i_file\r")
#        for i_frame=1:size(imgs)[3]
#            peaks,img_dots=FastPeakFind(imgs[:,:,i_frame])
#            img_trace = img_trace.+img_dots; 
#        end
    end
    vessels=dropdims(std(imgs,dims=3),dims=3);
    plot(Gray.(vessels),axis=nothing)

end

function read_acq_info(datadir)

infofile=glob("info.txt",datadir)[1];

# Read delimited file and transfer to a dictionary to facilitate access

tmp=readdlm(infofile, ':', header=true)
scaninfo = Dict(tmp[1][i,1] => tmp[1][i,2] for i = 1:size(tmp[1])[1])

# At this point we have a dictionary, not ideal for computations so move
# to a struct which will do better type checking

ioi_info = IOIinfo(scaninfo["nx"],
                   scaninfo["ny"])
                   
end;


        