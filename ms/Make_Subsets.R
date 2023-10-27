effect_Ids <- ManyEcoEvo_results %>% 
  filter(exclusion_set == "complete", publishable_subset == "All") %>% 
  select(MA_mod, effects_analysis) %>% 
  group_by(estimate_type, dataset) %>% 
  transmute(tidy_mod = map(MA_mod, 
                           ~ broom::tidy(.x, conf.int = TRUE, include_studies = TRUE) %>% 
                             rename(study_id = term))) %>% 
  unnest(tidy_mod) %>% filter(type =="study") %>% 
  select(study_id)

effect_Ids$dataset<-NULL
effect_Ids$estimate_type<-NULL
colnames(effect_Ids)<-"id_col"
write_csv(effect_Ids,"ms/effect_Ids.csv")


Euc_Ids<-mod_data_logged %>% #TODO not reproducible
  hoist(data, "study_id") %>% 
  select(study_id, estimate_type) %>% 
  unnest(study_id)

BT_Ids<-ManyEcoEvo_yi_results %>% #TODO not reproducible
  filter(exclusion_set == "complete", dataset == "blue tit") %>% 
  select(MA_mod, effects_analysis, -exclusion_set) %>% 
  group_by(estimate_type, dataset) %>% 
  transmute(tidy_mod = map(MA_mod, 
                           ~ broom::tidy(.x, conf.int = TRUE, include_studies = TRUE) %>% 
                             rename(study_id = term))) %>% 
  unnest(tidy_mod) %>% filter(type == "study") %>% 
  select(estimate_type, study_id)

BT_Ids$dataset<-NULL

bothpredids<-bind_rows(BT_Ids,Euc_Ids)
bothpredids$estimate_type<-NULL
colnames(bothpredids)<-"id_col"
write_csv(bothpredids,"ms/predictions_Ids.csv")
