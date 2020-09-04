### ~ OHCA & CPR ~ ----

### 問題：今年1月有多少OHCA患者?其中多少人施行了心肺復甦術(CPR)?

### library
library(fst)
library(data.table)
library(gmodels)



### 1.讀取資料 ----

# 讀取2014年1月的西醫門診費用檔opdte(patients' id) → 病人資料
# 讀取2014年1月的西醫門診費用檔opdto(order code) → 醫令資料
ohca_1a <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdte10301_10.fst", as.data.table = T)
ohca_1b <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdto10301_10.fst", as.data.table = T)

# 合併兩者
ohca_2 <- ohca_1a[ohca_1b, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]



# 2.資料整理 ----

# 建立OHCA(ICD-9-CM:798.xx)和CPR(醫令47029C)欄位
ohca_3 <- ohca_2[, `:=`(OHCA = 0)][(grepl("^798", icd9cm_1)|grepl("^798", icd9cm_2)|grepl("^798", icd9cm_3)), `:=`(OHCA = 1)]
ohca_3 <- ohca_3[, `:=`(CPR = 0)][drug_no == "47029C", `:=`(CPR = 1)]

# 先看次數分布
table(ohca_3$OHCA)
table(ohca_3$CPR)

# 整合成看診人次資料
ohca_4 <- ohca_3[, .(OHCA = max(OHCA), CPR = max(CPR)), by = .(id, func_date, hosp_id)]



# 3.資料分析 ----
CrossTable(ohca_4$CPR, ohca_4$OHCA, prop.r = F, prop.c = F, prop.t = F, prop.chisq = F)

# clear
rm(list = ls())





### ~ 重複中風人數 ~ ----

### 問題：有多少人在隔月重複因為中風進入急診?

### library
library(fst)
library(data.table)



### 1.讀取資料 ----

# 讀入fst
sk_1a <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdte10302_10.fst", as.data.table = T)
sk_1b <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdte10303_10.fst", as.data.table = T)

format(object.size(sk_1a), "Mb")
# 檔案   fst大小(MB)  讀進記憶體大小(MB)
# sk_1a  6.3          46.4
# fst只是在儲存時進行壓縮，讀入R之後會解壓縮回原本的大小



### 2.整理資料 ----

# 中風
sk_2a <- sk_1a[(grepl("^43[0-8]", icd9cm_1)|grepl("^43[0-8]", icd9cm_2)|grepl("^43[0-8]", icd9cm_3))]
sk_2b <- sk_1b[(grepl("^43[0-8]", icd9cm_1)|grepl("^43[0-8]", icd9cm_2)|grepl("^43[0-8]", icd9cm_3))]

# 申報類別為西醫急診
sk_3a <- sk_2a[case_type == "02"]
sk_3b <- sk_2b[case_type == "02"]

# 歸人
sk_4a <- unique(sk_3a[, .(id)])
sk_4b <- unique(sk_3b[, .(id)])

# 取交集
sk_5 <- sk_4a[sk_4b, on = .(id), nomatch = 0]



### 3.後續延伸 ----

# 連結承保檔瞭解病人特性
sk_5_ins <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_enrol10301.fst", as.data.table = T)
sk_6 <- sk_5_ins[sk_5, on = .(id), nomatch = 0]

# 建立其他有興趣的變項
sk_7 <- sk_6[, age := 2014 - as.numeric(sk_6$id_birth_y)]

# 檢視
sk_7[, .(id, id_s, age)]

# clear
rm(list = ls())





### ~ 各地感冒盛行率 ~ ----

### 問題：台灣民眾感冒就診人次，在各地是否有差異?

### library
library(fst)
library(data.table)



### 1.感冒就診 ----

# 匯入4月份的門診費用檔
cold_1 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdte10304_10.fst", as.data.table = T)

# 保留需要使用的欄位
cold_2 <- cold_1[, .(id, func_date, hosp_id, city, icd9cm_1, icd9cm_2, icd9cm_3)]

