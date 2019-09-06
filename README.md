# YellowTaxiAnalysis

In this assignment, New York City Taxi trip data for January 2018 is analysed using Python and SQL(MSSQL). <br/>

Trip records include fields such as; pick-up & drop-off dates, pick-up & drop-off locations, trip distances, rate types, payment types and tips. The taxi zone data is used for the name of zones and borough.<br/>

The requirements of the analysis are:<br/>
•	Receive as arguments the input path for the CSV file and an output path to save the results.<br/>
•	Ingest the CSV file and store it in a place of your choice (Parquet file, Postgres, MySQL, MongoDB, etc).<br/>
•	Query the stored data to generate two CSV reports:<br/>
      o	top_tipping_zones.csv: Top 5 Dropoff Zones that pay the highest amount of tips.<br/>
      o	longest_trips_per_day.csv: Top 5 longest trips per day of the first week of January 2018.<br/>

In Python application, all requirements are covered. For downloading data two alternatives are served. In one python file, urllib is used to download data files. The other one, data should be downloaded to inputpath before execution. After that, yellow taxi trip data are ingested and stored in Parquet file. Pandas dataframe is used for analysis. Finally, two csv reports, that are in requirements, are generated from dataframes.<br/>

In SQL application, MSSQL 2017 is used. Bulk insert is used to fetch data and stored in tables. Bcp utility and xp_cmdshell are used to export results. <br/>

## Python:
The following steps should be followed. Please be aware of two option about downloading data files. Details are in step 3.
1. Prerequisites are Python3 and pip. These should be already installed. <br/>

2. To install required libraries and their dependencies <b>requirements.txt</b> file is used under the Python folder.<br/>
<pre><code>pip install -r requirements.txt<br/>
</code></pre>
3. There are two options. One is for manually download data files and the other for automatically download files when executing final python file.<br/>
<pre><code>To download data files manually please uses the following links: <br/>

yellow_tripdata_2018-01: <a href="url">https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-01.csv</a><br/>
taxi_zone: <a href="url">https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv</a><br/>

Data dictionary:<br/>
<a href="url">https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf</a><br/>
</code></pre>

4. To run the code:<br/>

4.1. Who download file in step 3, should use YellowTaxi_wo_Download.py<br/>
<pre><code>Inputpath should be the path where data files already dowloaded.<br/>

python YellowTaxi_wo_Download.py --inputpath YourInputPath --outputpath YourOutputPath <br/>

<i>Example:<br/>
python YellowTaxi_wo_Download.py --inputpath C:/Users/dkantar/Desktop/DET4/ --outputpath C:/Users/dkantar/Desktop/DET4/</i><br/>

<b><i>Warning: Please do not forget "/" end of your paths</i></b> </code></pre><br/>

4.2. Who does not download file in step 3, should use YellowTaxi_w_Download.py<br/>
<pre><code>python YellowTaxi_w_Download.py --inputpath YourInputPath --outputpath YourOutputPath <br/>

<i>Example:<br/>
python YellowTaxi_w_Download.py --inputpath C:/Users/dkantar/Desktop/DET4/ --outputpath C:/Users/dkantar/Desktop/DET4/</i><br/>

<b><i>Warning: Please do not forget "/" end of your paths</i></b><br/> </code></pre>



## SQL:
MSSQL 2017 is used in this application. The following steps should be followed
1. To download SQL Server 2017 Express Edition, the following link can be used. Express Edition is free edition.<br/>
<pre><code><a href="url">https://go.microsoft.com/fwlink/?linkid=853017</a><br/></code></pre>

2. To install SQL Server 2017 Express Edition the following link can be used. SQL Server Management Studio should be installed.<br/>
<pre><code><a href="url">https://www.mssqltips.com/sqlservertip/5528/installing-sql-server-2017-express/ </a><br/></code></pre>

3. Open SQL Server Management Studio and connect Database Engine.<br/>

4. To create database, <b>DBCreate.sql</b> be used. <br/> 
<pre><code>By copy paste scripts to New Query window/open File with Existing Connection options.<br/></code></pre>

5. To export results to csv file xp_cmdshell is used. Some SQL server settings should be change to use xp_cmdshell.<br/>
 <pre><code>Open New Query window. Change SQLServer Configurations.<br/>
 --this turns on advanced options and is needed to configure xp_cmdshell <br/>
 sp_configure 'show advanced options', '1'  <br/>
 RECONFIGURE <br/>
 --this enables xp_cmdshell <br/>
 sp_configure 'xp_cmdshell', '1'  <br/>
 RECONFIGURE <br/>
</code></pre>
6. To download data files manually please uses the following links:<br/>
 <pre><code>yellow_tripdata_2018-01: https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-01.csv<br/>
taxi_zone: https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv<br/>

Data dictionary:<br/>
https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf<br/>
</code></pre>

7. To create NYCTaxi procedure, <b>NYCTaxi.sql</b> should be executed.<br/>

8. Last step executing the procedure, input parameters of the procedure is inputpath and outputpath.<br/>
<pre><code>Inputpath should be the path where <b>yellow_tripdata_2018-01.csv</b> and <b>taxi_zone files.csv</b> are stored.<br/>
Outputpath should be the path where the outputs are created.<br/>
<b><i>Warning:For both folders check permissions for the account running SQL Server Agent</i></b><br/>

EXEC	[dbo].[NYCTaxi]<br/>
@inputpath = N'YourPAth',<br/>
@outputpath = N'YourPAth'<br/>

<i>Example:<br/>
EXEC	[dbo].[NYCTaxi]<br/>
@inputpath = N'D:\SQLData\',<br/>
@outputpath = N'D:\SQLData\'<br/></i>

<b><i>Warning: Please do not forget "\" end of your paths</i></b><br/> </code></pre>
