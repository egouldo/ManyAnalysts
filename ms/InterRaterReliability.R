library(tidyverse)
library(targets)
library(irr)

tar_load(ManyEcoEvo_results)

ReviewData2<-ManyEcoEvo_results %>% 
  filter(exclusion_set == "complete", publishable_subset == "All") %>% 
  ungroup %>% 
  select(data, -dataset) %>% 
  unnest(data) %>% 
  select(ends_with("_id"), id_col, dataset, review_data) %>% 
  unnest(review_data)%>% 
  distinct(ReviewerId , id_col,.keep_all = T) %>% 
#by unfortunate chance two reviewer reviewed the same analyses twice Rev100 for R_2TFbZCxFIz91BGC and Rev133 for R_1hSZf5af3tKfwLI. Fortunately, their ratings were similar so we will just use distinct to remove one above

#reviewers reviewed all analyses per team for each dataset - need to deduplicate to avoid inflating inter-rater reliability
distinct(response_id, ReviewerId , dataset,.keep_all = T) 

ReviewData2$PublishableAsIs2<-ifelse(ReviewData2$PublishableAsIs=="publishable as is",4,ifelse(ReviewData2$PublishableAsIs=="publishable with minor revision",3,ifelse(ReviewData2$PublishableAsIs=="publishable with major revision",2,ifelse(ReviewData2$PublishableAsIs=="deeply flawed and unpublishable",1,NA))))

ContinuousRating2<-ReviewData2 %>% select(c("id_col","ReviewerId","RateAnalysis")) %>%pivot_wider(
  names_from = id_col, values_from = RateAnalysis)
ContinuousRating2m<-as.matrix(ContinuousRating2)

alpha_result_continuous2 <- irr::kripp.alpha(x = t(ContinuousRating2m),
                                     method = "nominal")

OrdinalRating2<-ReviewData2 %>% select(c("id_col","ReviewerId","PublishableAsIs2")) %>%pivot_wider(
  names_from = id_col, values_from = PublishableAsIs2)



alpha_result_ordinal2 <- irr::kripp.alpha(x = t(OrdinalRating),
                                            method = "ordinal")
