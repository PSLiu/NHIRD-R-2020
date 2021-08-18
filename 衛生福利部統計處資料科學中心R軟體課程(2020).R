### ~ 物件(object)類型與應用 ~ ----

# 物件名稱 <- 內容
# "<-"的快捷鍵是 alt + -



### 1.1. 資料框 data.frame ----

# data.frame是最常見的資料及儲存格式
# 可以將「不同類型」但長度相等的向量組合成資料框
# 以「欄位名稱 = 內容」的方式建立，多個向量用逗點隔開
# 和Excel/SAS/STATA相同，以欄、列儲存方式資料
df1 <- data.frame(
  UID = c("A01", "A01", "A02", "A02", "A02", "A03"),
  Visit = c(1, 2, 1, 2, 3, 1),
  sbp = c(118, 117, 116, 119, 120, 130),
  dbp = c(85, 80, 92, 90, 92, 100)
)
class(df1)
View(df1)



### 1.2. 數值型 ----

# 單一數值
a1 <- 3
print(a1)
class(a1)

a2 <- 3.1415
print(a2)
class(a2)

# 使用c()將多個物件組合成一個向量(vector)
# 同一向量當中須為相同類型(class)的元素(element)
# 向量長度(length)為內含元素的數量
a3 <- c(118, 117, 116, 119, 120, 130)
print(a3)
class(a3)
length(a3)

# 使用c()將15, 16, ... 29, 30的數列組合成一個向量
# n:m為快速產生n, n+1 … m-1, m的連續整數列寫法
a4 <- c(15:30)
print(a4)
class(a4)

# 使用索引(index)抓取向量當中指定元素
# 物件名稱[索引]，將索引的條件寫在物件名稱後的中括號內
a4[1]
a4[c(2:3)]
a4[c(2:3, 8)]

# 向量的運算及操作會應用到向量中的每一個元素
# 運算符號：加法 +, 減法 -, 乘法 *, 除法 /, 餘數 %%
a5 <- a4 + 2
print(a5)



### 1.3. 文字型 ----

# 單一字串
b1 <- "Peter"
print(b1)
class(b1)

# 多個字串組成文字向量
# 每個元素字串的長度可以不一樣
b2 <- c("Peter", "Sam", "Kate")
print(b2)
class(b2)

# 向量長度(向量內包含元素的數量)
length(b2)

# 字串長度(向量內每個元素的字串長度)
nchar(b2)



### 1.4. 邏輯值 ----

# 布林邏輯值元素只有兩種, TRUE(簡寫T), FALSE(簡寫F)
# 用於表達條件比較的結果為真(T)或為假(F)
# 比較用的運算子(operater)：>, <, ==, >=, <=, !=, %in%

# 數值的比較，把比較的結果存為新的邏輯向量
c1 <- c(10:15)
c2 <- c1 > 13 
print(c1)
print(c2)
class(c2)

# 我們想知道c1向量當中「哪一些元素」大於13，而非只知道邏輯值
# 執行指令c1 > 13的比較會得到一個邏輯向量，長度與c1相同
# 將邏輯值作為「索引」放入c1之後的中括號[]當中
# 會將對應邏輯值為TRUE的元素保留
print(c1)
c1 > 13
c2 <- c1[c1 > 13]
print(c2)

# 文字的比較，把比較的結果存為新的邏輯向量
d1 <- c("Taiwan", "ROC", "Formosa", "MyCountry")
d2 <- d1 == "China"
print(d1)
print(d2)
class(d2)

# state.abb是一個R內建的物件，包含美國50州的英文縮寫
# 美國洲名(state.abb)的前10個，是否包含紐約(NY)和加州(CA)?
print(state.abb)
e1 <- state.abb[1:10]
e2 <- e1 %in% c("NY", "CA")
print(e1)
print(e2)
class(e2)





### ~ 常用套件與函數應用 ~ ----

# 如何瞭解函數的使用
?sample

### 2.0. 作業環境  ----

# rm是remove的縮寫，移除「物件」
rm(a1)

# ls是列出所有正在使用的物件名稱
ls()

# 移除所有正在使用的物件
rm(list = ls())



### 2.1. 套件(packages) ----

# install.packages可以下載網路上的套件來使用
install.packages("readr") # 匯入Excel檔案
install.packages("fst") # fst檔案
install.packages("ggplot2") # 繪圖套件
install.packages("data.table") # data.frame的進階版，實用資料處理方法

