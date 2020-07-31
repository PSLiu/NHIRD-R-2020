### setting ----

# library
library(data.table)
library(fst)
library(readr)
library(fastDummies)

# prepare ATC CODE & DRUG_NO
dmdrugs <- as.data.table(read_csv("all_drug_no.csv"))
dmdrugs <- dmdrugs[grepl("^A10", atc_code)]
dmdrugs <- unique(dmdrugs$drug_no)



### target ----

# patients prescribed DM medication at least 7 days dose in Janurary

# OPD
cd01 <- read_fst("./fst/h_nhi_opdte10301_10.fst", as.data.table = T)
oo01 <- read_fst("./fst/h_nhi_opdto10301_10.fst", as.data.table = T)

# pharmacy
gd01 <- read_fst("./fst/h_nhi_druge10301.fst", as.data.table = T)
go01 <- read_fst("./fst/h_nhi_drugo10301.fst", as.data.table = T)

# join table
dm01.op <- cd01[oo01, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]
dm01.rx <- gd01[go01, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]

rm(cd01, oo01, gd01, go01)

# including sample
dm01.op <- dm01.op[(drug_no %in% dmdrugs) & (drug_day >= 7)][, .(id)]
dm01.rx <- dm01.rx[(drug_no %in% dmdrugs) & (drug_day >= 7)][, .(id)]

# bind all rows of id
dm01.id <- rbind(dm01.op, dm01.rx)

# unique ID
dm01 <- unique(dm01.id[, .(id)])
write_fst(dm01, "dm01.fst")

# clear environment
rm(dm01.op, dm01.rx, dm01.id, dm01)



### include & exclude ----

# baseline characterise uning  insurance files
dm02 <- read_fst("dm01.fst", as.data.table = T)

# import insurance files
ins <- read_fst("./fst/h_nhi_enrol10301.fst", as.data.table = T)

# keep id, sex, year of birth, then inner join with patients ID
dm02 <- ins[, .(id, id_s, id_birth_y)][dm02, on = .(id), nomatch = 0]
rm(ins)

# check code
table(dm02$id_s)
nrow(dm02) # before
dm02 <- dm02[id_s %in% c("1", "2")]
nrow(dm02) # after

# check age, keep older then 20 yrs
summary(2014 - as.numeric(dm02$id_birth_y))
nrow(dm02)
dm02 <- dm02[(2014 - as.numeric(dm02$id_birth_y)) >= 20]
nrow(dm02)

# recode
dm02 <- dm02[, male := 0][id_s == "1", male := 1]
dm02 <- dm02[, age := 2014 - as.numeric(id_birth_y)]
dm02 <- dm02[, agegp := 1][age >= 40, agegp := 2][age >= 65, agegp := 3]

# make dummy variable
dummy_cols(dm02, select_columns = "agegp")

# check group
table(dm02$male)

summary(dm02$age)
table(dm02$agegp)
table(dm02$agegp_1)
table(dm02$agegp_2)
table(dm02$agegp_3)

# write out
write_fst(dm02, "dm02.fst")
rm(dm02)



### delete some patients died in 2014 using death registry

dm03 <- read_fst("dm02.fst", as.data.table = T)
death <- read_fst("./fst/h_ost_death103.fst", as.data.table = T)

nrow(dm03)
dm03 <- dm03[!death, on = .(id)] # anti-join using ! symbol
nrow(dm03)

# write out
write_fst(dm03, "dm03.fst")
rm(dm03, death)



### DM MPR ----

dm04 <- read_fst("dm03.fst", as.data.table = T)

# prepare for import files
dm04_1a <- list.files("./fst", "(h_nhi_opdte103(0[2-9]|1[0-2])_10|h_nhi_druge103(0[2-9]|1[0-2])).fst") # cd
dm04_1b <- list.files("./fst", "(h_nhi_opdto103(0[2-9]|1[0-2])_10|h_nhi_drugo103(0[2-9]|1[0-2])).fst") # oo
dm04_1 <- vector(mode = "list", length = length(dm04_1a)) # container

# find DM patients(using principle diagnosis)
for (i in 1:length(dm04_1)) {
  
  # import data
  df1 <- read_fst(paste0("./fst/", dm04_1a[i]), as.data.table = T)
  df2 <- read_fst(paste0("./fst/", dm04_1b[i]), as.data.table = T)
  
  # find target patients in CD & GD
  dm04_1[[i]] <- df1[
    # select out target's record
    dm04[, .(id)], on = .(id)][
      # join OO & GO
      df2, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0][
        # keep variable need
        , .(id, func_date, fee_ym, drug_no, drug_day)][
          # keep drug_no no in list of DM drugs
          drug_no %in% dmdrugs]
  # log
  rm(df1, df2)
  print(paste("complete", i))
}
rm(i)

# bind by row
dm04_1 <- rbindlist(dm04_1)
dm04_1 <- dm04_1[order(id, func_date, fee_ym, drug_no, drug_day)]
head(dm04_1)

# aggregate different visit using max dose by id, func_date, fee_ym
dm04_2 <- dm04_1[, .(drug_day_max = max(drug_day)), keyby = .(id, func_date, fee_ym)]
summary(dm04_2$drug_day_max)

# summary dose by id
dm04_3 <- dm04_2[, .(drug_day_sum = sum(drug_day_max)), keyby = .(id)]
summary(dm04_3$drug_day_sum)

# join to target sample with other variables
dm04_4 <- dm04_3[dm04, on = .(id)]
summary(dm04_4$drug_day_sum)

# replace NA(no perscribe drug in observation period) to 0
dm04_4 <- dm04_4[is.na(drug_day_sum), drug_day_sum := 0]
summary(dm04_4$drug_day_sum)

# calculate MPR from Feb. to Dec.
dm04_4 <- dm04_4[, mpr := (drug_day_sum / (365 - 31))][mpr > 1, mpr := 1]
summary(dm04_4$mpr)

dm04_4 <- dm04_4[, mpr80 := 0][mpr >= 0.8, mpr80 := 1]
table(dm04_4$mpr80)

# write out
write_fst(dm04_4, "dm04.fst")
rm(list = ls(pattern = "^dm04"))



### logistic regression ----
dmpt_final <- read_fst("dm04.fst", as.data.table = T)
model <- glm(mpr80 ~ male + agegp_2 + agegp_3,
             data = dmpt_final,
             family = binomial(link = "logit"))

table(dmpt_final$mpr80, dmpt_final$male)
table(dmpt_final$mpr80, dmpt_final$agegp)

summary(model)
exp(cbind(OR = coef(model), confint(model)))

# - - - #
#  END  #
# - - - #