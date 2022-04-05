#!/bin/zsh

#########################################################
# Function  :Tomography             
# Platform  :GMT6.3.0                   
# Version   :1.0                                         
# Date      :2021-04-05                                  
# Author    :wzhang                               
# Contact   :zhangwentaoucas@gmail.com                                
#########################################################

# Get the source directory of this script
cd $(cd $(dirname "$0") && pwd)
logfile="log_clean.log"

TopoIn=@earth_relief_04m

# 注意 Depth on the $7, because \n
File_in=~/ownCloud/Data/Tomography/Belinić_et_al_2021EPSL/1-s2.0-S0012821X20306300-mmc1.csv

TopoRegion=5/25/36/50

PxA=9.70
PyA=42.32
PxB=21
PyB=47.34
Width=2

# Data preprocessing
step1(){
    awk -F, '{if(NR>1){print $6,$5,$1,$3}}' $File_in | gmt project -C$PxA/$PyA -E$PxB/$PyB -Fxyz -W-$Width/$Width -Lw -Q > filexyD_Vs.tmp

    gmt info -i0,2 -I0.000001 filexyD_Vs.tmp  | read R
    gmt surface -i0,2,3  filexyD_Vs.tmp $R -I0.01/1 -GfilexyD_Vs_grd.tmp


    # uniq: filters out the repeated lines in a file
    awk -F, '{if(NR>1){print $6,$5}}' $File_in | uniq > filexy.tmp


}

# Plot the result by GMT6
step2(){

gmt grdcut $TopoIn -R$TopoRegion -GTopo_grd.tmp
gmt project -C$PxA/$PyA -E$PxB/$PyB -G1 -Q | gmt grdtrack -GTopo_grd.tmp > Topo_profile.tmp



gmt begin map_all
#gmt set PS_MEDIA A4 # 21cm×29.7cm / 8.3 × 11.7 inch
Width=6i
Length=2i
    echo '————————Tomography'
    awk 'END {print $3}' Topo_profile.tmp | read Xmax
    R=-R$PxA/$PxB/0/400
    gmt basemap $R -JX$Width/-$Length -BWSne -Bxaf+l"longitude along the @;red;profile@;; " -Byafg+l"Depth (km)" -U"'$File_in'"
    gmt makecpt -Cseismic -T4/5.5/0.01
    gmt plot filexyD_Vs.tmp -i0,2 -Ss0.1c -Gred 
    gmt grdimage filexyD_Vs_grd.tmp -C
    gmt colorbar -DjMR+w$Length/0.2i+o-2c/0c -C -By+l"Vs (km/s)" -Bxaf

    echo '————————Elevation'
    gmt info -i2,3 -I1 Topo_profile.tmp  | read R
    gmt plot Topo_profile.tmp -i2,3 $R -JX$Width/1i -Wthick,darkred -Ggray -L+y-10000 -BWSne -Bxaf+l"Distance along the @;red;profile@;; (km)" -Byaf+l"Elevation (m)" -Y3i

    echo '————————Topo map'
    gmt makecpt -Cglobe -T-5000/5000/10
    gmt grdimage $TopoIn -JM$Width -C -R$TopoRegion -Baf -BWseN+t""  -Y2i
    gmt plot filexy.tmp -Ss0.06c -Gblack
    # The location of Profile
    gmt psxy Topo_profile.tmp -W3p,red


    
    


    

gmt end

}


main(){
    step1
    step2
}

# invoke main function
main|tee ${logfile}