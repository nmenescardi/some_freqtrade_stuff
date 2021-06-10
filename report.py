import os
os.chdir('/freqtrade/')

import pandas as pd
from freqtrade.data.btanalysis import load_backtest_data, load_backtest_stats
from pathlib import Path

backtest_dir = "/freqtrade/user_data/backtest_results"

report_columns = [
    "Backtest",
    "Period",
    "Strategy",
    "MOT",
    "Total_Profit",
    "Max_Drawdown"
]
df = pd.DataFrame(columns = report_columns)

backtest_list = Path(backtest_dir).rglob('*.json')
for path in backtest_list:
    backtest_file_path = str(path)
        
    if ".last_result.json" in backtest_file_path:
        continue

    stats = load_backtest_stats(backtest_file_path)

    import ntpath
    backtest_name = ntpath.basename(backtest_file_path)
    
    for strategy, stats in stats['strategy'].items():
        
        period = stats['backtest_start'][0:10] + '__' + stats['backtest_end'][0:10]

        new_row = {
            "Period": period,
            "Strategy": strategy,
            "MOT": stats['max_open_trades'],
            "Total_Profit": stats['profit_total'],
            "Max_Drawdown": stats['max_drawdown'],
            "Backtest": stats['backtest_name'],
        }
        df = df.append(new_row, ignore_index=True)


def filter_df(df, amount_of_results = 2):
    quantile = 100
    found_results = False

    while(not found_results):
        quantile -= 1
        tp_quantile = round(quantile / 100, 2)
        dd_quantile = round(1 - tp_quantile, 2)

        filtered_df = df.loc[ 
            (df.Total_Profit >= df.groupby('Period').Total_Profit.transform(pd.Series.quantile, tp_quantile)) &
            (df.Max_Drawdown <= df.groupby('Period').Max_Drawdown.transform(pd.Series.quantile, dd_quantile))
        ]
        if(len(filtered_df) >= amount_of_results):
            found_results = True

    return filtered_df, quantile


# Print results
for i in range(1,6):
	filtered_df, quantile = filter_df(df, amount_of_results = i)
	amount_of_results_found = len(filtered_df.index)
	results_str = "Result" if amount_of_results_found == 1 else "Results"
	print("{} {} found on quantile {}".format(amount_of_results_found, results_str, quantile))
	print(filtered_df.to_string())
	print("****************** \n \n")

print(" All backtests: ")
print(df.drop(labels='Backtest', axis=1).to_string())
