# ==============================================================================
# COMPLETE FASHION CROSS-CATEGORY ANALYSIS
# ==============================================================================
# Project: Cross-Category Product Assortment Patterns in Fashion Retail
# Author: [Your Name]
# Course: MISM 6200 - Northeastern University
# Date: December 2024
# ==============================================================================

# Clean environment
rm(list = ls())

# Load required libraries
library(tidyverse)
library(randomForest)
library(caret)
library(reshape2)

cat("================================================================================\n")
cat("CROSS-CATEGORY PRODUCT ASSORTMENT ANALYSIS\n")
cat("Fashion Retail Product Clustering & Attribute Prediction\n")
cat("================================================================================\n\n")

# ==============================================================================
# PART 1: LOAD DATA
# ==============================================================================
cat("[1/8] Loading data...\n")
df <- read.csv("styles.csv", stringsAsFactors = FALSE)
cat(sprintf("✓ Loaded %s rows, %s columns\n", format(nrow(df), big.mark = ","), ncol(df)))

# ==============================================================================
# PART 2: DATA PREPROCESSING
# ==============================================================================
cat("[2/8] Data preprocessing...\n")

# Clean data
df <- df %>%
  filter(!is.na(masterCategory) & masterCategory != "",
         !is.na(subCategory) & subCategory != "",
         !is.na(articleType) & articleType != "")

cat(sprintf("After cleaning: %s rows\n", format(nrow(df), big.mark = ",")))

# Handle missing values
if("baseColour" %in% names(df)) df$baseColour[is.na(df$baseColour) | df$baseColour == ""] <- "Unknown"
if("season" %in% names(df)) df$season[is.na(df$season) | df$season == ""] <- "Unknown"
if("usage" %in% names(df)) df$usage[is.na(df$usage) | df$usage == ""] <- "Unknown"
if("gender" %in% names(df)) df$gender[is.na(df$gender) | df$gender == ""] <- "Unknown"

cat("\n--- Category Hierarchy ---\n")
cat(sprintf("Master Categories: %d\n", length(unique(df$masterCategory))))
print(sort(table(df$masterCategory), decreasing = TRUE))

# ==============================================================================
# PART 3: CROSS-CATEGORY ASSORTMENT PATTERNS
# ==============================================================================
cat("\n[3/8] Analyzing cross-category patterns...\n")

master_cat_dist <- sort(table(df$masterCategory), decreasing = TRUE)

# Create visualizations
png("category_distribution.png", width = 1600, height = 1200, res = 150)
par(mfrow = c(2, 2), mar = c(8, 10, 4, 2))

barplot(master_cat_dist, horiz = TRUE, las = 1, 
        main = "Product Distribution by Master Category",
        xlab = "Number of Products", col = rainbow(length(master_cat_dist)))
grid()

sub_cat_dist <- head(sort(table(df$subCategory), decreasing = TRUE), 15)
barplot(sub_cat_dist, horiz = TRUE, las = 1,
        main = "Top 15 Sub Categories",
        xlab = "Number of Products", col = heat.colors(15))
grid()

article_dist <- head(sort(table(df$articleType), decreasing = TRUE), 15)
barplot(article_dist, horiz = TRUE, las = 1,
        main = "Top 15 Article Types",
        xlab = "Number of Products", col = terrain.colors(15))
grid()

par(mar = c(2, 2, 4, 2))
pie(master_cat_dist, main = "Master Category Proportion",
    col = rainbow(length(master_cat_dist)), cex = 0.8)

dev.off()
cat("✓ Saved: category_distribution.png\n")

# ==============================================================================
# PART 4: CLUSTERING ANALYSIS
# ==============================================================================
cat("\n[4/8] Product clustering...\n")

# Select and encode features
clustering_features <- c('masterCategory', 'subCategory', 'articleType', 
                        'gender', 'baseColour', 'season', 'usage')

df_cluster <- df[, clustering_features]
df_encoded <- df_cluster
for(col in names(df_cluster)) {
  df_encoded[[col]] <- as.numeric(as.factor(df_cluster[[col]]))
}
df_scaled <- scale(df_encoded)

# Elbow method
cat("Determining optimal clusters...\n")
set.seed(42)
wss <- numeric(9)
for(k in 2:10) {
  cat(sprintf("  Testing k=%d...\n", k))
  kmeans_result <- kmeans(df_scaled, centers = k, nstart = 10, iter.max = 100)
  wss[k-1] <- kmeans_result$tot.withinss
}

png("elbow_curve.png", width = 1000, height = 600, res = 150)
plot(2:10, wss, type = "b", pch = 19, col = "blue",
     xlab = "Number of Clusters (k)", 
     ylab = "Within-cluster Sum of Squares",
     main = "Elbow Method For Optimal k")
grid()
dev.off()
cat("✓ Saved: elbow_curve.png\n")

# K-means with k=5
optimal_k <- 5
cat(sprintf("\nPerforming K-Means with k=%d...\n", optimal_k))
set.seed(42)
kmeans_result <- kmeans(df_scaled, centers = optimal_k, nstart = 25, iter.max = 100)
df$cluster <- as.factor(kmeans_result$cluster)

