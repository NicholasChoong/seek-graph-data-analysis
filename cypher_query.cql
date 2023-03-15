// How many jobs are advertised for a given job category in a specified city?
WITH "Sydney" AS specifiedCity
MATCH (city:City {name: specifiedCity})-[:BASED_IN]-(job:Job_id)-[:CATEGORISED_AS]-(category:Category)
RETURN city.name AS city, category.name AS category, COUNT(job) AS NumberOfJobs
ORDER BY NumberOfJobs DESC

// Find job_ids that share the same job_title.
MATCH (jobTitle:Job_title)-[:IS_TITLED]-(job:Job_id)
RETURN jobTitle.title AS JobTitle, COLLECT(job.jobID) AS JobIdList

// Find all companies that offer jobs in different categories.
MATCH (company:Company)-[:IS_OFFERING]-(:Job_id)-[:CATEGORISED_AS]-(category:Category)
WITH company, COUNT( DISTINCT category) as categoryCount
WHERE categoryCount >= 2
RETURN company.name as company, categoryCount
ORDER BY categoryCount DESC

// Find jobs based on the presence of a keyword.
WITH "Developer" AS keyword
MATCH (job:Job_id)--(n)
MATCH (job)--(company:Company)
MATCH (job)--(jobTitle:Job_title)
MATCH (job)--(jobType:Job_type)
MATCH (job)--(city:City)--(state:State)
WHERE n.date CONTAINS keyword OR n.name CONTAINS keyword OR n.title CONTAINS keyword 
    OR n.type CONTAINS keyword or state.name CONTAINS keyword
RETURN job.jobID AS jobID, company.name AS company, jobTitle.title AS jobTitle, 
    jobType.type AS jobType, job.hourly_salary AS hourlySalary, 
    city.name AS city, state.name AS state

// Find jobs posted during a specified period of time.
WITH "2018-4-11" AS startDate, "2018-4-13" AS endDate
MATCH (job:Job_id)--(n)
MATCH (job)--(company:Company)
MATCH (job)--(jobTitle:Job_title)
MATCH (job)--(jobType:Job_type)
MATCH (job)--(city:City)--(state:State)
WHERE DATE(n.date) >= DATE(startDate) AND DATE(n.date) <= DATE(endDate) 
RETURN job.jobID AS jobID, company.name AS company, jobTitle.title AS jobTitle, 
    jobType.type AS jobType, job.hourly_salary AS hourlySalary, 
    city.name AS city, state.name AS state, n.date AS date

// Find the number of jobs in each job type.
MATCH (job: Job_id)--(jobType:Job_type)
RETURN jobType.type AS jobType, COUNT(job) AS jobCount
ORDER BY jobCount DESC

// Find jobs that pay more than zero.
MATCH (job:Job_id)--(company:Company)
MATCH (job)--(jobTitle:Job_title)
MATCH (job)--(jobType:Job_type)
MATCH (job)--(city:City)--(state:State)
WHERE job.hourly_salary > 0
RETURN job.jobID AS jobID, company.name AS company, jobTitle.title AS jobTitle, 
    jobType.type AS jobType, job.hourly_salary AS hourlySalary, 
    city.name AS city, state.name AS state

// Find the number of jobs in each city.
MATCH (job: Job_id)--(city:City)
RETURN city.name AS city, COUNT(job) AS jobCount
ORDER BY jobCount DESC