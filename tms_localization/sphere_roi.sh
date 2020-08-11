#!/bin/bash

# usage: $0 atlas roi_csv size
# atlas: is the standard atlas, i.e. "MNI152_T1_2mm_brain.nii.gz"
# roi_csv: CSV file with the list of names and respective coordinates in voxel in fsl format (no header).
# to convert from mni to voxel you can use the mni2vox.sh script in this same folder.
# size: sphere size in mm
## example csv file: 
### sub-002,110,86,71
## example use: sphere_roi.sh MNI152_T1_2mm_brain.nii.gz rois.csv 3

cone_roi() {
  # Create cone shaped ROI for TMS FC

  # Create point in specific location
  fslmaths ${FSLDIR}/data/standard/${atlas} -mul 0 -add 1 -roi ${coords} point;

  # Create sphere.
  fslmaths point -kernel sphere ${size} -fmean -bin ${name} -odt float;
  
  # Remove preliminary files
  rm point*
  
  echo "cone_roi_${name} is finished"
}

atlas=$1;
roi_csv=$2;
size=$3;

while IFS="," read name xmin ymin zmin; do 
  coords="$xmin 1 $ymin 1 $zmin 1 0 1"
  echo "Cone ROI: ${name}; Coordinates: $coords"
  cone_roi
done < $roi_csv
