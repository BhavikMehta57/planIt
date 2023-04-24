from fastapi import FastAPI, Request
import pandas
import uvicorn
from pydantic import BaseModel

from sklearn.cluster import KMeans
from k_means_constrained import KMeansConstrained

import ortools
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth
from firebase_admin import firestore
from firebase_admin import credentials
import datetime

from math import radians, cos, sin, asin, sqrt
import math
import sys
from sys import maxsize 
from itertools import permutations

class Info(BaseModel):
    city: str
    hotelName: str
    hotelLatitude: str
    hotelLongitude: str
    itineraryID: str

class Location(BaseModel):
    latitude: float
    longitude: float

app = FastAPI()

@app.get("/")
async def root():
    return {"status": "Server Started"}

@app.get("/hotels/{city}")
async def getHotels(city: str):
    hotels = []
    cityName = city.capitalize()
    csvFile = pandas.read_csv('hotelsDataset.csv')
    hotelList = csvFile[(csvFile['City'] == cityName)]
    for row in hotelList.iterrows():
        hotels.append({
            "Name": row[1]['Name'],
            "Address": row[1]['Address'],
            "Latitude": row[1]['Latitude'],
            "Longitude": row[1]['Longitude'],
            "Rating": row[1]['Rating'],
            "Price": row[1]['Price'],
            "Image": row[1]['Image'],
        })
    return {
        "result": {
            "status": 200,
            "data": hotels
        }
    }

@app.post("/restaurants/{city}")
async def getRestaurants(city: str, location: Location):
    restaurants = []
    cityName = city.capitalize()
    restaurantList = pandas.read_csv(cityName + 'Restaurant.csv')
    distances = []
    lat = location.latitude
    lon = location.longitude
    def haversine_distance(lat1, lon1, lat2, lon2):
        # Convert latitude and longitude to spherical coordinates in radians.
        degrees_to_radians = math.pi/180.0

        phi1 = (90.0 - lat1)*degrees_to_radians
        phi2 = (90.0 - lat2)*degrees_to_radians

        theta1 = lon1*degrees_to_radians
        theta2 = lon2*degrees_to_radians
        
        # Compute spherical distance from spherical coordinates.
        # For two locations in spherical coordinates (1, theta, phi) and (1, theta', phi')
        # cosine( arc length ) = sin phi sin phi' cos(theta-theta') + cos phi cos phi'
        # distance = rho * arc length
        cos = (math.sin(phi1) * math.sin(phi2) * math.cos(theta1 - theta2) + math.cos(phi1) * math.cos(phi2))
        arc = math.acos( cos )

        # Remember to multiply arc by the radius of the earth in your favorite set of units to get length.
        # in meters
        return arc*6378160

    for i, row in restaurantList.iterrows():
        dist = haversine_distance(lat, lon, row['latitude'], row['longitude'])
        distances.append(dist)

    sorted_dist_indices = sorted(range(len(distances)), key=lambda k: distances[k])[:100]

    nearest_places = [restaurantList.iloc[[i]].to_dict('list') for i in sorted_dist_indices]

    return {
        "result": {
            "status": 200,
            "data": nearest_places
        }
    }