# 將ICD9CM轉置(橫轉直)，方便等一下搜尋ICD欄位
cold_3 <- melt(data = cold_2, id.vars = c("id", "func_date", "hosp_id", "city"), measure.vars = c("icd9cm_1", "icd9cm_2", "icd9cm_3"), variable.name = "order", value.name = "icd")

# 找出感冒的門診紀錄，ICD9-CM：460-466, 480-487(林民浩，2011)
cold_4 <- cold_3[grepl("46[0-6]|48[0-7]", icd)]

# 人數資料：依照病人ID、就診日期、就診醫院、就診醫院地點，保留不重複的唯一值，再取每人的第一次
cold_5 <- unique(cold_4[, .(id, func_date, hosp_id, city)])
cold_5 <- cold_5[order(id, func_date)]
cold_5 <- cold_5[ , .SD[1], by = .(id)]

# 依地區歸人
cold_6 <- cold_5[, .(cold_sum = .N), by = .(city)]



### 2.地區人數 ----

# 匯入1月的承保檔
ins_1 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_enrol10301.fst", as.data.table = T)

# 歸人，看每個地區分別有幾個人
ins_2 <- ins_1[, .(per_sum = .N), by = .(id1_city)]

# 此一方式僅供課堂演練參考，因為投保地未必與居住地相等



### 3.合併資料 ----

# 將地區別感冒紀錄和地區別投保人口數取交集，並且計算感冒盛行率(百分之幾)
fdt_1 <- cold_6[ins_2, on = .(city = id1_city), nomatch = 0]
fdt_2 <- fdt_1[, cold_prevalence := ((cold_sum / per_sum) * 100)]
summary(fdt_2$cold_prevalence)

# 盛行率應當不會 > 100%，應該是許多人投保/依附納保地點被錯誤歸類
# 設定50%為切點，僅保留盛行率小於50%的為可信資料，進行後續分析
fdt_3 <- fdt_2[cold_prevalence < 50]

# 加上健保六分區的欄位 ~ 傳統寫法
fdt_4 <- fdt_3[, nhi_adm := 0]
fdt_4 <- fdt_4[grepl("^01|^31|^11|^34|^90|^91", city), nhi_adm := 1] # 台北業務組
fdt_4 <- fdt_4[grepl("^32|^12|^33|^35", city), nhi_adm := 2]         # 北區業務組
fdt_4 <- fdt_4[grepl("^03|^38|^37", city), nhi_adm := 3]             # 中區業務組
fdt_4 <- fdt_4[grepl("^39|^22|^40|^05", city), nhi_adm := 4]         # 南區業務組
fdt_4 <- fdt_4[grepl("^07|^43|^44", city), nhi_adm := 5]             # 高屏業務組
fdt_4 <- fdt_4[grepl("^46|^45", city), nhi_adm := 6]                 # 東區業務組

# 給定層級和標籤
table(fdt_4$nhi_adm)
fdt_4$nhi_adm <- factor(fdt_4$nhi_adm, 
                        levels = c(1, 2, 3, 4, 5, 6),
                        labels = c("台北", "北區", "中區", "南區", "高屏", "東區"))

# 確認分區結果不能有遺漏或錯誤
table(fdt_4$nhi_adm)



### 4.結果分析 ----

# 計算各分區感冒人數的盛行率平均值、標準差
fdt_4[, 
      .(NumCity = .N, 
        cold_prevalence_mean = mean(cold_prevalence), 
        cold_prevalence_sd = sd(cold_prevalence)), 
      keyby = .(nhi_adm)]

# ANOVA
report <- aov(cold_prevalence ~ nhi_adm, fdt_4)
summary(report)

# 繪圖
boxplot(cold_prevalence ~ nhi_adm, 
        data = fdt_4,
        main = "4月各地感冒盛行率分布狀況",
        xlab = "健保署業務組", 
        ylab = "感冒盛行率(%)")

# clear
rm(list = ls())



### END ###