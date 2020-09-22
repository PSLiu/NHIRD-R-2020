### library
library(fst)
library(data.table)
library(readr)
library(VennDiagram)





### ICU(莊立良) ----

# 匯入住院費用檔及醫令檔
icu_1_dd2014 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_ipdte103.fst", as.data.table = T)
icu_1_do201401 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_ipdto10301.fst", as.data.table = T)

# 依據資料庫說明手冊，診療科別「AJ」是「胸腔暨重症加護」
icu_2_a1 <- icu_1_dd2014[func_type == "AJ", ]
nrow(icu_2_a1)
icu_2_a2 <- unique(icu_2_a1[, .(id)])
nrow(icu_2_a2)

# 參考Sung et al(2016)的ICU健保代碼，先將住院費用檔與醫令檔連結(inner join)，依據order_code將申報ICU照護相關健保代碼的觀察值留下
orders <- c("02011K", "02012A", "02013B", "03010E", "03011F", "03012G", "03017A", "03041A", "03041A", "03047E", "03048F", "03049G", "05151B", "05152B", "P6301B")
icu_2_b1 <- icu_1_dd2014[icu_1_do201401, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]
icu_2_b2 <- icu_2_b1[order_code %in% orders, ]
icu_2_b3 <- unique(icu_2_b2[, .(id)])
nrow(icu_2_b3)

# venn diagram
venn.diagram(
  x = list(icu_2_a2$id, icu_2_b3$id),
  category.names = c("科別" , "醫令"),
  filename = 'ICU_Identify.png'
)

# 看起來應該是醫令檔的條件篩選起來的比較符合
# 依病人ID、醫院ID、科別，保留不重複的值
icu_3 <- unique(icu_2_b2[, .(id, in_date, hosp_id, func_type)])

# 分析
(icu_3t <- table(icu_3$func_type))
icu_3t <- sort(icu_3t, decreasing = T)
barplot(icu_3t)

# clear
rm(list = ls())

# 初探：從資料庫手冊可以看出，在曾經有ICU相關照護申報的住院紀錄當中，以神經外科(07)、心臟血管內科(AB)、胸腔內科(AC)為最多
# 後續：那其他月份呢? 如何進行資料的萃取? 可以運用迴圈來提升效率嗎? 要用什麼統計方法去比較?

# Sung et al(2016). Validity of a stroke severity index for administrative claims data research: a retrospective cohort study. BMC Health Services Research. 16:509 





### 腦中風合併吞嚥困難(余佳倫) ----

# 匯入住院費用檔及醫令檔
stroke_1_dd2014 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_ipdte103.fst", as.data.table = T)
stroke_1_do201409 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_ipdto10303.fst", as.data.table = T)

# 從費用檔的診斷碼欄位挑出中風的病患，這裡使用廣義的430.xx-438.xx，在5個診斷碼欄位裡面出現都算
stroke_2 <- stroke_1_dd2014[grepl("^43[0-8]", icd9cm_1)|grepl("^43[0-8]", icd9cm_2)|grepl("^43[0-8]", icd9cm_3)|grepl("^43[0-8]", icd9cm_4)|grepl("^43[0-8]", icd9cm_5)]

# 依據這些病患的6個欄位，合併中風患者在9月的住院醫令檔，透過醫令欄位辨識，是否有on NG tube，代表患者去有吞嚥功能困難(參考宋2018)
stroke_3 <- stroke_2[stroke_1_do201409, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]
stroke_4 <- stroke_3[, NG := 0][order_code %in% c("47017C", "47018C", "47018CA"), NG := 1] # NG coeds

# 依據患者ID、住院日期、醫院ID進行歸人，並加上一個NG的欄位，代表住院期間的申報是否包含NG tubes
stroke_5 <- stroke_4[, .(NG = max(NG)), .(id, in_date, hosp_id)]

# 分析
barplot(table(stroke_5$NG))

# clear
rm(list = ls())

# 初探：先抓出中風住院期間有on NG的病人，進一步探討
# 後續：on NG是否足以代表吞嚥功能困難? 又如何驗證「恢復吞嚥功能」?

# 宋昇峰(2018). 如何由健保申報資料估計中風嚴重度. 台灣腦中風學會. https://www.stroke.org.tw/GoWeb2/include/index.php?Page=5-1&paper02=17532831135bc04ef76a387
# Sung et al. Validity of a stroke severity index for administrative claims data research: a retrospective cohort study. BMC Health Services Research (2016) 16:509 





### DM中醫(楊招瑛) ----

# 匯入門診費用及醫令檔
dm_1_cd201401 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdte10305_10.fst", as.data.table = T)
dm_1_oo201401 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdto10305_10.fst", as.data.table = T)

# 合併
dm_1 <- dm_1_cd201401[dm_1_oo201401, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]

# 將健保用藥清單匯入，找出ATC code為A10開頭的糖尿病用藥，去除不必要的重複，留下糖尿病用藥的健保代碼
dm_1_drugs <- as.data.table(read_csv("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/all_drug_no.csv"))
dm_1_drugs <- dm_1_drugs[grepl("^A10", atc_code)]
dm_1_drugs <- unique(dm_1_drugs[, .(drug_no)])

# 將門診紀錄當中，依據DRUG_NO欄位，inner join糖尿病用藥，留下相關的門診紀錄，並依據病人的ID歸人
dm_2 <- dm_1[dm_1_drugs, on = .(drug_no), nomatch = 0]
dm_3 <- unique(dm_2[, .(id)])

# 是否有使用中醫? 匯入門診中醫紀錄，中醫的檔案名稱結果是_30，並依據ID進行歸人
cm_1_cd201401 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdte10303_30.fst", as.data.table = T)
cm_1_oo201401 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdto10303_30.fst", as.data.table = T)
cm_1 <- cm_1_cd201401[cm_1_oo201401, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]
cm_2 <- unique(cm_1[, .(id)])
cm_3 <- cm_2[, `:=`(ChineMed = 1)]

# 將中醫紀錄當中，屬於我們糖尿病人的保留下來
dm_4 <- cm_3[dm_3, on = .(id)]
dm_5 <- dm_4[is.na(ChineMed ), `:=`(ChineMed = 0)]

# 分析
pie(table(dm_5$ChineMed), labels = c("無", "有"), main = "糖尿病人使用中醫狀況")