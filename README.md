# Olist Logistics & Customer Experience Analysis

An end-to-end data analytics project analyzing how delivery performance, seller risk, freight costs, and product categories influence customer satisfaction in the Brazilian e-commerce marketplace.

The project combines **SQL, Python, Power BI, and business analysis** to move from raw transactional data to measurable insights and practical recommendations.

---

## Project Overview

Customer satisfaction in e-commerce depends on more than the product itself. Delivery delays, freight costs, seller performance, and product-related issues can all influence how customers evaluate their experience.

This project analyzes the Brazilian E-Commerce Public Dataset by Olist to understand the operational factors behind customer dissatisfaction.

The analysis follows the complete analytics workflow:

- Data exploration and preparation
- SQL analysis and transformation
- Python-based exploratory analysis
- Seller risk segmentation
- Power BI dashboard development
- Business insights and recommendations

The goal was not simply to build a dashboard, but to identify **where customer experience breaks down and what actions the business could take to improve it**.

---

# Key Results at a Glance

| Metric | Result |
|---|---:|
| Total Orders | 96K |
| On-Time Delivery Rate | 91.9% |
| Average Customer Review | 4.16 / 5 |
| Dissatisfied Customer Rate | 12.8% |

While the overall numbers suggest strong marketplace performance, the deeper analysis reveals significant differences across delivery conditions, seller segments, freight costs, and product categories.

---

# Key Business Insights

## 1. Delivery Reliability Is the Strongest Driver of Customer Experience

The clearest finding from the analysis is the relationship between delivery performance and customer dissatisfaction.

- **On-time deliveries:** approximately **7% dissatisfied**
- **High-delay deliveries:** approximately **42% dissatisfied**
- Late deliveries are therefore roughly **4.7x more likely to result in customer dissatisfaction**

Customers whose orders arrived on time gave substantially stronger reviews, while satisfaction declined as delivery delays became more severe.

**Business takeaway:** Delivery reliability is not simply an operational metric. It has a direct and significant impact on customer experience.

---

## 2. High-Delay Orders Represent a Major Customer Experience Risk

The analysis shows that severe delivery delays create a disproportionate level of dissatisfaction.

Orders delayed by more than a week showed the highest dissatisfaction levels, reaching approximately **42%**.

This means that even though most orders are delivered successfully and on time, a relatively smaller group of severely delayed orders can create a significant customer experience problem.

**Business takeaway:** The business should not only measure the overall on-time delivery rate. It should actively identify and manage orders at risk of becoming severely delayed.

---

## 3. Seller Performance Is Not Uniform

Sellers were segmented into four operational groups:

- **Strong Performers**
- **Delivery Risk**
- **Customer/Product Risk**
- **Critical Sellers**

The segmentation shows that seller performance varies significantly across the marketplace.

Strong Performers handled the largest share of order volume and maintained strong customer review performance. The other segments represent different sources of operational risk, including delivery issues and customer/product-related dissatisfaction.

**Business takeaway:** A single marketplace-wide seller metric can hide important differences. Seller segmentation allows the business to focus attention on the sellers creating the greatest customer experience risk.

---

## 4. Freight Costs Are Higher for Dissatisfied Customers

The analysis found that dissatisfied customers had a higher average freight cost than satisfied customers.

The same pattern was visible when comparing the **freight-to-product-price ratio**. Customers were more likely to be dissatisfied when delivery costs represented a larger share of the product value.

This does not prove that freight cost alone causes dissatisfaction, but it suggests that shipping costs can compound a poor customer experience.

**Business takeaway:** Freight pricing should be analyzed together with delivery performance and customer satisfaction rather than treated only as a logistics cost.

---

## 5. Certain Product Categories Show Higher Dissatisfaction

The dashboard identified product categories with noticeably higher dissatisfaction levels.

Examples include categories related to:

- Furniture and office products
- Audio
- Home and comfort
- Construction
- Telephony

These categories may have different operational challenges, such as delivery complexity, product expectations, packaging issues, or seller performance.

**Business takeaway:** High-dissatisfaction categories should be investigated individually rather than applying the same solution across the entire marketplace.

---

## 6. Customer Satisfaction Needs Continuous Monitoring

