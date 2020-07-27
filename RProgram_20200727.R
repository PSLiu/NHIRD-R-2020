### ~ 物件 ~ ----



### 1.1. 數值型 ----

# 單一數值
a1 <- 5L
a1
class(a1)

a2 <- 3
a2
class(a2)

a3 <- 3.1415
a3
class(a3)

# 使用c()將多個數字組合成一個向量(vector)
# 同一向量當中須為相同類型(class)的元素(element)
a4 <- c(1, 4, 90, 585)
a4

# 使用c()產生1, 2, ... 19, 20的數列
a5 <- c(1:20)
a5
class(a5)

# 使用seq()函數產生指定起始、結尾和間隔的數列
a6 <- seq(from = 1, to = 20)
a6
class(a6)

a7 <- seq(from = 1, to = 20, by = 3)
a7

# 使用索引(index)回傳向量當中的元素
# 起始的索引值為1，不同於python為0
a7[1]
a7[2:3]
a7[c(2:3)]
a7[c(2, 5)]

# 向量的運算及操作會應用到向量中的每一個元素
# 運算符號：加法 +, 減法 -, 乘法 *, 除法 /, 餘數 %%
a7 + 2
a8 <- a7 + 2
a8



### 1.2. 文字型 ----

# 單一字串
b1 <- "Peter"
b1
class(b1)

# 多個字串，內容長度可以不一樣
b2 <- c("Peter", "Jonny", "Kay")
b2
class(b2)



### 1.3. 邏輯值 ----

# 布林邏輯值物件, T = TRUE, F = FALSE
c1 <- T
class(c1)

c2 <- F
class(c2)

c3 <- c(T, T, F, F, T)
class(c3)

# 運算子(operater)
# >, <, ==, >=, <=, !=, %in%, 
# 比較的結果，將以T和F的方式代表
1 < 3
1 >= 3

# 將向量進行比較
# 回傳與原向量等長的邏輯值
a7
a7 > 10
a7 <= 10
a7 == 7
a7 != 7
a7 %in% c(4, 13)

# 把a7向量進行"是否大於10"的比較
# 回傳與a7向量長度(元素數量)一樣的邏輯值
# 將邏輯值套用在角括號[]當中
# 會將對應邏輯值為TRUE的元素保留/呈現
a7
a7[a7 > 10]

# 字串的比較
b2 == "Jonny"
b2 %in% c("Jonny", "Peter")



### 1.4. 資料框 data.frame ----

# data.frame是最常見的資料及儲存格式
# 可以將「不同類型」但長度相等的向量組合成資料框
# 以「欄位名稱 = 向量」的方式建立，多個向量用逗點隔開
# 和Excel/SAS/STATA相同，以欄、列儲存方式資料
df1 <- data.frame(
  UID = c("A01", "A01", "A02", "A02", "A02", "A03"),
  Visit = c(1, 2, 1, 2, 3, 1),
  sbp = c(118, 117, 116, 119, 120, 130),
  dbp = c(85, 80, 92, 90, 92, 100)
)
class(df1)

# 選擇觀察值(列/row)
df1[1, ]
df1[1:2, ]
df1[c(1, 3), ]
df1[df1$UID == "A01", ]
df1[df1$UID %in% c("A01", "A03"), ]

# 選擇變項(欄/column)
df1[, 1]
df1[, 1:2]
df1[, c(1, 3)]
df1$UID
df1[, "UID"]
df1[, c("UID", "sbp")]

# 下一章節的data.table將會給你一個更快速的操作方法！



### 1.5. 清單 list ----

# list可以將「不同類型的物件」混和在成一個物件
l1 <- list(x1 = c(1:10),  x2 = "Peter", x3 = df1)
l1

# 讓我們來看看清單當中的不同元素
# 清單[[清單內條件]][物件內條件]
l1[[1]]
l1[["x1"]]
l1$x1
l1[[2]]
l1[[3]]
l1[[3]][1]





