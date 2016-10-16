#!/usr/bin/env bash
filename=$(basename "$1");
extension="${filename##*.}";
filename="${filename%.*}";
pretty_separator="-----------------------------------------------------------------------";


if [[ -z "$1" ]]; then
    echo "Usage: ./anto_script.sh video_file [framerate=25]"
    exit;
fi
if [[ -z "$2" ]]; then
    frame_rate=25;
else
    frame_rate=$2;
fi

echo $pretty_separator;
image_dir="images_$filename";
if [ -d "$image_dir" ]; then
    echo "Directory $image_dir already exists";
    read -p "Delete directory and continue Y/n? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # do dangerous stuff
        rm -rf $image_dir;
    else
        echo "remove and run this again ";
        exit;
    fi
fi
echo "creating $image_dir";
mkdir $image_dir;

echo "running ffmpeg on $filename storing images in $image_dir, modify script to change framerate, default $frame_rate";
echo $pretty_separator;

ffmpeg -i $1 -r $frame_rate -f image2 $image_dir/image_%08d.bmp;

echo $pretty_separator;

ls -d -1 $PWD/$image_dir/*.bmp  > $image_dir/filenames.txt;
echo "calling calc_luminance.py on the images, saved at $image_dir/luminance_values";
python calc_luminance.py $image_dir/filenames.txt > $image_dir/luminance_values.repr ;

echo $pretty_separator;

echo "Creating graph and saving in $image_dir/luminance_values.repr.bmp";
python plotter.py $image_dir/luminance_values.repr ;
# eog $image_dir/luminance_values.repr.bmp;
echo "done";
