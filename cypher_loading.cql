// Loading
LOAD CSV WITH HEADERS FROM 'file:///dim_company.csv' AS row
FIELDTERMINATOR ','
CREATE (comp: Company {companyID: row.PK, name: row.company_name})
RETURN comp

LOAD CSV WITH HEADERS FROM 'file:///dim_job_type.csv' AS row
FIELDTERMINATOR ','
CREATE (jobType: Job_type {jobTypeID: row.PK, type: row.job_type})
RETURN jobType

LOAD CSV WITH HEADERS FROM 'file:///dim_date.csv' AS row
FIELDTERMINATOR ','
CREATE (date: Date {dateID: row.PK, date: date(row.date)})
RETURN date

LOAD CSV WITH HEADERS FROM 'file:///dim_location.csv' AS row
FIELDTERMINATOR '|'
MERGE (state: State {name: row.state})
CREATE (city: City {cityID: row.PK, name: row.city, latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})
CREATE (city)-[r: WITHIN]->(state)
RETURN city, r,  state

CREATE INDEX FOR (comp: Company) ON (comp.companyID)

CREATE INDEX FOR (jobType: Job_type) ON (jobType.jobTypeID)

CREATE INDEX FOR (date: Date) ON (date.dateID)

CREATE INDEX FOR (city: City) ON (city.cityID)

LOAD CSV WITH HEADERS FROM 'file:///fact_table.csv' AS row
FIELDTERMINATOR '~'
MERGE (job: Job_id {jobID: row.PK, hourly_salary: toFloat(COALESCE(row.salary, 0)), title_id: row.job_id})
WITH job, row
MATCH (comp: Company {companyID: row.company_id})
MATCH (jobType: Job_type {jobTypeID: row.job_type_id})
MATCH (date: Date {dateID: row.date_id})
MATCH (city: City {cityID: row.location_id})
CREATE (comp)-[:IS_OFFERING]->(job)
CREATE (job)-[:WORKS]->(jobType)
CREATE (job)-[:POSTED_ON {time: localtime(row.hour + ":" + row.minute + ":" + row.second)}]->(date)
CREATE (job)-[:BASED_IN]->(city)

CREATE INDEX FOR (job: Job_id) ON (job.title_id)

LOAD CSV WITH HEADERS FROM 'file:///dim_job.csv' AS row
FIELDTERMINATOR '|'
MERGE (jobTitle: Job_title {title: row.job_title})
MERGE (category: Category {name: row.category})
WITH row, jobTitle, category
MATCH (job: Job_id {title_id: row.PK})
CREATE (job)-[:IS_TITLED]->(jobTitle)
CREATE (job)-[:CATEGORISED_AS]->(category)

CALL db.schema.visualization

// Cleaning
:schema

DROP INDEX index_2a03763d

DROP INDEX index_3a605622

DROP INDEX index_73154543

DROP INDEX index_9de4a208

DROP INDEX index_b4e0c356

DROP INDEX index_f194ae0f

MATCH (comp: Company)
REMOVE comp.companyID

MATCH (jobType: Job_type)
REMOVE jobType.jobTypeID

MATCH (date: Date)
REMOVE date.dateID

MATCH (city: City)
REMOVE city.cityID

MATCH (job: Job_id)
REMOVE job.title_id

// Test
MATCH (n:Job_id{jobID: "4"})-[r]-(n1)
MATCH (n)-[r2]-(c:City)-[r1]-(s:State)
RETURN  n, r, n1,c, r1,s, r2