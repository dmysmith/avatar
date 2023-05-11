sst_file = '/space/syn50/1/data/ABCD/d9smith/PRScs/haowang/UKB/Cortex/fastGWA/global/UKB_cortex_global_total_surface_area_sumstat.fastGWA'
outfile = '/space/syn50/1/data/ABCD/d9smith/PRScs/haowang/UKB/Cortex/fastGWA/global/UKB_cortex_global_total_surface_area_sumstat.fastGWA.formatted' 

sst = read.delim(sst_file)
sst = sst[,c('SNP','A1','A2','BETA','P')]
write.table(sst, outfile, sep="\t", row.names = FALSE, quote = FALSE)