@app.post("/itinerary/")
async def getItinerary(info: Info):
    
    sns.set()
    db = firestore.client()
    itineraryDoc = db.collection('plannerInput').document(info.itineraryID).get().to_dict()
    itinerary = []
    current = itineraryDoc['Areas of Interest']
    destination = itineraryDoc['Destination']
    itinerary_id = itineraryDoc['ItineraryID']
    user = itineraryDoc['UserEmail']
    days = itineraryDoc['Number of Days']
    startDate = itineraryDoc['Start Date']
    destination = itineraryDoc['Destination']
    numberOfTravellers = itineraryDoc['Number of travellers']
    hotel_lat = float(info.hotelLatitude)
    hotel_long = float(info.hotelLongitude)
    hotel_name = info.hotelName

    data = pd.read_csv('Dataset Attributes - All2.csv')

    data = data.loc[data['City'] == destination] 
    data = data.loc[data['Type'].isin(current)]

    f = data.shape[0]/days
    ff = int(f)
    
    kmeans = KMeansConstrained(
        n_clusters = days,
        size_min = ff,
        size_max = None,
        random_state = 0,
        n_init = 100
    )

    x = data.iloc[:,4:6]
    iti_day = pd.DataFrame()
    new_row = pd.DataFrame(
        {
            'Place':hotel_name,
            'City':' ',
            'State':' ',
            'Full Address':'ff',
            'Latitude':hotel_lat,
            'Longitude':hotel_long,
            'Rating': 5.0,
            'Open Time': '00:00',
            'Close Time': '23:59',
            'Best Time to Visit': " ",
            'Type': " ",
            'Avg time spent': 0,
            'Avg Cost': ' ',
            'Free/Paid': ' ', 
            # 'Image': ' ',
        }, index =[0])

    kmeans.fit(x)

    identified_clusters = kmeans.fit_predict(x)

    dwc = data.copy()
    dwc['Cluster'] = identified_clusters

    y = dwc[['Place','Cluster']]

    global day
    day = 0
    
    for i in range(0,days):

        places = [hotel_name]
        city = ['']
        state = ['']
        add = ['']
        lat = [hotel_lat]
        long = [hotel_long]
        rati = [5.0]
        open = ['00:00']
        close = ['23:59']
        avg = [0]
        btv = ['']
        typ = ['']
        cost = ['']
        fp = ['']
        # img = dwc[dwc.Cluster == i]['Image'].to_numpy()

        places = np.append(places, dwc[dwc.Cluster == i]['Place'].to_numpy())
        city = np.append(city, dwc[dwc.Cluster == i]['City'].to_numpy())
        state = np.append(state, dwc[dwc.Cluster == i]['State'].to_numpy())
        add = np.append(add, dwc[dwc.Cluster == i]['Full Address'].to_numpy())
        lat = np.append(lat, dwc[dwc.Cluster == i]['Latitude'].to_numpy())
        long = np.append(long, dwc[dwc.Cluster == i]['Longitude'].to_numpy())
        rati = np.append(rati, dwc[dwc.Cluster == i]['Rating'].to_numpy())
        open = np.append(open, dwc[dwc.Cluster == i]['Open Time'].to_numpy())
        close = np.append(close, dwc[dwc.Cluster == i]['Close Time'].to_numpy())
        avg = np.append(avg, dwc[dwc.Cluster == i]['Avg time spent'].to_numpy())
        btv = np.append(btv, dwc[dwc.Cluster == i]['Best Time to Visit'].to_numpy())
        typ = np.append(typ, dwc[dwc.Cluster == i]['Type'].to_numpy())
        cost = np.append(cost, dwc[dwc.Cluster == i]['Avg Cost'].to_numpy())
        fp = np.append(fp, dwc[dwc.Cluster == i]['Free/Paid'].to_numpy())
        # img = dwc[dwc.Cluster == i]['Image'].to_numpy()

        newDate = datetime.datetime.strptime(startDate, "%Y-%m-%d") + datetime.timedelta(days = i)

        print(places)

        iti_day['Place'] = places
        iti_day['City'] = city
        iti_day['State'] = state
        iti_day['Full Address'] = add
        iti_day['Latitude'] = lat
        iti_day['Longitude'] = long
        iti_day['Rating'] = rati
        iti_day['Open Time'] = open
        iti_day['Close Time'] = close
        iti_day['Best Time to Visit'] = btv
        iti_day['Type'] = typ 
        iti_day['Avg time spent'] = avg
        iti_day['Avg Cost'] = cost
        iti_day['Free/Paid'] = fp
        # iti_day['Image'] = img
        
        print(iti_day)

        def distance(lat1, lat2, lon1, lon2):
            lon1 = radians(lon1)
            lon2 = radians(lon2)
            lat1 = radians(lat1)
            lat2 = radians(lat2)

            dlon = lon2 - lon1
            dlat = lat2 - lat1
            a = sin(dlat / 2)*2 + cos(lat1) * cos(lat2) * sin(dlon / 2)*2
        
            c = 2 * asin(sqrt(abs(a)))
            
            r = 6378
            return(c * r)

        def weights(place):
            weight = 0
            weights = []
            for i in iti_day.index:
                if iti_day["Place"][i] == place:
                    weights.append(0)
                else:
                    weight = distance(iti_day["Latitude"][i],iti_day["Latitude"][iti_day.Place == place],iti_day["Longitude"][i],iti_day["Longitude"][iti_day.Place == place])
                    weights.append(weight)
            return weights    
        
        graph = []
        tt = []

        places = iti_day["Place"]
        for place in places:  
            graph.append(weights(place))

        for i in graph:
            travel = [(round(x/35,2)) for x in i]
            tt.append(travel)

        # https://www.livemint.com/news/india/nitin-gadkari-on-increasing-speed-limit-on-highways-india-needs-to-revise-its-speed-norms-11604979963156.html#:~:text=The%20average%20speed%20of%20vehicles%20inside%20Indian%20cities%20normally%20is%20around%2035%20km/h%2C%20as%20per%20a%20study%20titled%20Mobility%20and%20Congestion%20in%20Urban%20India.

        final_list = []
        time_format = "%H:%M"
        cities = len(iti_day)
        print("CITIES " + str(cities))
        openingtimes = []
        closingtimes = []
        avgtimes = []
        ratings = []
        count = 1
        start_time = 9.5
        global current_time
        current_time = start_time
        current_time = start_time
        for i in iti_day["Open Time"]:
            time = datetime.datetime.strptime(i, time_format)
            decimal_hours = time.hour + time.minute/60
            openingtimes.append(decimal_hours)
        
        for i in iti_day["Close Time"]:
            time = datetime.datetime.strptime(i, time_format)
            decimal_hours = time.hour + time.minute/60
            closingtimes.append(decimal_hours)
        for i in iti_day["Avg time spent"]:
            avgtimes.append(i)
        for i in iti_day["Rating"]:
            ratings.append(i)

        def TSP(graph, s): 
            global current_time
            global start_time
            # keep all vertex other than the starting point
            vertex = [] 

            # traverse the diagram 
            for i in range(cities): 
                if i != s: 
                    vertex.append(i) 
        
            # keep minimum weight
            min_path = maxsize 

            next_permutation = permutations(vertex)
            
            best_path = []

            temp = 0
            for i in next_permutation:
                # store current Path weight(cost) 
                current_pathweight = 0
                
                # compute current path weight 
                k = s 
                
                for j in i: 
                    current_pathweight += graph[k][j] 
                    k = j 
                current_pathweight += graph[k][s] 
                
                # update minimum 
                if current_pathweight < min_path:
                    min_path = current_pathweight
                    best_path = [s]
                    best_path.extend(list(i))
                    best_path.append(s)
            
            print("Initial Path accoridng to TSP = ",best_path)
            for i in best_path:
                final_list.append(iti_day['Place'][i])
            
            return final_list,best_path

        def bestpath_time(best_path):
            global current_time
            global start_time
            final = []
            fwd = []
            bwd = []

            print("============================= \n Forward Path")
            print(best_path)
            for i in range(1,len(best_path)):
                
                j = i-1
                if (current_time >= openingtimes[best_path[i]]) and (current_time + avgtimes[best_path[i]] < closingtimes[best_path[i]]):
                    
                    current_time = round(current_time + avgtimes[best_path[i]] ,2)
                    
                    currenttimefwd = current_time
                    fwd.append(best_path[i])
                    
            avg_fwd_rating = 0
            for i in range(1,len(fwd)):
                avg_fwd_rating += ratings[best_path[i]]
            best_path.reverse()

            print("********************************* \n Backward Path")
            print(best_path)
            current_time = 9.5
            for i in range(1,len(best_path)):
                
                j = i-1
                if (current_time >= openingtimes[best_path[i]]) and (current_time + avgtimes[best_path[i]] < closingtimes[best_path[i]]):
                    
                    current_time = round(current_time + avgtimes[best_path[i]] ,2)
                    
                    bwd.append(best_path[i])
                    currenttimebwd = current_time
            avg_bwd_rating = 0
            for i in range(1,len(bwd)):
                    avg_bwd_rating += ratings[best_path[i]]
            print("Forward List: ", fwd)
            print("Backward List: ",bwd)

            if(currenttimebwd > currenttimefwd):
                
                final = addExtra(best_path,fwd)
                if(len(final)<=len(bwd)):
                    final = addExtra(best_path,bwd)
            else:
                final = addExtra(best_path,bwd)
            
                if(len(final)<=len(fwd)):
                    final = addExtra(best_path,fwd)
            if( 0 in final):
                final.remove(0)
            return final

        def addExtra(best_path,place_list):
            global current_time
            global start_time
            unmatch = set(best_path) - set(place_list)
            if (0 in unmatch):
                unmatch.remove(0)
            unmatch = list(unmatch)
            print("----------------------------------------")
            print("Unmatched List Places are = ",unmatch)
            l=len(place_list)
            for i in range(len(unmatch)):
                j=i+1
                if (current_time >= openingtimes[unmatch[i]]) and (current_time + avgtimes[unmatch[i]] < closingtimes[unmatch[i]]):
                
                    current_time = round(current_time + avgtimes[best_path[i]] ,2)
                    
                    place_list.append(unmatch[i])
                    

            return place_list
            
            
        dist, path = TSP(graph,0)
        final_path = bestpath_time(path)
        print("-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=")
        print("FINAL PATH IS ",final_path)
        iti_day = iti_day.iloc[final_path]
        print(iti_day)
        print("-=-=-=-=-=-=-=-=-=-=-=-=-=DAY OVER=-=-=-=-=-=-=-=-=-=-=-")
        itinerary.append({
                "date": newDate.strftime("%Y-%m-%d"),
                "day": day,
                "places": iti_day.to_dict('list')
            })

        iti_day.drop(iti_day.index,inplace=True)

    # db.collection('itineraries').document(itinerary_id).set({
    #     "Itinerary": itinerary,
    #     "UserEmail": user,
    #     "ItineraryID": itinerary_id,
    #     "Destination": destination,
    #     "Number of travellers": numberOfTravellers,
    #     "Number of Days": days,
    #     "Start Date": startDate,
    # })

    return {
        "result": {
            "status": 200,
            "data": {
                "itineraryID": itinerary_id,
                "destination": destination,
                "startDate": startDate,
                "numberOfDays": days,
            }
        }
    }


if __name__ == "__main__":
    cred = credentials.Certificate("planit-9d690-firebase-adminsdk-dx1wx-f93c823aa2.json")
    firebase_admin.initialize_app(cred)
    uvicorn.run(app, host="0.0.0.0", port=8000)