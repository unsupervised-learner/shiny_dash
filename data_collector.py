from bs4 import BeautifulSoup
import requests
import pickle
import pandas as pd
import pandas_datareader as pdr
import datetime as dt



def main():
	#request url
	req = requests.get('https://www.slickcharts.com/sp500')

	#place url in soup
	soup = BeautifulSoup(req.text, 'lxml')
	#print(soup)

	#search for table
	table = soup.find('table', {'class':'table table-hover table-borderless table-sm'})
	#iterate through rows
	#findAll rows (skip header)
	rows = table.findAll('tr')[1:]
	ticks = []
	for row in rows:
		#select column 2 of this row
		tick = row.findAll('td')[2].text
		ticks.append(tick)

	#dump to file
	with open('symbols.pickle','wb') as f:
		#dump ticks to file
		pickle.dump(ticks, f)

	start_date = dt.datetime(2000,1,1)
	end_date = dt.datetime(2019,1,1)

	#open file for reading
	with open('symbols.pickle','rb') as f:
		symbols = pickle.load(f)

	#loop through symbols and download files
	for symbol in symbols:
		try:
			df = pdr.DataReader(symbol, 'yahoo', start_date, end_date)
			#write to file
			df.to_csv('/home/vernon/Desktop/stock_data/{}.csv'.format(symbol))
		except KeyError:
			pass
		#print(df.head())

if __name__ == '__main__':
	main()