### ~ 基本函數 ~ ----

### 2.1. 作業環境  ----

# library 將要應用的套件載入記憶體
library(survival)
# 將套件內容自記憶體卸載
detach(name = "package:survival", unload = TRUE)

# rm是remove的縮寫，移除「物件」
rm(a1)

# 若要移除多個物件，可以用逗點進行分隔
rm(df1, l1)

# 若要移除特定模式，例如說名稱為a開頭的物件
# 使用ls()函數產生一個清單
# 內容為environment當中名稱開頭為"a"的物件
# 將此一清單賦值至rm()函數的list
rm(list = ls(pattern = "^a"))

# pattern當中的"^a"是正規表達式(regular expression)
# 將會在後續章節介紹

# 移除environment當中的所有物件
rm(list = ls())

# list.files可以列出資料夾中檔案的清單
# 目前的工作資料夾，也是R script開啟時的資料夾
list.files()

# 也可以列出其他資料夾
# 同一工作資料夾中名為fst的子資料夾
# 注意R的路徑間格為/，不是Windows的\
list.files(path = "./fst") 

# 此範例想要找死因檔
# 其檔名會以"h_ost"作為開頭
list.files(path = "./fst", pattern = "^h_ost")

# 可以列出指定模式(pattern)的檔案名稱
# 此範例想要找出R script檔案
# 其檔名會以".R"作為結尾
list.files(pattern = ".R$")

# 請鎖定下午場的超實用regular expression講解！



### 2.1. 數值運算 ----

# 整體描述性摘要
# 個別函數min, max, mean, sd, median, qrange
d1 <- c(1:30)

summary(d1)
mean(d1)
sd(d1)
min(d1)
quantile(d1, 0.25)
median(d1)
quantile(d1, 0.75)
max(d1)
IQR(d1)

rm(d1)



### 2.2. 文字處理  ----

# 表格，產生次數統計
e1 <- c("G", "C", "G", "T", "G", "A", "C", "A", "T", "C")
table(e1)

# 字串組合：# paste & paste0

# 將字串組合，想要組合的元素以逗點分隔
# paste預設以空白鍵(space)作為分隔
e1.1 <- paste("gen", e1)
print(e1.1)

# 可以透過sep = "你想要的符號"自行定義
e1.2 <- paste("gen", e1, sep = "-")
print(e1.2)

# paste0預設字串之間不使用符號分隔
e1.3 <- paste0("gen", e1)
print(e1.3)



# 找尋文字：grep & grepl

# 從e1物件中找尋包含"A"的元素
# 並回傳其位置(index)
e1.4 <- grep("A", e1)
print(e1.4)

# 從e1物件中找尋包含"A"的元素
# 並回傳其符合條件的值(value)
e1.5 <- grep("A", e1, value = T)
print(e1.5)

# 從e1物件中找尋包含"A"的元素
# 並回傳其邏輯值(logical)
# 值的個數會等於原始向量的長度(元素數量)
e1.6 <- grepl("A", e1)
print(e1.6)

rm(list = ls(pattern = "^e1"))



# 取代文字：sub & gsub

e2 <- c("TCGATT", "ATATG")

# 將元素內「第一個」符合模式(pattern)的字串取代為新的字串
sub(pattern = "T", replacement = "U", e2) 

# 將元素內「所有」符合模式(pattern)的字串取代為新的字串
gsub(pattern = "T", replacement = "U", e2)

rm(e2)



### 2.3. 多功能用途  ----

# 抽樣：sample

# LETTERS是R內建的物件，包含A-Z的大寫字母
# x是抽樣的樣本空間
# size是抽樣的數量
# 預設是抽出「不放回」
LETTERS
sample(x = LETTERS, size = 10)

