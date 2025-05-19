# CABIChallenge


 ## Question 1

 ### Sub question 1
 Avg. resolution time is 1 month and 8 days (rounded down to days)

 ### Sub question 2
 The Max Case cost of a won case is 4700, however these vary greatly depending on the market as seen in the visualization

 ## Question 2

 ### Sub question 1
|client_id|client_name   |client_value|cltv_group|
|---------|--------------|------------|----------|
|C100     |Belgu         |19200       |High      |
|C102     |AFK           |10000       |High      |
|C111     |Gett-E        |9200        |High      |
|C103     |D-PAH         |8500        |High      |
|C104     |PA-tato       |8400        |Medium    |
|C110     |Routers       |8000        |Medium    |
|C101     |NPC           |7200        |Medium    |
|C105     |EFFES         |6600        |Medium    |
|C106     |AN-SAW        |5000        |Low       |
|C108     |Photo-Newsy   |4600        |Low       |
|C109     |NPC-Freelancey|3500        |Low       |
|C107     |E-PAW         |3250        |Low       |

 
 ### Sub question 2
 The exponential weighted average for each of the clients are calculated for each of the clients. This ensures that the value of the most recent case is weighted higher than the older ones, this would most likely be more usefull from a business context, as I assume clients budgets and demands are heavily temporal. 
 
The formula for doing so is given by: 
 
$$\text{EWA} = \frac{\sum_{i=1}^n x_i \cdot e^{-\lambda (i - 1)}}{\sum_{i=1}^n e^{-\lambda (i - 1)}}$$

Where we set $\alpha=0.5$ for this case, $x_i$ is the case value for the corresponding rank $i$

|client_id|client_name   |weighted_avg_case_value|
|---------|--------------|-----------------------|
|C111     |Gett-E        |4624.49                |
|C104     |PA-tato       |4200.00                |
|C110     |Routers       |3987.75                |
|C100     |Belgu         |3788.07                |
|C101     |NPC           |3600.00                |
|C109     |NPC-Freelancey|3500.00                |
|C102     |AFK           |3338.56                |
|C105     |EFFES         |3300.00                |
|C107     |E-PAW         |3250.00                |
|C103     |D-PAH         |2850.65                |
|C106     |AN-SAW        |2524.49                |
|C108     |Photo-Newsy   |2324.49                |

## Question 3









 
