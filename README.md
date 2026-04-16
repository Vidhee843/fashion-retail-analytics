# Fashion Retail Analytics — Clustering & Classification 👗

An end-to-end retail analytics project using unsupervised and supervised machine learning to segment fashion products and build a high-accuracy category classifier in R.

## Overview
Analyzed **42,388 fashion products** using K-Means clustering and PCA for segmentation, then built a Random Forest classifier achieving near-perfect accuracy in predicting product categories.

## Key Results
- 🎯 Random Forest accuracy: **99.96%** across 7 master product categories
- 📦 Identified **5 distinct product segments** explaining 45.2% of total variance (PC1 & PC2)
- 💰 Delivered ROI-backed recommendations with projected **18–24 month payback period**

## Tech Stack
- **Language:** R
- **Methods:** K-Means Clustering, PCA, Random Forest, Elbow Method
- **Libraries:** ggplot2, caret, randomForest, factoextra

## Project Structure
```
fashion-retail-analytics/
│
├── data/                   # Product dataset (42,388 records)
├── scripts/
│   ├── clustering.R        # K-Means + PCA analysis
│   ├── classification.R    # Random Forest classifier
│   └── visualization.R     # ggplot2 visualizations
├── outputs/                # Cluster plots, confusion matrix, feature importance
└── README.md
```

## Methodology
### Clustering (Unsupervised)
- Applied **K-Means** with k=5 selected via elbow method
- Used **PCA** for dimensionality reduction and visualization
- PC1 and PC2 explain **45.2% of total variance**

### Classification (Supervised)
- Built **Random Forest** with 100 trees, 80/20 train-test split
- Achieved **99.96% test accuracy** across 7 product classes
- Feature importance analysis revealed key product attributes

## Business Recommendations
1. **Automated product tagging** using the trained classifier
2. **Cluster-based merchandising** aligned to the 5 identified segments
3. **Seasonal inventory planning** informed by cluster demand patterns

## How to Run
```r
# Run clustering analysis
source("scripts/clustering.R")

# Run classification
source("scripts/classification.R")

# Generate visualizations
source("scripts/visualization.R")
```

## Course
MISM 6200 — Introduction to Business Analytics, Northeastern University (Fall 2024). Prof. Christoph Riedl.
