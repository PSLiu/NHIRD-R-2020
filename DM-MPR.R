### 工作環境配置 ----

# install
need <- c("data.table", "fst", "readr", "fastDummies", "gmodels", "pROC", "ggplot2")
for (i in 1:length(need)) {
  install.packages(need[i])
}

# library
library(data.table)
library(fst)
library(readr)
library(fastDummies)
library(gmodels)
library(pROC)
library(ggplot2)



### 糖尿病藥物 ----

# 前置糖尿病藥物ATC CODE(篩選指定藥物) & DRUG_NO(連結健保檔)
dmdrugs <- as.data.table(read_csv("all_drug_no.csv"))

# 請R列出檔案的大小(在記憶體中所佔的空間)
format(object.size(dmdrugs), "Mb")

dmdrugs <- dmdrugs[grepl("^A10", atc_code)]
dmdrugs <- unique(dmdrugs[, .(drug_no)])

# 由此可見檔案的容量與記憶體管理之重要性
format(object.size(dmdrugs), "Mb")



### 目標樣本 ----

# 在2014年1月被開立糖尿病藥物至少28天的病人

# 門診檔
cd01 <- read_fst("./fst/h_nhi_opdte10301_10.fst", as.data.table = T)
oo01 <- read_fst("./fst/h_nhi_opdto10301_10.fst", as.data.table = T)

# 藥局檔
gd01 <- read_fst("./fst/h_nhi_druge10301.fst", as.data.table = T)
go01 <- read_fst("./fst/h_nhi_drugo10301.fst", as.data.table = T)

# 連結費用檔(具有用藥天數)及醫令檔(具有藥品代碼drug_no)，保留糖尿病用藥的申報紀錄
dm01.op <- cd01[
  # cd串oo
  oo01, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0][
    # 再串一次用藥
    dmdrugs, on = .(drug_no), nomatch= 0]

dm01.rx <- gd01[
  # gd串go
  go01, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0][
    # 再串一次用藥
    dmdrugs, on = .(drug_no), nomatch= 0]

# 清除不必要的檔案
rm(cd01, oo01, gd01, go01)

# 將門診及藥局檔中符合糖尿病藥物代碼的紀錄垂直合併，並保留用藥天數和相關要歸戶的欄位
dm01 <- rbind(dm01.op[, .(id, func_date, hosp_id, prsn_id, drug_day)], 
              dm01.rx[, .(id, func_date, hosp_id = r_hosp_id, prsn_id, drug_day)])
nrow(dm01) # 歸戶前是12,481筆資料(申報醫令量)

# 先將1月的用藥歸戶，避免重複計算
dm01 <- dm01[, .(drug_day = max(drug_day)), by = .(id, func_date, hosp_id, prsn_id)]
nrow(dm01) # 歸戶後是6,013筆資料(申報費用量)



# 檢視用藥天數的分布狀況
summary(dm01$drug_day)
hist(dm01$drug_day, breaks = seq(0, 90, 10), main = "門診開立糖尿病藥物之用藥天數分布")

# 加總1月每人的用藥天數，保留用藥天數大於等於28天樣本的id欄位
dm01 <- dm01[, .(JanSum = sum(drug_day)), by = .(id)][JanSum >= 28, .(id)]

# 將處理好的檔案寫到硬碟成為fst檔
write_fst(dm01, "dm01.fst")

# 清除檔案
rm(dm01.op, dm01.rx, dm01)



### 納入與排除條件 ----

### 使用承保檔連結個人基本特性資料
dm02 <- read_fst("dm01.fst", as.data.table = T)

# 匯入承保檔
ins <- read_fst("./fst/h_nhi_enrol10301.fst", as.data.table = T)

# 保留年齡、性別、投保金額的資料，與目標樣本人進行串聯取交集
dm02 <- ins[, .(id, id_s, id_birth_y, id1_amt)][dm02, on = .(id), nomatch = 0]
rm(ins)

