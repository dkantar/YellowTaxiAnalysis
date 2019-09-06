# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 01:00:26 2019

@author: dkantar
"""

# -*- coding: utf-8 -*-
"""
@author: dkantar
"""
import click
@click.command()
@click.option(
    '--inputpath',
     required=True,
)
@click.option(
    '--outputpath',
    required=True,
)
def YellowCabs(inputpath, outputpath):
   
    #Download files that are used
    urllib.request.urlretrieve("https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-01.csv", inputpath+"yellow_tripdata_2018-01.csv")
    urllib.request.urlretrieve("https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv", inputpath+"taxi+_zone_lookup.csv")
    
    #Read files and store them to pandas dataframe
    dfTripData = pd.read_csv(inputpath + "yellow_tripdata_2018-01.csv", sep = ",", encoding = "utf-8")

    dfZone = pd.read_csv(inputpath + "taxi+_zone_lookup.csv", sep = ",", encoding = "utf-8")
    
    ##Ingest the CSV file and store it in parguet
    #The following code lines about storage the CSV file. I used the Parquet file for this. 
    #But I think this makes no sense because all things can be done by dataframes. 
    #I only used this because the second point of assignment told that the CVS file should be stored in a place such as Parquet file.
    
    #convert pandas df to table
    tableTD = pa.Table.from_pandas(dfTripData)
    #store table to parquet file
    pq.write_table(tableTD, 'yellow_tripdata.parquet')
    #read from parquet file
    tableTDP = pq.read_table('yellow_tripdata.parquet')
    #convert parquet to pandas df
    dfTripData = tableTDP.to_pandas()
    
    ##Data Cleaning
    dfTripData = dfTripData.dropna(subset = ["DOLocationID"])
    dfTripData = dfTripData.dropna(subset = ["tip_amount"])
    dfTripData = dfTripData.dropna(subset = ["trip_distance"])
    
    #Top 5 Dropoff Zones that pay the highest amount of tips.
    dfTripDataTopTippingZone=dfTripData[["DOLocationID","tip_amount"]]
    dfTripDataTopTippingZone_Grouped = dfTripDataTopTippingZone.groupby("DOLocationID", as_index=False).agg({"tip_amount": "sum"})
    
    #Merge dataframes to obtain zone names
    dfTripDataTopTippingZone_Grouped=pd.merge(dfTripDataTopTippingZone_Grouped, dfZone, left_on="DOLocationID", right_on="LocationID").sort_values(by="tip_amount", ascending=False).head(5)
    dfTripDataTopTippingZone_Grouped[["Borough","Zone","tip_amount"]].to_csv(outputpath+"top_tipping_zones.csv",index=False)
    
    #Top 5 longest trips per day of the first week of January 2018
    
    dfTripDataLongestTrips=dfTripData[["tpep_dropoff_datetime","trip_distance","DOLocationID"]]
    dfTripDataLongestTrips_Grouped=pd.merge(dfTripDataLongestTrips, dfZone, left_on="DOLocationID", right_on="LocationID")
    dfTripDataLongestTrips_Grouped = dfTripDataLongestTrips_Grouped.dropna(subset = ['DOLocationID'])
    dfTripDataLongestTrips_Grouped=dfTripDataLongestTrips_Grouped[dfTripDataLongestTrips_Grouped.Zone!="Unknown"]
    dfTripDataLongestTrips_Grouped=dfTripDataLongestTrips_Grouped[dfTripDataLongestTrips_Grouped.Borough!="Unknown"]
    #Convert tpep_dropoff_datetime column to datetime
    dfTripDataLongestTrips_Grouped["tpep_dropoff_datetime"] = pd.to_datetime(dfTripDataLongestTrips_Grouped["tpep_dropoff_datetime"])
    dfTripDataLongestTrips_Grouped["dropoff_date"] = dfTripDataLongestTrips_Grouped['tpep_dropoff_datetime'].dt.to_period('D')
    
    #Filter first week of January 2018
    dfTripDataLongestTrips_Grouped = dfTripDataLongestTrips_Grouped[dfTripDataLongestTrips_Grouped.dropoff_date < "2018-01-08"] 
    dfTripDataLongestTrips_Grouped = dfTripDataLongestTrips_Grouped[dfTripDataLongestTrips_Grouped.dropoff_date >= "2018-01-01"] 
    dfTripDataLongestTrips_Grouped = dfTripDataLongestTrips_Grouped[["dropoff_date","Borough","Zone","trip_distance","tpep_dropoff_datetime"]].groupby(["dropoff_date"]).apply(lambda x: x.nlargest(5,"trip_distance")).reset_index(level=0, drop=True)
    dfTripDataLongestTrips_Grouped[["dropoff_date","tpep_dropoff_datetime","Borough","Zone", "trip_distance"]].to_csv(outputpath+"longest_trips_per_day.csv",index=False)

 
if __name__ == '__main__':
    import pandas as pd
    import urllib.request
    import pyarrow as pa
    import pyarrow.parquet as pq
    
    YellowCabs()