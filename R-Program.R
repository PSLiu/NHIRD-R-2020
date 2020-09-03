### ~ 物件 ~ ----

# 物件名稱 <- 內容
# "<-"的快捷鍵是 alt + -



### 1.1. 數值型 ----

# 單一數值
a1 <- 3
a1
class(a1)

a2 <- 3.1415
a2
class(a2)

# 使用c()將多個數字組合成一個向量(vector)
# 同一向量當中須為相同類型(class)的元素(element)
a3 <- c(1, 4, 90, 585)
a3
class(a3)

# 使用c()產生1, 2, ... 9, 10的數列
a4 <- c(1:10)
a4
class(a4)

# 使用索引(index)回傳向量當中的元素
# 起始的索引值為1，不同於python為0
a4[1]
a4[2:3]
a4[c(2:3)]
a4[c(2, 5)]

# 向量的運算及操作會應用到向量中的每一個元素
# 運算符號：加法 +, 減法 -, 乘法 *, 除法 /, 餘數 %%
a4 + 2
a5 <- a4 + 2
a5



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
a5
a5 > 10
a5 <= 10
a5 == 7
a5 != 7
a5 %in% c(4, 13)

# 我們想知道a5向量當中哪一些元素大於7
# 執行指令a5 > 7的結果為回傳一組邏輯值的向量，長度與a7相同
# 將邏輯值放入角括號[]當中
# 會將對應邏輯值為TRUE的元素保留

a5
a5 > 7
a5[a5 > 7]

# 字串的比較
b2
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

# 選擇觀察值(列/row)，放在角括號內逗點的左邊
df1[df1$sbp > 120, ]

# 選擇變項(欄/column)，放在角括號內逗點的右邊
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
l1[[2]]
l1[[3]]
l1[[3]][1]





### ~ 基本函數 ~ ----

# 如何瞭解函數的使用
?list.files

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
# 使用ls()函數產生一個物件名為drop
# 內容為environment當中名稱開頭為"a"的物件名稱所構成的向量
# 將此一清單作為rm()函數中list引數的參數
drop <- ls(pattern = "^a")
rm(list = drop)

# 函數包函數的簡潔寫法
rm(list = ls(pattern = "^b"))

# pattern當中的"^a"是正規表達式(regular expression)
# 將會在後續章節介紹

# 移除environment當中的所有物件
rm(list = ls())

# list.files可以列出資料夾中檔案的清單
# 注意R的路徑間格為/，不是Windows的\，需要手動修改
list.files(path = "C:/Peter/Dropbox/Teaching/R-NHIRD(2020)") 

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

# 將各別元素內符合模式(pattern)的「第一個字串」取代為新的字串
sub(pattern = "T", replacement = "U", e2) 

# 將各別元素內符合模式(pattern)的「所有字串」取代為新的字串
gsub(pattern = "T", replacement = "U", e2)

rm(e2)



### 2.3. 多功能用途  ----

# 抽樣：sample

# LETTERS是R內建的物件，包含A-Z的大寫字母
# sample()函數當中
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

# 隨機均等分布
runif(n = 30)
runif(n = 30, min = 15, max = 50)

# 隨機常態分布
rnorm(n = 30)
rnorm(n = 30, mean = 5, sd = 1.23)





### ~ 實用套件 packages ~ ----



### 3.0. 下載套件 ----

# 下載套件，許多好用的套件都不是R安裝時內建
install.packages("readr") # 匯入Excel檔案
install.packages("fst") # fst檔案
install.packages("ggplot2") # 繪圖套件
install.packages("gmodels") # 快速產生虛擬變項
install.packages("fastDummies") # 快速產生虛擬變項
install.packages("data.table") # data.frame的進階版，實用資料處理方法


### 3.1. readr ----

# library
library(readr)

# read_csv
drug <- read_csv("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/all_drug_no.csv")
str(drug)



### 3.2. fst ----

# library
library(fst)

# read_fst
opdte201401 <- read_fst("C:/Peter/Dropbox/Teaching/R-NHIRD(2020)/fst/h_nhi_opdte10301_10.fst")
str(opdte201401)
head(opdte201401)
head(opdte201401, 10)



### 3.3. ggplot2 ----

# library
library(ggplot2)

# ggplot
ggplot(data = opdte201401, aes(x = factor(id_s), y = drug_day)) + 
  stat_summary(fun = "mean", geom = "bar")



### 3.4. gmodels ----

# library
library(gmodels)
CrossTable(opdte201401$id_s, opdte201401$appl_type)
CrossTable(opdte201401$id_s, opdte201401$appl_typ, prop.r = T, prop.c = F, prop.t = F, prop.chisq = F)