# library 將要應用的套件載入記憶體
library(survival)



### 2.2. 讀取與寫出檔案 ----

# 檔案位址 = 資料夾路徑/檔案名稱.副檔名
# Windows裡面是用backward slash「\」分隔
# 要改成forward slash「/」

# 讀取fst檔案
library(fst)
a <- read_fst("C:/Users/PeterLiu/Downloads/2020_Open/DemoData/h_nhi_ipdte103.fst")

# 讀取csv檔案
library(readr)
b <- read_csv("C:/Users/PeterLiu/Downloads/2020_Open/all_drug_no.csv")
rm(b)


### 2.3. 資料預檢 ----

# str()可以檢查資料的結構
str(a)

# head()可以印出資料的頭(預設是前6列)
head(a)

# 對一個data使用summary函數，可以看到整體描述性統計
summary(a)

# 對單一數值欄位進行描述性統計
summary(a$order_num)

# 對單一類別欄位進行描述性統計
table(a$case_type)




### 2.4. 數值運算 ----

# 整體描述性摘要
# 個別函數min, max, mean, sd, median, qrange
mean(a$order_num)
sd(a$order_num)
min(a$order_num)
quantile(a$order_num, 0.25)
median(a$order_num)
quantile(a$order_num, 0.75)
max(a$order_num)
IQR(a$order_num)



### 2.5. 文字處理  ----

# paste函數是將文字進行組合
a$in_age_cha1 <- paste("年齡", a$in_age)
a$in_age_cha2 <- paste("年齡", a$in_age, sep = " = ")
a$in_age_cha3 <- paste0("年齡", a$in_age)

head(a[, c("id", "in_age", "in_age_cha1", "in_age_cha2", "in_age_cha3")])

# 找尋文字：grep & grepl

# 飛機航班編號
flight <- c("AC-18", "TR-874", "TR-899", "TG-5871", "BI-452", "CI-9504", "BR-102", "NH-5848", "NZ-4902", "TK-9452", "TG-6282", "BR-158", "TG-6376", "TK-9470", "NH-5820", "NZ-4920")
print(flight)

# 從flight物件中找尋包含"BR"的元素，並回傳其位置(index)
flight.1 <- grep("BR", flight)
print(flight.1)

# 從flight物件中找尋包含"BR"的元素，並回傳其符合條件的值(value)
flight.2 <- grep("BR", flight, value = T)
print(flight.2)

# 從flight物件中找尋包含"BR"的元素
# 並回傳其邏輯值(logical)
# 值的個數會等於原始向量的長度(元素數量)
flight.3 <- grepl("BR", flight)
print(flight.3)



# 擷取文字：substr
# substr(擷取對象, 起始位置, 停止位置)
flight.4 <- substr(flight, 1, 2)
print(flight.4)
table(flight.4)



# 取代文字：sub & gsub
e2 <- c("TCGATT", "ATATG")

# 將各別元素內符合模式(pattern)的「第一個字串」取代為新的字串
e2.1 <- sub(pattern = "T", replacement = "U", e2) 
print(e2.1)

# 將各別元素內符合模式(pattern)的「所有字串」取代為新的字串
e2.2 <- gsub(pattern = "T", replacement = "U", e2)
print(e2.2)



### 2.6. 隨機抽樣  ----

# sample
r1a <- sample(x = LETTERS, size = 10)
table(r1a)

r1b <- sample(x = LETTERS, size = 50, replace = T)
table(r1b)

# 隨機均等分布
r2a <- runif(n = 300)
hist(r2a)

# 自訂抽樣分布範圍
r2b <- runif(n = 300, min = 15, max = 50)
hist(r2b)

# 隨機常態分布
r3a <- rnorm(n = 300)
hist(r3a)

# 自訂抽樣分布
r3b <- rnorm(n = 300, mean = 5, sd = 1.23)
hist(r3b)

# 機率分佈
x1 <- rnorm(3000)
y1 <- dnorm(x1)
y2 <- pnorm(x1)
df <- data.frame(x1, y1, y2)

library(ggplot2)

# PDF
ggplot(data = df, aes(x = x1, y = y1)) + geom_line()

# CDF
ggplot(data = df, aes(x = x1, y = y2)) + geom_line()





### ~ data.table ~ ----
library(data.table)