# Analyze clusters
cat("\n--- Cluster Analysis ---\n")
for(cluster_id in 1:optimal_k) {
  cluster_data <- df %>% filter(cluster == cluster_id)
  cat(sprintf("\nCluster %d (%s products, %.1f%%):\n", 
              cluster_id, 
              format(nrow(cluster_data), big.mark = ","),
              nrow(cluster_data)/nrow(df)*100))
  
  cat("  Top MasterCategories:\n")
  top_master <- head(sort(table(cluster_data$masterCategory), decreasing = TRUE), 3)
  for(i in 1:min(3, length(top_master))) {
    cat(sprintf("    - %s: %s\n", names(top_master)[i], top_master[i]))
  }
}

# PCA visualization
cat("\n✓ Creating PCA visualization...\n")
pca_result <- prcomp(df_scaled, center = FALSE, scale. = FALSE)
pca_data <- as.data.frame(pca_result$x[, 1:2])
pca_data$cluster <- df$cluster
var_explained <- pca_result$sdev^2 / sum(pca_result$sdev^2)

png("cluster_visualization.png", width = 1200, height = 800, res = 150)
plot(pca_data$PC1, pca_data$PC2, 
     col = as.numeric(pca_data$cluster),
     pch = 20, cex = 0.5,
     xlab = sprintf("PC1 (%.1f%% variance)", var_explained[1] * 100),
     ylab = sprintf("PC2 (%.1f%% variance)", var_explained[2] * 100),
     main = "Product Clusters (PCA Visualization)")
legend("topright", legend = 1:optimal_k, col = 1:optimal_k, pch = 20, title = "Cluster")
grid()
dev.off()
cat("✓ Saved: cluster_visualization.png\n")

# ==============================================================================
# PART 5: HIERARCHICAL CLUSTERING
# ==============================================================================
cat("\n[5/8] Hierarchical clustering...\n")

sample_size <- min(1000, nrow(df))
set.seed(42)
sample_idx <- sample(1:nrow(df), sample_size)
df_sample <- df_scaled[sample_idx, ]

cat(sprintf("Computing on %d samples...\n", sample_size))
hc_result <- hclust(dist(df_sample), method = "ward.D2")

png("dendrogram.png", width = 1500, height = 800, res = 150)
plot(hc_result, labels = FALSE, hang = -1,
     main = "Hierarchical Clustering Dendrogram",
     xlab = "Sample Index", ylab = "Distance")
dev.off()
cat("✓ Saved: dendrogram.png\n")

# ==============================================================================
# PART 6: PREDICTIVE MODELING
# ==============================================================================
cat("\n[6/8] Training Random Forest classifier...\n")

# Function to group rare categories
group_rare_categories <- function(x, top_n = 50) {
  freq_table <- table(x)
  top_categories <- names(sort(freq_table, decreasing = TRUE)[1:min(top_n, length(freq_table))])
  x_grouped <- ifelse(x %in% top_categories, x, "Other")
  return(x_grouped)
}

# Create modeling dataset with grouped categories
df_model <- df %>%
  select(subCategory, articleType, masterCategory) %>%
  mutate(
    subCategory_grouped = group_rare_categories(subCategory, 40),
    articleType_grouped = group_rare_categories(articleType, 40)
  ) %>%
  na.omit()

# Add other features
if("gender" %in% names(df)) {
  df_model$gender <- df$gender[match(rownames(df_model), rownames(df))]
}
if("baseColour" %in% names(df)) {
  df_model$baseColour_grouped <- group_rare_categories(df$baseColour[match(rownames(df_model), rownames(df))], 30)
}
if("season" %in% names(df)) {
  df_model$season <- df$season[match(rownames(df_model), rownames(df))]
}
if("usage" %in% names(df)) {
  df_model$usage_grouped <- group_rare_categories(df$usage[match(rownames(df_model), rownames(df))], 30)
}

# Select features
feature_cols <- c('subCategory_grouped', 'articleType_grouped')
if("gender" %in% names(df_model)) feature_cols <- c(feature_cols, 'gender')
if("baseColour_grouped" %in% names(df_model)) feature_cols <- c(feature_cols, 'baseColour_grouped')
if("season" %in% names(df_model)) feature_cols <- c(feature_cols, 'season')
if("usage_grouped" %in% names(df_model)) feature_cols <- c(feature_cols, 'usage_grouped')

# Create final dataset
df_model_final <- df_model %>%
  select(all_of(c(feature_cols, 'masterCategory'))) %>%
  na.omit()

# Convert to factors
for(col in c(feature_cols, 'masterCategory')) {
  df_model_final[[col]] <- as.factor(df_model_final[[col]])
}

cat(sprintf("\nFinal modeling dataset: %s products\n", format(nrow(df_model_final), big.mark = ",")))

# Split data
set.seed(42)
train_idx <- createDataPartition(df_model_final$masterCategory, p = 0.8, list = FALSE)
train_data <- df_model_final[train_idx, ]
test_data <- df_model_final[-train_idx, ]

