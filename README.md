
# 🎨 Cross-Category Product Assortment Patterns in Fashion Retail

A clustering and predictive analytics study examining how 42,388 fashion products naturally group across categories and what attributes enable automated categorization.

**Author:** [Your Name]  
**Course:** MISM 6200 - Introduction to Business Analytics  
**Institution:** Northeastern University  
**Date:** December 2024

---

## 📊 Project Overview

### Research Question
How do fashion products naturally cluster across master categories, and what product attributes enable reliable automated categorization?

### Business Problem
Fashion retailers manage extensive product catalogs (40,000+ items) facing challenges with:
- Manual product categorization (labor-intensive and costly)
- Suboptimal merchandising strategies
- Inefficient inventory planning
- Missed cross-selling opportunities

### Key Findings
- ✅ **5 distinct product clusters** identified using K-means clustering
- ✅ **99.96% prediction accuracy** achieved with Random Forest classifier
- ✅ **subCategory is the dominant predictor** (53% of importance)
- ✅ **Clear gender and seasonal patterns** across categories

---

## 🔬 Methodology

### Data Source
- **Dataset:** Fashion Product Images (Kaggle)
- **Size:** 42,388 products
- **Attributes:** 7 master categories, 45 subcategories, 143 article types
- **Features:** Gender, color, season, usage

### Analytical Approach

**1. Unsupervised Learning (Clustering)**
- K-means clustering (k=2-10 tested, k=5 optimal)
- Hierarchical clustering validation
- PCA visualization (45.2% variance explained)

**2. Supervised Learning (Classification)**
- Random Forest classifier (100 trees)
- 80/20 train-test split
- Feature importance analysis

**3. Cross-Category Analysis**
- Gender × Category relationships
- Season × Category patterns
- Color preferences by category

---

## 📈 Key Results

### Clustering Results

| Cluster | Size | % | Primary Category | Description |
|---------|------|---|------------------|-------------|
| 1 | 7,737 | 18.3% | Apparel (73%) | Casual Everyday Wear |
| 2 | 10,056 | 23.7% | Accessories (58%) | Fashion Accessories Hub |
| 3 | 4,167 | 9.8% | Footwear (47%) | Athletic Footwear |
| 4 | 12,657 | 29.9% | Apparel (72%) | Core Apparel Collection |
| 5 | 7,771 | 18.3% | Footwear (72%) | Formal + Personal Care |

### Prediction Performance

- **Accuracy:** 99.96% (8,472/8,475 correct)
- **Perfect accuracy** for Apparel, Footwear, and Personal Care
- **Only 3 misclassifications** in test set

### Feature Importance

| Rank | Feature | Importance Score | % of Total |
|------|---------|-----------------|------------|
| 1 | subCategory | 12,098 | 53.4% |
| 2 | articleType | 6,701 | 29.6% |
| 3 | season | 2,253 | 9.9% |
| 4 | baseColour | 485 | 2.1% |
| 5 | usage | 389 | 1.7% |
| 6 | gender | 309 | 1.4% |

### Cross-Category Patterns

**Gender Distribution:**
- Men dominate: Footwear (62%), Apparel (53%)
- Women dominate: Personal Care (75%), Accessories (47%)

**Seasonal Distribution:**
- Personal Care: 98% Spring products
- Apparel: 59% Summer, 36% Fall
- Accessories: 48% Winter, 40% Summer (balanced)

---

## 💼 Business Recommendations

1. **Automated Categorization System**
   - Deploy Random Forest model for real-time classification
   - Expected: 70-90% reduction in manual tagging labor

2. **Cluster-Based Merchandising**
   - Organize stores/website using 5-cluster framework
   - Expected: 3-7% increase in cross-category sales

3. **Seasonal Inventory Planning**
   - Q2 surge for Personal Care (98% Spring)
   - Q3 peak for Apparel (59% Summer)
   - Expected: 15-20% reduction in carrying costs

4. **Gender-Targeted Marketing**
   - Category-specific campaigns by gender
   - Expected: 20-30% improvement in conversion rates

5. **Data Quality Focus**
   - Prioritize subCategory accuracy (53% of predictive power)

**ROI:** $150K-$300K annual labor savings + 3-5% revenue uplift

---

## 📂 Repository Structure
