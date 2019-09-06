create procedure NYCTaxi @inputpath nvarchar(max), @outputpath nvarchar(max) 
as
BEGIN

CREATE TABLE [dbo].[TaxiZone](
	[LocationID] [nvarchar](max) NULL,
	[Borough] [nvarchar](max) NULL,
	[Zone] [nvarchar](max) NULL,
	[service_zone] [nvarchar](max) NULL
) ON [PRIMARY]

--Insert zone csv file to table
DECLARE @sqlInsertZone NVARCHAR(4000) = 'BULK INSERT [TaxiZone] FROM ''' + @inputpath + 'taxi+_zone_lookup.csv'' WITH ( FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR =''\n'',TABLOCK )';
EXEC(@sqlInsertZone)


CREATE TABLE [dbo].[YellowTrip](
	[VendorID] [int] NULL,
	[tpep_pickup_datetime] [datetime] NULL,
	[tpep_dropoff_datetime] [datetime] NULL,
	[passenger_count] [int] NULL,
	[trip_distance] [decimal](38, 2) NULL,
	[RatecodeID] [nvarchar](max) NULL,
	[store_and_fwd_flag] [varchar](max) NULL,
	[PULocationID] [nvarchar](max) NULL,
	[DOLocationID] [nvarchar](max) NULL,
	[payment_type] [nvarchar](max) NULL,
	[fare_amount] [nvarchar](max) NULL,
	[extra] [nvarchar](max) NULL,
	[mta_tax] [nvarchar](max) NULL,
	[tip_amount] [decimal](38, 2) NULL,
	[tolls_amount] [nvarchar](max) NULL,
	[improvement_surcharge] [nvarchar](max) NULL,
	[total_amount ] [nvarchar](max) NULL
) ON [PRIMARY]

--Insert YellowTrip csv file to table
DECLARE @sqlInsertYellowTrip NVARCHAR(4000) = 'BULK INSERT [YellowTrip] FROM ''' + @inputpath + 'yellow_tripdata_2018-01.csv'' WITH ( FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR =''\n'',TABLOCK )';
EXEC(@sqlInsertYellowTrip);


--Top 5 Dropoff Zones that pay the highest amount of tips
select top (5) replace([Borough],'"','') as Borough, replace([Zone],'"','') as Zone, sum([tip_amount]) as total_tip_amount
into top_tipping_zones
from [dbo].[YellowTrip] as YT
inner join [dbo].[TaxiZone] as TZ on YT.[DOLocationID]=TZ.[LocationID]
group by [Borough],[Zone]
order by sum([tip_amount]) desc

--Export top_tipping_zones
declare @sqlExportTopTippingZone varchar(8000)
select @sqlExportTopTippingZone =  'bcp "select * from [NYCTaxiDB].[dbo].top_tipping_zones" queryout ' + @outputpath +'top_tipping_zones.csv -c -t, -T ' 
exec master..xp_cmdshell @sqlExportTopTippingZone



select 
convert(nvarchar,[tpep_dropoff_datetime],103) as 'dropoff_date', [tpep_dropoff_datetime], [DOLocationID], [Borough], [Zone]
,max([trip_distance]) as max_trip_distance
into ##tempMaxTripDistance
from [dbo].[YellowTrip] as YT
inner join [dbo].[TaxiZone] as TZ on YT.[DOLocationID]=TZ.[LocationID]
where convert(nvarchar, [tpep_dropoff_datetime], 112) <'20180108' and convert(nvarchar,[tpep_dropoff_datetime],112) >='20180101' 
	and [DOLocationID] is not null 
	and  [Borough]<>'"Unknown"' 
	and [Zone] <>'"NA"'
group by  [Borough], [Zone], [tpep_dropoff_datetime], convert(nvarchar,[tpep_dropoff_datetime],103), [DOLocationID]


select dropoff_date, [tpep_dropoff_datetime], replace([Borough],'"','') as [Borough], replace([Zone],'"','') as [Zone], max_trip_distance 
into longest_trips_per_day 
from (
	select dropoff_date, [tpep_dropoff_datetime], [Borough], [Zone], max_trip_distance, 
	dense_rank() over (partition by dropoff_date order by max_trip_distance desc ) as dayrank
	from ##tempMaxTripDistance
	) MaxTripDistance
where  dayrank<=5

declare @sqlExportLongestTrips varchar(8000)
select @sqlExportLongestTrips =  'bcp "select * from [NYCTaxiDB].[dbo].longest_trips_per_day" queryout ' + @outputpath +'longest_trips_per_day.csv -c -t, -T ' 
 
exec master..xp_cmdshell @sqlExportLongestTrips


END
