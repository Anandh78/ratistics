##-------------------------------------------------------------------
## check all data in specs using R to verify correctness
##-------------------------------------------------------------------

library(descr)

## module CentralTendency

sample <- c(13, 18, 13, 14, 13, 16, 14, 21, 13)
mean(sample) #=> 15

sample <- c(13, 18, 14, 16, 21)
mean(sample) #=> 16.4

sample <- c(13, 18, 13, 14, 13, 16, 14, 21, 13, 11, 19, 19, 17, 16, 13, 12, 12, 12, 20, 11)
mean(sample, trim=0.125) #=> 14.625
mean(sample, trim=0.10) #=> 14.625
mean(sample, trim=0.05) #=> 14.72222
mean(sample, trim=0.0) #=> 14.85

sample <- c(13, 19, 12, 17, 18, 11, 21, 14, 16, 20)
mean(sample, trim=0.10) #=> 16.125

sample <- c(13, 18, 13, 14, 13, 16, 14, 21, 13, 0)
median(sample) #=> 13.5

sample <- c(13, 18, 13, 14, 13, 16, 14, 21, 13)
median(sample) #=> 14

sample <- c(73, 75, 80, 84, 90, 92, 93, 94, 96)
quantile(sample)
# 0%  25%  50%  75% 100% 
# 73   80   90   93   96 

sample <- c(1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,4,4,5,6)
quantile(sample)
# 0%  25%  50%  75% 100% 
#  1    2    2    3    6 

## module Distribution

sample <- c(67, 72, 85, 93, 98)
sd(sample) #=> 13.28533
mad(sample, center=85) #=> 19.2738
var(sample) #=> 176.5

sample <- c(13, 13, 13, 13, 14, 14, 16, 18, 21)
max(sample) - min(sample) #=> 8

