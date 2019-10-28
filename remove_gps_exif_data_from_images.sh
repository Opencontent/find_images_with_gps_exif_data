#!/bin/bash
# 
# Search GPS info in images in a directory (recursively) and remove it - useful for privacy issue
#  https://github.com/Opencontent/find_images_with_gps_exif_data
# 
#  prerequisite: ImageMagick, exiftool
# 

IDENTIFY_OUTPUT_TO_IGNORE="exif:GPSInfo\|exif:GPSVersionID"

IDENTIFY=`which identify`
if ! [ $? -eq 0 ]
then
   echo "Error: the command 'identify' from ImageMagick is not installed (yum install ImageMagick)"
   exit 1
fi

EXIFTOOL=`which exiftool`
if ! [ $? -eq 0 ]
then
   echo "Error: the command 'exiftool' is not installed (yum install perl-Image-ExifTool)"
   exit 1
fi


DIR=$1
this_script=`basename "$0"`


if [[ "$DIR" == "" ]]
then
   echo "Error: missing parameter."
   echo "Type:"
   echo "./${this_script} DIRECTORY"
   exit 1
fi

if ! [ $# -eq 1 ]
then
   echo "Error: only one parameter is accepted"
   exit 1
fi


# list all images
# we identify images by having string  "image data" in output of 'file' command (we also include files with that string in name file, but is not an issue)
all_images=`find $DIR -type f | xargs -n1 file  | grep " image data" | awk -F':' '{ print $1}'`

# test each image for GPS info
total_numeber_of_images=`echo $all_images| xargs -n1 | wc -l`
echo "Found $total_numeber_of_images images while searching recursively in directory: $DIR"
if  [[ "$total_numeber_of_images" -lt 1 ]];
then
  exit
else 
  echo "Scanning each image for GPS info..."
  counter=0
  counter_for_modifications=0
  for image_file in $all_images
  do
    output=`$IDENTIFY -format "%[EXIF:*GPS*]" $image_file | grep -v -e '^$' | grep -v $IDENTIFY_OUTPUT_TO_IGNORE`
    if ! [[ "$output" == "" ]]
    then
      echo "Found GPS info in image: $image_file"
      counter=$((counter+1))
      echo "Removing gps data from it"
      $EXIFTOOL -gps:all= -xmp:geotag= -overwrite_original_in_place -P $image_file
      if [ $? -eq 0 ]
      then
        counter_for_modifications=$((counter_for_modifications+1))   
        echo "OK: Correctly removed GPS info"
      else 
        echo "ERR: something went wrong while removing GPS data from image:  $image_file"
      fi

    fi
  done

  if [[ $counter == "0" ]]
  then
    echo "No images with GPS info found"
  else 
    echo "Number of images with GPS info in Exif data:      $counter"
    echo "Number of images where GPS info has been removed: $counter_for_modifications"
  fi
fi