# 建立data.table
DT <- data.table(
  uid = c("A01", "A01", "A02", "A03", "A02", "A02"),
  visit = c(1, 2, 1, 1, 2, 3),
  sbp = c(118, 117, 146, 119, 150, 130),
  dbp = c(85, 80, 92, 90, 92, 100)
)

# 可以手動建立資料，也可以匯入外部資料，如read_fst/csv
# 但是要使用as.data.table()賦予物件屬性




### 3.1. i → 觀察值(row) ----

# 使用變項(column)的特性選擇觀察值(row)

# 哪一些是首次看診紀錄
DT.i1 <- DT[visit == 1]
print(DT.i1)

# 哪一些是pre-HTN(sbp落在120-140中間)
DT.i2 <- DT[sbp >= 120 & sbp <= 140]
print(DT.i2)

# 資料排序
DT.i3 <- DT[order(uid, -visit)]
print(DT.i3)



### 3.2. j → 欄位(col) ----

# 選擇欄位
DT.j1 <- DT[, .(uid, sbp, dbp)]
print(DT.j1)

# 保留全部的欄位，並加上1個新建立的欄位
DT.j2 <- DT[, `:=`(CaseGroup = 1)]
print(DT.j2)

# 保留想要的欄位，並加上2個新建立的欄位
DT.j3 <- DT[, `:=`(gp = 1, gp2 = 0)]
print(DT.j3)



### 3.3. i, j的綜合運用 ----


# 先創造一個變項賦予起始值，再將符合條件的觀察值改變其內容
# 大家都先有一個新的變項叫做htn，大家都是0
# 如果有哪一些觀察值的SBP大於420 mm-HG
# 那就把這一些觀察值的pre_htn欄位修改為1
DT.m1 <- DT[, `:=`(htn = 0)][sbp >= 140, `:=`(htn = 1)]
table(DT.m1$htn)

# 簡便寫法，但一次只能處理一個變項
DT.m2 <- DT[, htn := 0][sbp >= 140, htn := 1]
table(DT.m2$htn)



### 3.4. by → 組別 ----

# j, by的綜合運用

# 進行分組運算，結果成為新的欄位，data.table不含原始欄位
# 只有彙算結果
DT.g1 <- DT[, .(mean_sbp = mean(sbp), mean_dbp = mean(dbp)), by = uid]
print(DT.g1)

# 進行分組運算，結果成為新的欄位，data.table包含原始欄位
DT.g2 <- DT[, `:=`(mean_sbp = mean(sbp), mean_dbp = mean(dbp)), by = uid]
print(DT.g2)

# i, by的綜合運用
# 資料排序後取每人第n筆
DT[order(uid, visit)]

DT[, .SD[1], by = uid]       # 群組內第1筆
DT[, .SD[c(1:3)], by = uid]  # 群組內第1-3筆
DT[, .SD[c(1, 3)], by = uid] # 群組內第1, 3筆
DT[, .SD[.N], by = uid]      # 群組內最後一筆


### 3.5. 連結資料表 join ----
ptinf <- data.table(
  uid = c("C01", "C02", "C03", "C04"),
  age = c(50, 39, 67, 88)
)

mmse <- data.table(
  uid = c("C02", "C03", "C09"),
  score1 = c(27, 12, 22)
)

barthel <- data.table(
  uid = c("C01", "C03", "C07"),
  score2 = c(95, 80, 90)
)

# 交集 inner join
DT_2a.1 <- merge(ptinf, mmse, by = c("uid"))
DT_2a.2 <- ptinf[mmse, on = .(uid), nomatch = 0]
print(DT_2a.1)
print(DT_2a.2)

# 右聯結 right join
DT_2b.1 <- merge(ptinf, barthel, by = c("uid"), all.y = T)
DT_2b.2 <- ptinf[barthel, on = .(uid)]
print(DT_2b.1)
print(DT_2b.2)

# 左聯結 left join
DT_2c <- merge(ptinf, mmse, by = c("uid"), all.x = T)
print(DT_2c)

# 聯集 full join
DT_2d <- merge(mmse, barthel, by = c("uid"), all = T)
print(DT_2d)

rm(list = ls())





### ~ 正規表達式 Regular Expression ~ ----

# demo data
df1 <- data.table(
  UID = c("A01", "A01", "B05", "C02", "B04", "A09", "A08", "A08", "A08", "C01"),
  icd1 = c("250", "25010", "1250", "430", "431", "432", "433", "4332", "434", "436")
)
View(df1)

### 4.1. 模式 pattern ----

