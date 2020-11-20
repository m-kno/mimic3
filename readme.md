# Prediction of Extubation Success in Patients with Acute Respiratory Syndrome 

The authors: [Mirko Knoche](https://github.com/CrazyBigFoot), [Jacqueline Gabriel](https://github.com/gabriel-hd73), [Niko Stergioulas](https://github.com/stervet) and [Nina Notman](https://github.com/NinaNotman)

This project is still **in progress**.

![Emergency_Pixabay](https://user-images.githubusercontent.com/67256213/99786324-a019f100-2b1e-11eb-9d97-84e3a76a71dc.png)


## Overview 

This project is based on the [MIMIC-III, critical care database](https://mimic.physionet.org/). The MIMIC-III is a large, single-center database comprising information relating to patients admitted to critical care units at a large tertiary care hospital. Data includes vital signs, medications, laboratory measurements, observations and notes charted by care providers, fluid balance, procedure codes, diagnostic codes, imaging reports, hospital length of stay, survival data, and more. The database supports applications including academic and industrial research, quality improvement initiatives, and higher education coursework. The following [nature article](https://www.nature.com/articles/sdata201635) gives further information on data selection and description. 

The work in this repository is part of the final assessment of the Data Science Bootcamp at [Neue Fische - School and Pool for Digital Talent](https://www.neuefische.de/). Here, we aim to predict the success of an extubation attempt on intesive care patients suffering from acute respiratory syndrome. Our study design leans on a [study](https://pubmed.ncbi.nlm.nih.gov/23367074/) by Mikhno and colleagues that have predicted the extubation failure for neonates with respirator distress syndrome using the MIMIC-II Clinical Database. 

Business Case: predicting the success likelihood of an extubation may decrease the incidence of failed extubations in Intensive Care Units (ICU). This may significantly contribute to patients health as failed extubations are associated with an increased risk of following unplanned extubations, the use of noninvasive ventilation postextubation, and sepsis ([Lee et al., 2017](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5363101/)). 

The project is intended to cover all stages of the data science cycle:

## Life cycle of data science

- 1 Medical understanding
- 2 Data acquisition
- 3 Data cleansing
- 4 Data Exploration
- 5 Feature Engineering
- 6 Predictive modeling
- 7 Data visualization

## Tools and Technologies used 
Database Management with SQL: PostgreSQL / DBeaver  
Analysis with Python: Pandas / NumPy / scikit-learn / Matplotlib / Seaborn / sklearn

## ML models used
The models were applied and compared for *F0.5-score* 

- Logistic Regression
- Decision Tree
- Random Forest
- XGBoost 
- Adaboost 
- Knn
- Support Vector Machine
 
## Results
- Best performing model, focusing on F0.5 score: 
- Most important features: 

# Conclusion
- 
- 

## Future work
**Title Future Work 1**
- To Do Future Work 1
- To Do Future Work 1 

**Title Future Work 2**
- To Do Future Work 2
- To Do Future Work 2 