# 確認承保檔資料的正確性

# 性別，只保留性別是1(男性)、2(女性)的樣本
table(dm02$id_s)
nrow(dm02)
dm02 <- dm02[id_s %in% c("1", "2")]
nrow(dm02)

# 年齡，只保留大於等於20歲的樣本(符合IRB標準))
summary(2014 - as.numeric(dm02$id_birth_y))
nrow(dm02)
dm02 <- dm02[(2014 - as.numeric(dm02$id_birth_y)) >= 20]
nrow(dm02)

# 投保金額
summary(dm02$id1_amt)

# 重新編碼成有意義的變項
dm02 <- dm02[, male := 0][id_s == "1", male := 1]
dm02 <- dm02[, age := 2014 - as.numeric(id_birth_y)]
dm02 <- dm02[, agegp := 1][age >= 40, agegp := 2][age >= 65, agegp := 3]
dm02 <- dm02[, insgp := 1][id1_amt >= 15840, insgp := 2][id1_amt >= 35000, insgp := 3]

# 建立虛擬變項(dummy variable)
dm02 <- dummy_cols(dm02, select_columns = c("agegp", "insgp"))

# 檢查分組變項
table(dm02$male)

summary(dm02$age)
table(dm02$agegp)
table(dm02$agegp_1)
table(dm02$agegp_2)
table(dm02$agegp_3)

table(dm02$insgp)
table(dm02$insgp_1)
table(dm02$insgp_2)
table(dm02$insgp_3)

# 將處理好的檔案寫到硬碟成為fst檔
write_fst(dm02, "dm02.fst")
rm(dm02)



### 連結死亡檔，排除在2014當年死亡的個案

dm03 <- read_fst("dm02.fst", as.data.table = T)
death <- read_fst("./fst/h_ost_death103.fst", as.data.table = T)

nrow(dm03)
dm03 <- dm03[!death, on = .(id)] # 反連結(anti-join)，使用驚嘆號(!)表示左邊id「不等於」右邊id的
nrow(dm03)

# 將處理好的檔案寫到硬碟成為fst檔
write_fst(dm03, "dm03.fst")
rm(dm03, death)



### DM MPR 藥物遵從性 ----

dm04_id <- read_fst("dm03.fst", as.data.table = T)
dm04_id <- dm04_id[, .(id)]

# 使用正規表達式將接下來要匯入的檔案清單整理出來
dm04_1a <- list.files("./fst", "(h_nhi_opdte103(0[2-9]|1[0-2])_10|h_nhi_druge103(0[2-9]|1[0-2])).fst") # cd
dm04_1b <- list.files("./fst", "(h_nhi_opdto103(0[2-9]|1[0-2])_10|h_nhi_drugo103(0[2-9]|1[0-2])).fst") # oo
dm04_1 <- vector(mode = "list", length = length(dm04_1a)) # container

# 找出目標樣本在2014年2-12月的門診、藥局用藥紀錄當中，有使用糖尿病藥物的紀錄
for (i in 1:length(dm04_1)) {
  
  # 匯入
  df1 <- read_fst(paste0("./fst/", dm04_1a[i]), as.data.table = T)
  df2 <- read_fst(paste0("./fst/", dm04_1b[i]), as.data.table = T)
  
  # 整理資料
  
  # 將費用檔right-join to 目標樣本ID縮減檔案大小
  temp <- df1[dm04_id, on = .(id), nomatch = 0] 
  
  # 合併醫令檔
  temp <- temp[df2, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]
  
  # 保留糖尿病用藥的用藥紀錄
  temp <- temp[dmdrugs, on = .(drug_no), nomatch= 0] 
  
  # 保留需要的變項來縮減檔案大小
  if (grepl("opdte", dm04_1a[i])) {
    temp <- temp[, .(id, func_date, prsn_id, drug_day, fee_ym, hosp_id, case_type, appl_type, appl_date, seq_no)]
  } else if (grepl("druge", dm04_1a[i])) {
    temp <- temp[, .(id, func_date, prsn_id, drug_day, fee_ym, hosp_id = r_hosp_id, case_type, appl_type, appl_date, seq_no)]
  }
  
  # 將處理好的物件放入清單當中
  dm04_1[[i]] <- temp
  
  # log
  rm(df1, df2)
  print(paste("complete", i))
}
rm(i, temp)

