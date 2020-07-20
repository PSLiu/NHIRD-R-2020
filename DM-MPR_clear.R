library(data.table)
library(fst)
library(readr)
fr <- "C:/Peter/Dropbox/Project/NHIRD/S10M/fst/"
dmdrugs <- read_csv("C:/Peter/Dropbox/Project/Resource/NHI-Drug-Atc-OrderCode/all_drug_no.csv")
dmdrugs <- dmdrugs[grepl("^A10", dmdrugs$atc_code), c("drug_no")]
dmdrugs <- unique(dmdrugs$drug_no)
dmpt_1a <- list.files(fr, "(h_nhi_opdte103(0[1-9]|1[0-2])_10|h_nhi_druge103(0[1-9]|1[0-2])).fst")
dmpt_1b <- list.files(fr, "(h_nhi_opdto103(0[1-9]|1[0-2])_10|h_nhi_drugo103(0[1-9]|1[0-2])).fst")
dmpt_1 <- vector(mode = "list", length = length(dmpt_1a))
for (i in 1:length(dmpt_1)) {
  df1 <- read_fst(paste0(fr, dmpt_1a[i]), as.data.table = T)
  df2 <- read_fst(paste0(fr, dmpt_1b[i]), as.data.table = T)
  dmpt_1[[i]] <- df1[
    df2, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0][
      , .(id, fee_ym, icd9cm_1, drug_no, drug_day)][
        grepl("^250", icd9cm_1)][
          !(drug_no %in% dmdrugs), drug_day := 0]
  print(paste("complete", i))
}
head(dmpt_1[[1]])
rm(dmpt_1a, dmpt_1b, i)
dmpt_1 <- rbindlist(dmpt_1)
dmpt_2 <- dmpt_1[, .(drug_day_max = max(drug_day)), keyby = .(id, fee_ym)]
summary(dmpt_2$drug_day_max)
dmpt_2 <- dmpt_2[, .(drug_day_sum = sum(drug_day_max)), keyby = .(id)]
summary(dmpt_2$drug_day_sum)
dmpt_2 <- dmpt_2[drug_day_sum >= 365, drug_day_sum := 365]
summary(dmpt_2$drug_day_sum)
dmpt_2 <- dmpt_2[, mpr := drug_day_sum/365]
dmpt_2 <- dmpt_2[, mpr80 := 0][mpr >= 0.8, mpr80 := 1]
summary(dmpt_2$mpr)
table(dmpt_2$mpr80)
ins <- read_fst(paste0(fr, "h_nhi_enrol10301.fst"), as.data.table = T)
dmpt_3 <- dmpt_2[ins[, .(id, id_s, id_birth_y)], on = .(id), nomatch = 0]
dmpt_3 <- dmpt_3[, male := 0][id_s == "1", male := 1]
dmpt_3 <- dmpt_3[, a65 := 0][2014 - as.numeric(id_birth_y) >= 65, a65 := 1]
table(dmpt_3$mpr80, dmpt_3$male)
table(dmpt_3$mpr80, dmpt_3$a65)
model <- glm(mpr80 ~ male + a65, data = dmpt_3, family = binomial(link = "logit"))
summary(model)
exp(cbind(OR = coef(model), confint(model)))