# 使用grepl判斷df1資料表中UID字串是否以A開頭，並產生T/F
# 將T/F值放入data.table的i位置，將T的列留下
df1[grepl("^A", UID)]

# 使用grepl判斷df1資料表中UID字串是否以01結果，回傳資料列
df1[grepl("01$", UID)]

# 辨識ICD Codes
df1[grepl("250", icd1)] # 不小心抓到 125.0 Bancroftian filariasis
df1[grepl("^250", icd1)] # 應該使用250「開頭」才對



### 4.2. 模式的變化型 ----

# Ischemic stroke：ICD-9-CM為433.xx, 434.xx 
df1[grepl("^433|^434", icd1)] # 433開頭或434開頭，這樣可以考量有次診斷資料
df1[grepl("^43[34]", icd1)] # 43開頭，後面接3或4的數字

# overall stroke, 430, 431, 432, 433, 434, 435, 436, 437, 438
df1[grepl("^43[0-8]", icd1)] # 43開頭，後面接0-8的數字


# useful reference

# https://blog.yjtseng.info/post/regexpr/
# https://datascienceandr.org/articles/RegularExpression.html





### ~ for 迴圈 ~ ----



### 5.1. 代入數值資料  ----

# i和其來源物件都可以自行決定

# 連續數列
for (i in 1:10){
  print(i)
}

# 使用c來集結非連續元素成為一個向量供i使用
for (i in c(3, 5, 20, 200)){
  print(i)
}



### 5.2. 代入文字資料  ----
for (i in LETTERS){
  print(i)
}

for (i in c("Peter", "Anny", "John")){
  print(i)
}



### 5.3. 迴圈中處理資料  ----
for (i in 1:30){
  print(paste("complete iteration", i))
}



### 5.4. 各個月份就診人次  ----
a <- list.files("C:/Users/PeterLiu/Downloads/2020_Open/DemoData", full.names = T)
a <- grep("opdte", a, value = T)
a <- grep("_10", a, value = T)
b <- vector(mode = "list", length = length(a))
for (i in 1:length(a)) {
  print(i)
  temp <- read_fst(a[i])
  b[[i]] <- nrow(temp)
  rm(temp)
  print(paste("complete iteration", i, "at", Sys.time()))
}
print(b)





### ~ DM診斷與藥物 ~ ----

# 6.1. library ----
library(fst)
library(readr)
library(data.table)



# 6.2. 讀取資料 ----

# 藥物總檔
drug_all <- read_csv("C:/Users/PeterLiu/Downloads/2020_Open/all_drug_no.csv")
drug_all <- as.data.table(drug_all)

# DM藥物為ATC Code屬於A10開頭
drug_dm <- drug_all[grep("^A10", atc_code)]
drug_dm <- drug_dm[, .(drug_no)]
drug_dm <- unique(drug_dm)
drug_dm <- drug_dm[, `:=`(dm_tx = 1)]

rm(drug_all)

# 門診資料
# 當你設定工作路徑之後
# R會直接在工作路徑裡面搜尋你的檔案名稱
# 所以資料夾路徑可以省略
setwd("C:/Users/PeterLiu/Downloads/2020_Open/DemoData")
opd_1a <- read_fst("h_nhi_opdte10301_10.fst", as.data.table = T)
opd_1b <- read_fst("h_nhi_opdto10301_10.fst", as.data.table = T)



# 6.3. 合併資料 ----

# 費用檔和醫令檔合併(交集)
opd_2 <- merge(opd_1a, opd_1b, by = c("fee_ym", "case_type", "appl_type", "appl_date", "seq_no", "hosp_id"))

# 門診檔和藥品檔合併(左聯集)
opd_2 <- merge(opd_2, drug_dm, by = c("drug_no"), all.x  = T)

# 建立欄位辨識DM診斷
opd_2 <- opd_2[, dm_dx := 0][grepl("^250", icd9cm_1)|grepl("^250", icd9cm_2)|grepl("^250", icd9cm_3), dm_dx := 1]
table(opd_2$dm_dx)

# 建立欄位辨識DM藥物
opd_2 <- opd_2[is.na(dm_tx), dm_tx := 0]
table(opd_2$dm_tx)

# 資料歸戶
opd_3 <- opd_2[, .(dm_dx = max(dm_dx), dm_tx = max(dm_tx)), by = .(id)]



# 6.4. 資料分析 ----
table(opd_3$dm_tx, opd_3$dm_dx)





# END #