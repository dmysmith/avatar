#!/bin/bash
python /space/chen-syn01/1/data/haowang/bin/PRScs/PRScs.py \
  --ref_dir=/space/chen-syn01/1/data/haowang/bin/LD_reference/ldblk_1kg_eur \
  --bim_prefix=/space/syn70/1/data/ABCD/TOPMED_imputed_UKB_intersected_flipped \
  --sst_file=/space/syn50/1/data/ABCD/d9smith/PRScs/haowang/UKB/Cortex/fastGWA/global/UKB_cortex_global_total_surface_area_sumstat.fastGWA.formatted \
  --n_gwas=34692 \
  --out_dir=/space/syn50/1/data/ABCD/d9smith/PRScs/Results/temp/global_total_surface_area

for j in {1..22}; do
  cat /space/syn50/1/data/ABCD/d9smith/PRScs/Results/temp/global_total_surface_area_pst_eff_a1_b0.5_phiauto_chr${j}.txt >> /space/syn50/1/data/ABCD/d9smith/PRScs/Results/temp/global_total_surface_area.score
done

/space/chen-syn01/1/data/haowang/bin/plink1.9/plink \
  --bfile /space/syn70/1/data/ABCD/TOPMED_imputed_UKB_intersected_flipped \
  --score /space/syn50/1/data/ABCD/d9smith/PRScs/Results/temp/global_total_surface_area.score 2 4 6 \
  --out /space/syn50/1/data/ABCD/d9smith/PRScs/Results/global_total_surface_area