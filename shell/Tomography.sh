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

TopoRegion=7/23/39/48



PxA=9.85
PyA=40.04
PxB=15.00
PyB=40.27
PxC=19.39
PyC=43.55
PxD=21.74
PyD=43.48
PxE=22.87
PyE=44.03

PxA=9.70
PyA=42.32
PxB=21
PyB=47.34

PxA=9.85
PyA=40.04
PxB=22.87
PyB=44.03
Width=5

# Data preprocessing
step1(){

    # Make small Topography grd file 
    gmt grdcut $TopoIn -R$TopoRegion -GTopo_grd.tmp

    # Make Topography file along the profile
    gmt project -C$PxA/$PyA -E$PxB/$PyB -G1 -Q | gmt grdtrack -GTopo_grd.tmp > Topo_profile.tmp

    # uniq: filters out the repeated lines in a file
    awk -F, '{if(NR>1){print $6,$5}}' $File_in | uniq > filexy.tmp

    awk -F, '{if(NR>1){print $6,$5,$1,$3,$2}}' $File_in | gmt project -C$PxA/$PyA -E$PxB/$PyB -Fxyzpqrs -W-$Width/$Width -Lw -Q > filexyD_all.tmp

    # Make Vs grd file
    awk '{print $6,$3,$4}' filexyD_all.tmp > filexDepth_Vx.tmp

    gmt info  filexDepth_Vx.tmp -C  | read Amin Amax Bmin Bmax
    R=-R$Amin/$Amax/50/300

    gmt surface  filexDepth_Vx.tmp $R -I2/2 -GfilexDepth_Vx_grd.tmp


    # Make Vp grd file
    awk '{print $6,$3,$5}' filexyD_all.tmp > filexDepth_Vp.tmp

    gmt info  filexDepth_Vp.tmp -C  | read Amin Amax Bmin Bmax
    R=-R$Amin/$Amax/50/300

    gmt surface  filexDepth_Vp.tmp $R -I2/2 -GfilexDepth_Vp_grd.tmp
}

# Plot the result by GMT6
step2(){

gmt begin map_all
# gmt set PS_MEDIA A4 # 21cm×29.7cm / 8.3 × 11.7 inch 
# 1 inch=2.54 cm=72 point

WidthNumber=6
WidthUnit=i
Width=$WidthNumber$WidthUnit

    echo '————————Tomography Vs'
    awk 'END {print $3}' Topo_profile.tmp | read Xmax
    R=-R0/$Xmax/0/400
    Jx=$(($WidthNumber*2.54/$Xmax))
    
    gmt basemap $R -Jx$Jx/-$Jx -BWSne -Bxaf+l"Distance along the @;red;profile@;; (km)" -Byafg+l"Depth (km)" -U"'$File_in'"
    gmt makecpt -Cseismic -T4.3/4.8 
    gmt grdimage filexDepth_Vx_grd.tmp -C
    gmt colorbar -DjMR+w2i/0.2i+o-2c/0c -C -By+l"Vs (km/s)" -Bxaf
    #gmt plot filexDepth_Vx.tmp -Ss0.05c -Gblack
    
    echo '————————Tomography Vp'   
    gmt basemap $R -Jx$Jx/-$Jx -BWSne -Bxaf+l"Distance along the @;red;profile@;;  (km)" -Byafg+l"Depth (km)" -Y3i
    gmt makecpt -Cseismic -T7.5/9.0
    gmt grdimage filexDepth_Vp_grd.tmp -C
    gmt colorbar -DjMR+w2i/0.2i+o-2c/0c -C -By+l"Vp (km/s)" -Bxaf
    #gmt plot filexDepth_Vx.tmp -Ss0.05c -Gblack

    echo '————————Elevation'
    gmt info -i2,3 -I1 Topo_profile.tmp  | read R
    gmt plot Topo_profile.tmp -i2,3 $R -JX$Width/1i -Wthick,darkred -Ggray -L+y-10000 -BWSne -Bxaf+l"Distance along the @;red;profile@;; (km)" -Byaf+l"Elevation (m)" -Y3i

    echo '————————Topo map'
    gmt makecpt -Cglobe -T-5000/5000/10
    gmt grdimage $TopoIn -JM$Width -C -R$TopoRegion -Baf -BWSen+t""  -Y2i
    
    
    # The location of Profile
    gmt psxy Topo_profile.tmp -W3p,red

    gmt plot filexyD_all.tmp -Sc0.1c -Ggreen
    gmt plot filexy.tmp -Ss0.06c -Gblack

    gmt text -F+f10p,3,black -N  << EOF
$PxA $PyA   A ($PxA $PyA)
$PxB $PyB   B ($PxB $PyB)
EOF


PxA=9.85
PyA=40.04
PxB=15.00
PyB=40.27
PxC=19.39
PyC=43.55
PxD=21.74
PyD=43.48
PxE=22.87
PyE=44.03
    gmt plot -W3p,gray << EOF
$PxA $PyA  
$PxB $PyB  
$PxC $PyC
$PxD $PyD 
$PxE $PyE 
EOF

gmt end


}


main(){
    step1
    step2
}

# invoke main function
main|tee ${logfile}