The time-series analysis shows that customer satisfaction was relatively stable for much of the observed period but still experienced noticeable fluctuations.

A strong overall average review score can therefore hide temporary operational problems.

**Business takeaway:** Customer experience metrics should be monitored over time alongside delivery and seller performance metrics so emerging issues can be identified earlier.

---

# Business Recommendations

## 1. Proactively Flag High-Risk Orders

Orders associated with severe delivery risk should be identified before the customer experiences the delay.

Priority monitoring should focus on:

- Orders at risk of becoming severely delayed
- High-risk delivery routes
- Sellers classified in higher-risk segments

Customers should receive proactive communication when delays are likely instead of waiting until the expected delivery date has already passed.

**Expected impact:** Reduced customer frustration and improved transparency.

---

## 2. Prioritize Critical and High-Risk Sellers

Seller risk segmentation should be used as an operational management tool.

The business can:

- Monitor Critical Sellers more closely
- Investigate recurring delivery issues
- Compare weaker sellers against Strong Performer benchmarks
- Introduce improvement plans for sellers with persistent customer experience problems

**Expected impact:** More targeted intervention instead of treating all sellers equally.

---

## 3. Investigate High-Dissatisfaction Product Categories

Product categories with consistently high dissatisfaction should be analyzed at a more detailed level.

The investigation should consider:

- Delivery performance
- Seller performance
- Freight costs
- Product characteristics
- Packaging
- Customer reviews

For example, large or complex products may create additional delivery and customer expectation challenges.

**Expected impact:** Category-specific actions can address the actual source of dissatisfaction.

---

## 4. Review Freight Cost Relative to Product Value

Since dissatisfied customers showed higher freight costs and a higher freight-to-product-price ratio, shipping pricing should be reviewed for categories where delivery cost represents a large proportion of product value.

Potential actions include:

- Testing targeted freight subsidies
- Optimizing shipping options
- Reviewing pricing for low-value products with relatively high freight charges
- Negotiating improved logistics arrangements for high-cost categories

**Expected impact:** A better balance between customer value perception and delivery cost.

---

## 5. Track Severe Delays Separately from Overall On-Time Performance

The overall on-time delivery rate of **91.9%** provides a useful summary, but it does not fully show the customer impact of severe delays.

The dashboard should therefore be used to monitor:

- Overall on-time delivery rate
- High-delay order volume
- Dissatisfaction by delay severity
- Seller risk performance
- Customer review trends

**Expected impact:** Earlier identification of the operational problems with the greatest effect on customer satisfaction.

---

# Interactive Dashboard

The Power BI dashboard is divided into two analytical views.

## Executive Overview

The first page provides a high-level view of:

- Total orders
- On-time delivery rate
- Average customer review
- Dissatisfied customer rate
- Order volume by delivery severity
- Customer satisfaction distribution
- Seller risk segmentation
- Product categories with high dissatisfaction

## Customer Experience & Risk Analysis

The second page provides deeper analysis of:

- Average freight cost by customer satisfaction
- Freight-to-product-price ratio
- Order volume by seller risk segment
- Average customer review by seller risk segment
- Average customer review by delivery delay severity
- Customer satisfaction and dissatisfaction trends over time

Interactive filters allow users to investigate delivery categories, product categories, and seller risk segments.

---

# Dashboard Preview

![Executive Overview](Images/Executive%20Veiw.png)

![Customer Experience & Risk Analysis](Images/risk_analysis.png)

---

# Tools and Technologies

| Tool | Purpose |
|---|---|
| **SQL** | Data cleaning, transformation, joins, and business analysis |
| **Python** | Exploratory data analysis and deeper investigation |
| **Power BI** | Interactive dashboard development and visualization |
| **GitHub** | Project documentation and portfolio presentation |

---

# Project Structure

```text
olist-logistics-customer-experience-analysis/
│
├── Data/
│   └── README.md
│
├── Images/
│   └── Dashboard screenshots and project visuals
│
├── Notebooks/
│   └── Python analysis notebooks
│
├── Power_Bi/
│   └── Power BI dashboard files
│
├── Sql/
│   └── SQL queries and analysis scripts
│
├── Olist_Business_Insights_Report.pdf
│
└── README.md
