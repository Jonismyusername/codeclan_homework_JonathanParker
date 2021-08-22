library(tidyverse)
library(shiny)
library(CodeClanData)
library(fmsb)


whisky_flavours <- whisky %>% 
  select(Distillery, Body:Floral)

whisky_flavours_minmax <- rbind(rep(4, 12), rep(0, 12), whisky_flavours)