cat(sprintf("Training: %s | Testing: %s\n", 
            format(nrow(train_data), big.mark = ","),
            format(nrow(test_data), big.mark = ",")))

# Train Random Forest
cat("\nTraining Random Forest (this may take 3-5 minutes)...\n")
set.seed(42)
rf_model <- randomForest(masterCategory ~ ., 
                         data = train_data,
                         ntree = 100,
                         importance = TRUE)

cat("✓ Training complete!\n")

# Predictions and evaluation
predictions <- predict(rf_model, test_data)
accuracy <- sum(predictions == test_data$masterCategory) / nrow(test_data)
cat(sprintf("\n✓ Model Accuracy: %.2f%%\n", accuracy * 100))

# Confusion Matrix
conf_matrix <- confusionMatrix(predictions, test_data$masterCategory)
cat("\n--- Confusion Matrix ---\n")
print(conf_matrix$table)

# Feature importance
feature_importance <- importance(rf_model)
importance_df <- data.frame(
  Feature = rownames(feature_importance),
  Importance = feature_importance[, "MeanDecreaseGini"]
)
importance_df <- importance_df[order(-importance_df$Importance), ]

cat("\n--- Feature Importance ---\n")
print(importance_df)

# Visualizations
png("feature_importance.png", width = 1000, height = 600, res = 150)
par(mar = c(5, 12, 4, 2))
barplot(importance_df$Importance, 
        names.arg = importance_df$Feature,
        horiz = TRUE, las = 1,
        main = "Feature Importance for MasterCategory Prediction",
        xlab = "Importance Score (Mean Decrease Gini)",
        col = "steelblue")
grid()
dev.off()
cat("✓ Saved: feature_importance.png\n")

png("confusion_matrix.png", width = 1000, height = 800, res = 150)
conf_matrix_table <- as.matrix(conf_matrix$table)
conf_matrix_df <- melt(conf_matrix_table)
colnames(conf_matrix_df) <- c("Actual", "Predicted", "Count")

p <- ggplot(conf_matrix_df, aes(x = Predicted, y = Actual, fill = Count)) +
  geom_tile() +
  geom_text(aes(label = Count), color = "white", size = 4) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  theme_minimal() +
  labs(title = "Confusion Matrix - MasterCategory Prediction",
       x = "Predicted", y = "Actual") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p)
dev.off()
cat("✓ Saved: confusion_matrix.png\n")

# ==============================================================================
# PART 7: CROSS-CATEGORY RELATIONSHIPS
# ==============================================================================
cat("\n[7/8] Analyzing cross-category relationships...\n")

# Gender distribution
if("gender" %in% names(df) && length(unique(df$gender)) > 1) {
  gender_master <- prop.table(table(df$masterCategory, df$gender), margin = 1) * 100
  
  png("gender_master_category.png", width = 1200, height = 600, res = 150)
  gender_df <- as.data.frame(gender_master)
  colnames(gender_df) <- c("MasterCategory", "Gender", "Percentage")
  
  p <- ggplot(gender_df, aes(x = MasterCategory, y = Percentage, fill = Gender)) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    labs(title = "Gender Distribution Across Master Categories",
         x = "Master Category", y = "Percentage (%)") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  print(p)
  dev.off()
  cat("✓ Saved: gender_master_category.png\n")
}

# Season distribution
if("season" %in% names(df) && length(unique(df$season)) > 1) {
  season_master <- prop.table(table(df$masterCategory, df$season), margin = 1) * 100
  
  png("season_master_category.png", width = 1200, height = 600, res = 150)
  season_df <- as.data.frame(season_master)
  colnames(season_df) <- c("MasterCategory", "Season", "Percentage")
  
  p <- ggplot(season_df, aes(x = MasterCategory, y = Percentage, fill = Season)) +
    geom_bar(stat = "identity") +
    theme_minimal() +
    labs(title = "Season Distribution Across Master Categories",
         x = "Master Category", y = "Percentage (%)") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  print(p)
  dev.off()
  cat("✓ Saved: season_master_category.png\n")
}

# ==============================================================================
# PART 8: SUMMARY
# ==============================================================================
cat("\n[8/8] Summary\n")
cat("================================================================================\n")
cat("ANALYSIS COMPLETE!\n")
cat("================================================================================\n\n")

cat("--- KEY FINDINGS ---\n")
cat(sprintf("Total Products: %s\n", format(nrow(df), big.mark = ",")))
cat(sprintf("Master Categories: %d\n", length(unique(df$masterCategory))))
cat(sprintf("Optimal Clusters: %d\n", optimal_k))
cat(sprintf("Random Forest Accuracy: %.2f%%\n", accuracy * 100))

cat("\n--- Generated Files ---\n")
cat("  1. category_distribution.png\n")
cat("  2. elbow_curve.png\n")
cat("  3. cluster_visualization.png\n")
cat("  4. dendrogram.png\n")
cat("  5. feature_importance.png\n")
cat("  6. confusion_matrix.png\n")
cat("  7. gender_master_category.png\n")
cat("  8. season_master_category.png\n")

cat(sprintf("\n✓ All files saved to: %s\n", getwd()))
cat("\n================================================================================\n")