# 當抽樣以抽出放回的方式進行，replace = TRUE
# 當size大於x的時候必須要指定
sample(LETTERS, 50, replace = T)
sample(c("Trump", "Winnie", "Kim"), 10, replace = T)
sample(1:3, 10, replace = T)

# ramdom number

# 隨機均等分布
runif(n = 30)
runif(n = 30, min = 15, max = 50)

# 隨機常態分布
rnorm(n = 30)
rnorm(n = 30, mean = 5, sd = 1.23)

# length：回傳向量長度
length(runif(30))





### ~ 實用套件 packages ~ ----
install.packages("readr") # 匯入Excel檔案
install.packages("fst") # fst檔案
install.packages("data.table") # data.frame的進階版，實用資料處理方法

### 3.1. readr ----

# library
library(readr)

# read in
drug <- read_csv("all_drug_no.csv")
str(drug)
dim(drug)

rm(drug)

### 3.1. fst ----

# read_fst

# library
library(fst)

# read in
opdte201401 <- read_fst("./fst/h_nhi_opdte10301_10.fst")
str(opdte201401)
head(opdte201401)
head(opdte201401, 10)
tail(opdte201401)



### 3.1. data.table ----

# library
library(data.table)

# as.data.table
opdte201401 <- read_fst("./fst/h_nhi_opdte10301_10.fst")
class(opdte201401)
opdte201401 <- as.data.table(opdte201401)
class(opdte201401)





### ~ data.table ~ ----

# 使用read_fst()函數將獨入的資料轉成data.table
opdte201401 <- read_fst("./fst/h_nhi_opdte10301_10.fst", as.data.table = T)

### 4.1. i → 觀察值(row) ----

# 使用變項(column)的特性選擇觀察值(row)

# 拿慢性處方箋的有幾人?
chronic <- opdte201401[case_type == "08"]
nrow(chronic)

# 有多少糖尿病人(主診斷250)且給藥天數>0天
dm <- opdte201401[icd9cm_1 == "250" & drug_day > 0]
nrow(dm)

# 哪些人的用藥天數落在1-14天
weekdrug.1 <- opdte201401[1 <= drug_day & drug_day <= 14]
summary(weekdrug.1$drug_day)

# between函數將會包含上下界
# 可以透過指定參數incbounds = F來修改
weekdrug.2 <- opdte201401[between(drug_day, 1, 14)]
summary(weekdrug.2$drug_day)



### 4.2. j → 欄位(col) ----

# 使用名稱來選擇需要的欄位

# data.frame傳統作法
icd <- opdte201401[, c("id", "icd9cm_1", "icd9cm_2", "icd9cm_3")] 
str(icd)

# data.table現代做法
icd <- opdte201401[, .(id, icd9cm_1, icd9cm_2, icd9cm_3)] 
str(icd)

# 先創造一個變項賦予起始值，再將符合條件的觀察值改變其變數內容
# 大家都先有一個新的(:=)變項叫做dm，大家都是0
# 如果有哪一些觀察值的icd9cm_1欄位是字串"250"
# 那就把這一些觀察值的dm欄位修改為1
icd.dm <- icd[, dm := 0][icd9cm_1 == "250", dm := 1]

# 跑出所有符合dm欄位為1觀察值的icd0cm_1欄位
icd[dm == 1, icd9cm_1]
str(icd.dm)
table(icd.dm$dm)



### 4.3. by → 組別 ----

# 分組摘要

# 以性別為分組進行用藥天數的平均值計算
opdte201401[, mean(drug_day), by = .(id_s)]

# 以性別為分組進行用藥天數的平均值計算，並將計算後的欄位命名為mean_drug_day
opdte201401[, .(mean_drug_day = mean(drug_day)), by = .(id_s)]



### 4.4. 連結資料表 join ----
df1 <- data.table(uid = sample(LETTERS, 20), sbp = runif(20))
df2 <- data.table(uid = sample(LETTERS, 20), dbp = runif(20))

