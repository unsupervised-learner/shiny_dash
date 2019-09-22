import os
import pandas as pd
import numpy as np


source_ = '/home/vernon/Desktop/stock_data'
dest_ = '/home/vernon/Desktop'



def seek_n_combine():
	curr_dir = source_
	tickers = os.listdir(curr_dir)
	ticker_list = []

	for ticker_obj in tickers:
		name_of_tick = str(ticker_obj).split('.')[0]
		path_to_ticker = os.path.join(source_, ticker_obj)

		#read data
		data = pd.read_csv(path_to_ticker)  

		#append label
		data['ticker_name'] = name_of_tick

		#append to list
		ticker_list.append(data)
		
	final_df = pd.concat(ticker_list)
	os.chdir(dest_)
	final_df.to_csv('combined_stocks.csv', index=False)
	print('[INFO] dataset created ...')
	print('[INFO] final data shape : {}'.format(final_df.shape))


def load_n_view():
	print('Hello World!')


if __name__ == '__main__':
	seek_n_combine()
