# -*- coding: utf-8 -*-
"""
Created on Tue Aug 14 10:32:26 2018

@author: matan
"""

from __future__ import print_function
from apiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools
import pandas as pd
import numpy as np


SPREADSHEET_ID = "1jF71hllx7V9XeAwjB43EC-SKnh12D5s-hD59L-SL5Vc"

RANGE_NAME1 = "Week7"
RANGE_NAME2 = "Week2"


def get_google_sheet(spreadsheet_id, range_name):
    """ Retrieve sheet data using OAuth credentials and Google Python API. """
    scopes = 'https://www.googleapis.com/auth/spreadsheets.readonly'
    # Setup the Sheets API
    store = file.Storage('credentials.json')
    creds = None
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets('client_secret.json', scopes)
        creds = tools.run_flow(flow, store)
    service = build('sheets', 'v4', http=creds.authorize(Http()))

    # Call the Sheets API
    gsheet = service.spreadsheets().values().get(spreadsheetId=spreadsheet_id, range=range_name).execute()
    return gsheet


def gsheet2df(gsheet):
    """ Converts Google sheet data to a Pandas DataFrame.
    Note: This script assumes that your data contains a header file on the first row!
    Also note that the Google API returns 'none' from empty cells - in order for the code
    below to work, you'll need to make sure your sheet doesn't contain empty cells,
    or update the code to account for such instances.
    """
    header = gsheet.get('values', [])[0]   # Assumes first line is header!
    values = gsheet.get('values', [])[1:]  # Everything else is data.
    if not values:
        print('No data found.')
    else:
        all_data = []
        for col_id, col_name in enumerate(header):
            column_data = []
            for row in values:
                if row[col_id] == '999':
                    column_data.append(np.nan)
                elif row[col_id].isnumeric() == True:
                    column_data.append(eval(row[col_id]))
                else:
                    column_data.append(row[col_id])
            ds = pd.Series(data=column_data, name=col_name)
            all_data.append(ds)
        df = pd.concat(all_data, axis=1)
    return df


##Run one of these two segments at a time, due to internet request
#Segment 1
#gsheet = get_google_sheet(SPREADSHEET_ID, RANGE_NAME1)
#df1 = gsheet2df(gsheet)
#print('Dataframe size = ', df1.shape)
#print(df1.head())
#Segment 2
gsheet2 = get_google_sheet(SPREADSHEET_ID, RANGE_NAME2)
df2 = gsheet2df(gsheet2)
print('Dataframe size = ', df2.shape)
print(df2.head())
#Segments end


#df1['Week'] = 7
df2['Week'] = 2 

listHeadersdf1 = ['subject_number','radiology','resting_state','ASL_rest','ER1','structural','MRS','ER2','UG_game','BOLD_MT','ASL_MT','LC_scan','LC_PA','LC_AP','BOLD_PB','PB6','PB10','PB15','Week']
listHeadersdf2 = ['subject_number','radiology','resting_state',	'ER1',	'structural', 'MRS','LC_scan','ASL','Week']
#df1Short = df1[listHeadersdf1]
df2Short = df2[listHeadersdf2]

file_name1 = 'post_Week7_legend.csv'
file_name2 = 'pre_Week2_legend.csv'

#df1Short.to_csv(file_name1, sep=',')
df2Short.to_csv(file_name2, sep=',')