# 右連結 right join
df3.r <- df1[df2, on = .(uid)]

# 交集 inner join
df3.i <- df1[df2, on = .(uid), nomatch = 0]

# 去除交集 anti join
df3.a <- df1[!df2, on = .(uid)]

rm(list = ls())





### ~ 正規表達式 Regular Expression ~ ----

# demo data
df1 <- data.table(
  UID = c("A01", "A01", "B05", "C02", "B04", "A09", "A08", "A08", "A08", "C01"),
  icd1 = c("250", "25010", "1250", "430", "431", "432", "433", "4332", "434", "436")
)

### 5.1. 模式 pattern ----

# 使用grepl判斷df1資料表中UID字串是否以A開頭，並回傳T/F
grepl("^A", df1$UID)

# 將T/F值放入data.table的i位置，將T的列留下
df1[grepl("^A", UID)]

# 使用grepl判斷df1資料表中UID字串是否以01結果，回傳資料列
df1[grepl("01$", UID)]

# 辨識ICD Codes
df1[grepl("250", icd1)] # 不小心抓到 125.0 Bancroftian filariasis
df1[grepl("^250", icd1)] # 應該使用250開頭才對



### 5.2. 模式與子模式 ----

# Ischemic stroke：ICD-9-CM為433.xx, 434.xx 
df1[icd1 %in% c("433", "434")]

df1[grepl("^433|^434", icd1)] # 433開頭或434開頭
df1[grepl("^43[34]{1}", icd1)] # 43開頭，後面接1個3或4
df1[grepl("^43[34]{1}[0-9]{1}", icd1)] # 433或434開頭，且有次診斷第4碼

# hemorrhagic stroke
df1[grepl("^43[0-2]{1}", icd1)] # 43開頭，後面接1個0, 1, 2

# overall stroke, 430, 431, 432, 433, 434, 435, 436, 437, 438
df1[grepl("^43[0-8]{1}", icd1)] # 43開頭，後面接1個0-8

# useful reference

# https://blog.yjtseng.info/post/regexpr/
# https://datascienceandr.org/articles/RegularExpression.html





### ~ for 迴圈 ~ ----



### 6.1. 代入數值資料  ----

# i和其來源物件都可以自行決定

# 連續數列
for (i in 1:10){
  print(i)
}

# 使用c來集結一個非連續數列供i使用
for (i in c(3, 5, 20, 200)){
  print(i)
}



### 6.2. 帶入文字資料  ----
for (i in LETTERS){
  print(i)
}

for (i in c("Peter", "Anny", "John")){
  print(i)
}





### ~ NHIRD use R ~ ----

# library
library(fst)
library(data.table)

# 定義問題：有多少人在2014年的1月執行CPR心肺復甦術搶救?

# 讀取2014年1月的西醫門診費用檔opdte(ppatients' id) → 病人資料
# 讀取2014年1月的西醫門診費用檔opdto(order code) → 醫令資料
cd <- read_fst("./fst/h_nhi_opdte10301_10.fst", as.data.table = T)
oo <- read_fst("./fst/h_nhi_opdto10301_10.fst", as.data.table = T)

# 合併兩者
op <- cd[oo, on = .(fee_ym, case_type, appl_type, appl_date, seq_no, hosp_id), nomatch = 0]

# 找出符合CPR醫令碼(47029C)的觀察值，建立一個新的欄位cpr，其值為1
# 並保留身分證號(id)，就醫日期(func_date)，CPR共3個欄位
op1 <- op[, cpr := 0][drug_no == "47029C", cpr := 1][, .(id, func_date, cpr)]
table(op1$cpr)
  
# 整合成看診人次資料
op2 <- op1[, .(cpr_1 = max(cpr)), by = .(id, func_date)]
table(op2$cpr)

# 整合成歸人資料
op3 <- op2[, .(cpr_2 = max(cpr_1)), by = .(id)]
table(op3$cpr)