# 將清單進行垂直合併(RowBindList)
dm04_1 <- rbindlist(dm04_1)
summary(dm04_1$drug_day)

# 先將用藥依據申報欄位進行歸戶
dm04_2 <- dm04_1[, .(drug_day = max(drug_day)), keyby = .(id, hosp_id, prsn_id, func_date, fee_ym, case_type, appl_type, appl_date, seq_no)]
summary(dm04_2$drug_day)

# 排除補報的
dm04_3 <- dm04_2[appl_type != "2"]

# 依據病人ID, 醫院ID, 就診日期, 處方醫師，將連續進行處方歸納
dm04_4 <- dm04_3[, .(drug_day = sum(drug_day)), keyby = .(id, hosp_id, func_date, prsn_id)]
summary(dm04_4$drug_day)

# 將已經歸納的一人多筆資料，再加總整年的用藥天數，歸納為一人一筆
dm04_5 <- dm04_4[, .(drug_day = sum(drug_day)), by = .(id)]
summary(dm04_5$drug_day)
hist(dm04_5$drug_day)

# 計算2-12月的MPR，如果MPR > 100%，則取代為100%
dm04_6 <- dm04_5[, `:=`(mpr = drug_day / (365 - 31))][mpr > 1, `:=`(mpr = 1)]
summary(dm04_6$mpr)

# 先建立(更新)一個變項叫做mpr90，預設值為0，若MPR大於等於90的則更新mpr90為1
dm04_7 <- dm04_6[, `:=`(mpr90 = 0)][mpr >= 0.9, `:=`(mpr90 = 1)]
table(dm04_7$mpr90)

# write out
write_fst(dm04_7, "dm04.fst")
rm(list = ls(pattern = "^dm04"))
rm(dmdrugs)



### merge ----
dm03 <- read_fst("dm03.fst", as.data.table = T) # 包含baseline資料
dm04 <- read_fst("dm04.fst", as.data.table = T) # 包含MPR資訊

dm05 <- dm04[dm03, on = .(id)]
dm05 <- dm05[is.na(drug_day), `:=`(drug_day = 0, mpr = 0, mpr90 = 0)] # 沒有用藥的，將其用藥天數、MPR及MPR超過90的變項設定為0

# write out
write_fst(dm05, "dm05.fst")
rm(list = ls(pattern = "^dm"))


### logistic regression ----
dmpt_final <- read_fst("dm05.fst", as.data.table = T) # 讀取最後合併好，可以直接分析的資料

# preview
CrossTable(dmpt_final$mpr90, dmpt_final$male, prop.r = F, prop.c = T, prop.t = F, prop.chisq = F)
CrossTable(dmpt_final$mpr90, dmpt_final$agegp, prop.r = F, prop.c = T, prop.t = F, prop.chisq = F)
CrossTable(dmpt_final$mpr90, dmpt_final$insgp, prop.r = F, prop.c = T, prop.t = F, prop.chisq = F)

# model
model <- glm(mpr90 ~ male + agegp_2 + agegp_3 + insgp_2 + insgp_3,
             data = dmpt_final,
             family = binomial(link = "logit"))

# report
summary(model)
exp(cbind(OR = coef(model), confint(model)))



### ROC Curves ----
dmpt_final$PredictValue <- predict(model, type = c("response"))
g <- roc(mpr90 ~ PredictValue, data = dmpt_final)

plot(g)
text(0.2, 0.2, paste0("AUROC = ", round(g$auc, 2)))



### PROJECT END ###