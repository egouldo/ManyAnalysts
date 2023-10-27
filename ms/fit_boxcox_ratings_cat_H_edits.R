
library(targets)
library(withr)
library(here)
library(metafor)
library(ManyEcoEvo)
library(tidyverse)
library(parameters)
library(gt)
library(specr)
library(lme4)
library(Hmisc)
library(irr)
library(MuMIn)
library(glmmTMB)
library(broom.mixed)

# Load Anonymisation lookup
TeamIdentifier_lookup <- read_csv(here::here("data-raw/metadata_and_key_data/TeamIdentifierAnonymised.csv"))
# Load all required targets and anonymise
withr::with_dir(here::here(),
                targets::tar_load(ManyEcoEvo_results))
withr::with_dir(here::here(),
                targets::tar_load(ManyEcoEvo_viz))
withr::with_dir(here::here(),
                targets::tar_load(ManyEcoEvo))
withr::with_dir(here::here(),
                targets::tar_load(ManyEcoEvo_yi))
withr::with_dir(here::here(),
                targets::tar_load(ManyEcoEvo_yi_results))
withr::with_dir(here::here(),
                targets::tar_load(ManyEcoEvo_yi_viz))

tibble::lst(ManyEcoEvo, ManyEcoEvo_yi) %>% 
  set_names(., c("ManyEcoEvo", "ManyEcoEvo_yi") ) %>% 
  map(~ .x %>%
        mutate_at(c("data", "diversity_data"),
                  .funs = ~ map(.x, anonymise_teams, TeamIdentifier_lookup))) %>% 
  walk2(.x = names(.), .y = .,
        ~ assign(x = .x, value = .y, envir = .GlobalEnv))

tibble::lst(ManyEcoEvo_results, ManyEcoEvo_yi_results) %>% 
  set_names(c("ManyEcoEvo_results", "ManyEcoEvo_yi_results")) %>% 
  map(~ .x %>%  
        mutate(effects_analysis = map(effects_analysis, rename, id_col = study_id)) %>% 
        mutate_at(c("data", "diversity_data", "diversity_indices", "effects_analysis"),
                  .funs = ~ map(.x, anonymise_teams, TeamIdentifier_lookup)) 
  ) %>% 
  walk2(.x = names(.), .y = .,
        ~ assign(x = .x, value = .y, envir = .GlobalEnv))





btZr<-ManyEcoEvo_results[[8]][[1]] #complete set, blue tit with box cox
eucZr<-ManyEcoEvo_results[[8]][[2]] #complete set, eucalyptus with box cox
bothZr<-bind_rows(btZr,eucZr)%>% # join the bt and euc data together
  unnest(cols = c(review_data))%>%  #unnest review data
  mutate(PublishableAsIs = as.numeric(forcats::fct_relevel(PublishableAsIs,c("deeply flawed and unpublishable", 
                                                                             "publishable with major revision", 
                                                                             "publishable with minor revision", 
                                                                             "publishable as is")),
                                      obs_id = 1:n())) 

lme1<-lmer(box_cox_abs_deviation_score_estimate ~ PublishableAsIs + (1 | ReviewerId), data = bothZr)
lme2<-lmer(box_cox_abs_deviation_score_estimate ~ PublishableAsIs + (1 | ReviewerId) + (1 | id_col), data = bothZr)
broom.mixed::tidy(lme1, conf.int=TRUE)   
broom.mixed::tidy(lme2, conf.int=TRUE) 

summary(lme1)
summary(lme2)
