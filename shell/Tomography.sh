#!/bin/zsh 

#########################################################
# Function  :Tomography             
# Platform  :GMT6.3.0                   
# Version   :2.0                                         
# Date      :2021-04-28                                  
# Author    :wzhang                               
# Contact   :zhangwentaoucas@gmail.com                                
#########################################################

# Get the source directory of this script
SCRIPT_dir=$(cd $(dirname "$0") && pwd)
cd $SCRIPT_dir
logfile="log_clean.log"
TopoGrd=@earth_relief_01m

# ******************Tomography Date****************************
# Tomography date for Belinić et al., 2021 EPSL
# $1: Depth(km); $2: Vp(km/s); $3: Vs(km/s)
# $4: Density(kh/m3); $5: lat(º); $6: lon(º)
# $7: Depth(km), 注意 Depth on the $7, because \n
File_in=~/ownCloud/Data/Tomography/Belinić_et_al_2021EPSL/1-s2.0-S0012821X20306300-mmc1.csv
# awk -F, '{if(NR>1){print $6,$5,$1,$3}}' $File_in | uniq > file_xyzv.tmp
awk -F, '{if(NR>1){print $6,$5,$1,$3}}' $File_in > file_xyzv.tmp
gmt makecpt -Cseismic -T4.3/4.8 > color.cpt
label='Vs(km/s)'
# awk -F, '{if(NR>1){print $6,$5,$1,$2}}' $File_in > file_xyzv.tmp
# gmt makecpt -Cseismic -T7.5/9.0 > color.cpt
# label='Vp(km/s)'

TopoRegion=7/23/39/48
Width=5 # The max width alone the profile

# File_in=model_villasenor_2015.xyzv
# awk -F, '{if(NR>1){print $2,$1,$3,$4}}' $File_in > file_xyzv.tmp
# # gmt info file_xyzv.tmp -T0.1+c3 | gmt makecpt -Chot > color.cpt
# gmt makecpt -Cseismic -T-1.0/1.0 > color.cpt
# label='dVp(%)'
# TopoRegion=-10/5/36/48
# Width=10 # The max width alone the profile

# alias Surface='gmt surface $file_VSlice $R -I2/2 -G$file_grd'

# ******************Profile Date****************************
# Sorthern proflie, zhang et al., 2022
> Info_profile.tmp << EOF
9.85, 40.04, A, -W1p,red
15.00, 40.27, B, -W1p,blue
19.39, 43.55, C, -W1p,black
21.74, 43.48, D, -W1p,cyan
22.87, 44.03, E, -W1p,red
EOF

# # Pyrenees
# > Info_profile.tmp << EOF
# -5.35, 41.2,A, -W1p,red
# -3.09,42.58,B, -W1p,blue
# -1.64,44.64,C, -W1p,black
# EOF


# Temporary files for the script
file_xyzv=file_xyzv.tmp 
file_VSlice=file_VerticalSlice.tmp
file_grd=file_VerticalSlice_grd.tmp
file_topo=file_ProfileTopo.tmp

gmt info file_xyzv.tmp 
# exit
main(){
    
    xyzv2VerticalSlice
    VerticalSlice2Fig
    # rm *.tmp *.cpt
}

# xyzv2VerticalSlice $Input$ $Output$
# xyzv2VerticalSlice file_xyzv.tmp file_VerticalSlice.tmp
# Outpoutfile: 
# $1: Dinstance(km); $2: Depth(km); $3: V(km/s); $4: lat(º); $5: lon(º)

xyzv2VerticalSlice(){

echo "The grd file of Topography:" $TopoGrd
Dis_pro=0
wc Info_profile.tmp | read nrow a b c
echo > $file_VSlice
echo > $file_topo
for i ({2..$nrow}) {
    awk -F, 'NR==i-1 {print "> ",$0}' i=$i Info_profile.tmp >> $file_VSlice | cat
    
    awk -F, 'NR==i-1 {print $1,$2}' i=$i Info_profile.tmp | read PxA PyA
    awk -F, 'NR==i {print $1,$2}' i=$i Info_profile.tmp | read PxB PyB

    # gmt project -C$PxA/$PyA -E$PxB/$PyB -G1 -Q >> $file_VSlice
    gmt project $file_xyzv -C$PxA/$PyA -E$PxB/$PyB -Fxyzpqrs -W-$Width/$Width -Lw -Q | awk '{print $5+D,$3,$4,$1, $2}' D=$Dis_pro >> $file_VSlice

    # *********Topo****************
    awk -F, 'NR==i-1 {print "> ",$0}' i=$i Info_profile.tmp >> $file_topo
    gmt grdcut $TopoGrd -R$TopoRegion -GTopo_grd.tmp
    gmt project -C$PxA/$PyA -E$PxB/$PyB -G1 -Q | awk '{print $1,$2,$3 + D}' D=$Dis_pro | gmt grdtrack -GTopo_grd.tmp  >> $file_topo
    
    awk 'END{print $3}' $file_topo | read Dis_pro # 终点的距离 
}

gmt info  $file_VSlice -C  | read Amin Amax Bmin Bmax
R=-R$Amin/$Amax/50/300
# gmt info  $file_VSlice -I1  | read R
echo $R
gmt surface $file_VSlice $R -I2/2 -G$file_grd
# Surface

}

VerticalSlice2Fig(){

file_in=file_VerticalSlice.tmp 
MaxDepth=400

gmt begin map_all
# gmt set PS_MEDIA A4 # 21cm×29.7cm / 8.3 × 11.7 inch 
# 1 inch=2.54 cm=72 point

WidthNumber=6
WidthUnit=i
Width=$WidthNumber$WidthUnit

    echo '————————Tomography V'
    awk 'END {print $3}' $file_topo | read Xmax
    Jx=$(($WidthNumber*2.54/$Xmax))

    gmt info -i2 -I1 $file_topo | read R
    gmt basemap $R$MaxDepth -Jx$Jx/-$Jx -BWSne -Bxaf+l"Distance along the @;red;profile@;; (km)" -Byafg+l"Depth (km)" -U"'$File_in'"
    
    gmt grdimage $file_grd -Ccolor.cpt
    gmt colorbar -DjMR+w2i/0.2i+o-2c/0c -Ccolor.cpt -By+l"$label" -Bxaf

    # gmt plot $file_in -Ss0.06c -Gblack

    echo '————————Elevation'
    gmt info -i2,3 -I1 $file_topo  | read R
    gmt plot $file_topo -i2,3 $R -JX$Width/1.0i -Wthick,darkred -Ggray -L+y-10000 -BWSne -Bxaf -Byaf+l"Elevation (m)" -Y$(($WidthNumber*$MaxDepth/$Xmax+0.5))i

    echo '————————Topo map'
    gmt makecpt -Cglobe -T-5000/5000/10
    gmt grdimage $TopoGrd -JM$Width -C -R$TopoRegion -Baf -BWSen+t""  -Y1.5i
    
    gmt plot file_xyzv.tmp -Ss0.06c -Gblack
    gmt plot -i3,4 $file_in -Sc0.1c -Ggreen -W1p,green

    # The location of Profile
    # gmt text -N  Info_profile.tmp 
    awk -F, '{print $1,$2,$3,"("$1,$2")" }' Info_profile.tmp | gmt text -F+f10p,3,red -N 
    gmt plot $file_topo -W2p,black 

gmt end


}

# invoke main function
main|tee ${logfile}