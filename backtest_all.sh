#!/bin/bash

STRATEGIES="
    CombinedBinHAndClucV6
    CombinedBinHAndClucV6H
    CombinedBinHAndClucV7
    CombinedBinHAndClucV8
    CombinedBinHClucAndMADV5
    CombinedBinHClucAndMADV3
    Obelisk_Ichimoku_ZEMA_v1
    NostalgiaForInfinityV1
    NostalgiaForInfinityV2
    NostalgiaForInfinityV3
"

static_config_files=~/ft_userdata/user_data/all_config/*static*
base_dir="/home/freqtrade/ft_userdata/"

last_30_days_period=$(date "+%Y%m%d" -d "31 day ago")-$(date "+%Y%m%d" -d "1 day ago")
year_window_period=$(date "+%y")0101-$(date "+%Y%m%d")
week_window_period=$(date "+%Y%m%d" -d "8 day ago")-$(date "+%Y%m%d" -d "1 day ago")

for TIMERANGE in ${last_30_days_period}
do
    docker-compose run --rm  \
        freqtrade download-data  \
        --exchange binance  \
        -t 5m 1h  \
        --timerange=${TIMERANGE}  \
        --pairs-file user_data/data/binance/pairs.json

    for CONFIG_FILE in ${static_config_files}
    do
        CONFIG_FILE=${CONFIG_FILE#"$base_dir"}  # Removing base dir from absolute path.
        CONFIG_FILE_NAME=$(basename ${CONFIG_FILE} .json)

        for MOT in 2 3 5 7
        do
            echo "******* Backtesting ${CONFIG_FILE_NAME} - ${TIMERANGE} and max-open-position=${MOT} *******"
            docker-compose run --rm  \
                freqtrade backtesting  \
                --strategy-list ${STRATEGIES}  \
                --timerange ${TIMERANGE}  \
                --config ${CONFIG_FILE}  \
                --max-open-trades ${MOT}  \
                --export trades  \
                --timeframe 5m  \
                --dry-run-wallet 1000  \
                --export-filename user_data/backtest_results/${TIMERANGE}_${MOT}MOT_${CONFIG_FILE_NAME}.json
        done
    done
done
