# find_images_with_gps_exif_data.sh

Search GPS info in images in a directory (recursively), and remove GPS data 

Useful for privacy issue, to be sure a storage does not have GPS info saved in image file.

Tested on: Centos 7

Execute:

```
find_images_with_gps_exif_data.sh mydirectory
# to remove gps data
remove_gps_exif_data_from_images.sh mydirectory
```

Requirements:

```
yum install ImageMagick
yum install perl-Image-ExifTool
```