### 3.5. fastDummies ----

# library
library(fastDummies)

opdte201401_dummy <- dummy_cols(opdte201401, select_columns = c("id_s"))

table(opdte201401_dummy$id_s)
table(opdte201401_dummy$id_s_1)
table(opdte201401_dummy$id_s_2)
table(opdte201401_dummy$id_s_9)





### ~ data.table ~ ----
library(data.table)

DT <- data.table(
  uid = c("A01", "A01", "A02", "A03", "A02", "A02"),
  visit = c(1, 2, 1, 1, 2, 3),
  sbp = c(118, 117, 116, 119, 120, 130),
  dbp = c(85, 80, 92, 90, 92, 100)
)



### 4.1. i → 觀察值(row) ----

# 使用變項(column)的特性選擇觀察值(row)

# 哪一些是首次看診紀錄
DT[visit == 1]

# 哪一些是pre-HTN(sbp落在120-140中間)
DT[sbp >= 120 & sbp <= 140]

# 資料排序
DT[order(uid, -visit)]



### 4.2. j → 欄位(col) ----

# 選擇欄位
DT[, .(uid, sbp, dbp)]

# 保留全部的欄位，並加上1個新建立的欄位
DT[, `:=`(CaseGroup = 1)]

# 保留想要的欄位，並加上2個新建立的欄位
DT[, `:=`(gp = 1, gp2 = 0)] 



### 4.3. i, j的綜合運用 ----


# 先創造一個變項賦予起始值，再將符合條件的觀察值改變其內容
# 大家都先有一個新的變項叫做pre_htn，大家都是0
# 如果有哪一些觀察值的SBP大於120 mm-HG
# 那就把這一些觀察值的pre_htn欄位修改為1
DT[, `:=`(pre_htn = 0)][sbp >= 120, `:=`(pre_htn = 1)]
table(DT$pre_htn)

# 簡便寫法，但一次只能處理一個變項
DT[, pre_htn := 0][sbp >= 120, pre_htn := 1]
table(DT$pre_htn)


### 4.4. by → 組別 ----

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


### 4.4. 連結資料表 join ----
df1 <- data.table(uid = sample(LETTERS, 20), lab1 = runif(20))
df2 <- data.table(uid = sample(LETTERS, 20), lab2 = runif(20))

# 右連結 right join
df1[df2, on = .(uid)]
df1[df2, on = .(uid = uid)] # e.g. order_code = drug_no

# 交集 inner join
df1[df2, on = .(uid), nomatch = 0]

# 去除交集 anti join
df1[!df2, on = .(uid)]

rm(list = ls())





### ~ 正規表達式 Regular Expression ~ ----

# demo data
df1 <- data.table(
  UID = c("A01", "A01", "B05", "C02", "B04", "A09", "A08", "A08", "A08", "C01"),
  icd1 = c("250", "25010", "1250", "430", "431", "432", "433", "4332", "434", "436")
)
View(df1)

### 5.1. 模式 pattern ----

# 使用grepl判斷df1資料表中UID字串是否以A開頭，並產生T/F
# 將T/F值放入data.table的i位置，將T的列留下
df1[grepl("^A", UID)]

# 使用grepl判斷df1資料表中UID字串是否以01結果，回傳資料列
df1[grepl("01$", UID)]

# 辨識ICD Codes
df1[grepl("250", icd1)] # 不小心抓到 125.0 Bancroftian filariasis
df1[grepl("^250", icd1)] # 應該使用250「開頭」才對



### 5.2. 模式的變化型 ----

# Ischemic stroke：ICD-9-CM為433.xx, 434.xx 
df1[icd1 %in% c("433", "434")]
df1[grepl("^433|^434", icd1)] # 433開頭或434開頭，這樣可以考量有次診斷資料
df1[grepl("^43[34]", icd1)] # 43開頭，後面接3或4的數字

# overall stroke, 430, 431, 432, 433, 434, 435, 436, 437, 438
df1[grepl("^43[0-8]", icd1)] # 43開頭，後面接0-8的數字


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

# 使用c來集結非連續元素成為一個向量供i使用
for (i in c(3, 5, 20, 200)){
  print(i)
}



### 6.2. 代入文字資料  ----
for (i in LETTERS){
  print(i)
}

for (i in c("Peter", "Anny", "John")){
  print(i)
}



### 6.3. 迴圈中處理資料  ----
for (i in 1:30){
  print(paste("complete iteration", i))
}





# END #
