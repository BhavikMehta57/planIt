
# !pip install k_means_constrained

# !pip uninstall ortools

# !pip install --user ortools==9.3.10497

from sklearn.cluster import KMeans
from k_means_constrained import KMeansConstrained

import ortools
# import ortools.graph.pywrapgraph
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set()

import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth
from firebase_admin import firestore
from firebase_admin import credentials
import datetime

cred = credentials.Certificate("planit-9d690-firebase-adminsdk-dx1wx-f93c823aa2.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

users_ref = db.collection('plannerInput')
docs = list(users_ref.stream())
itinerary = []
current = docs[1].to_dict()['Areas of Interest']
destination = docs[1].to_dict()['Destination']
itinerary_id = docs[1].to_dict()['ItineraryID']
user = docs[1].to_dict()['UserEmail']
days = docs[1].to_dict()['Number of Days']
startDate = docs[1].to_dict()['Start Date']
destination = docs[1].to_dict()['Destination']
numberOfTravellers = docs[1].to_dict()['Number of travellers']

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

kmeans.fit(x)

identified_clusters = kmeans.fit_predict(x)
# identified_clusters

dwc = data.copy()
dwc['Cluster'] = identified_clusters

y = dwc[['Place','Cluster']]

plt.scatter(dwc['Longitude'], dwc['Latitude'], c = dwc['Cluster'], cmap='rainbow')
# plt.xlim(-180,180)
# plt.ylim(-90,90)

for i in range(0,days):
    places = dwc[dwc.Cluster == i]['Place'].to_numpy()
    newDate = datetime.datetime.strptime(startDate, "%Y-%m-%d") + datetime.timedelta(days = i)
    itinerary.append({
        "date": newDate.strftime("%Y-%m-%d"),
        "day": i+1,
        "places": places.tolist()
    })

# db.collection('itineraries').document(itinerary_id).set({
#     "Itinerary": itinerary,
#     "UserEmail": user,
#     "ItineraryID": itinerary_id,
#     "Destination": destination,
#     "Number of travellers": numberOfTravellers,
#     "Number of Days": days,
#     "Start Date": startDate,
# })