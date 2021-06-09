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

for CONFIG_FILE in ${static_config_files}
do
    CONFIG_FILE=${CONFIG_FILE#"$base_dir"}  # Removing base dir from absolute path.
    CONFIG_FILE_NAME=$(basename ${CONFIG_FILE} .json)
    echo ${CONFIG_FILE_NAME}

    for TIMERANGE in 20210325-20210527
    do
        for MOT in 2 3 5 7
        do
            echo "******* Backtesting ${CONFIG_FILE} - ${TIMERANGE} and max-open-position=${MOT} *******"
            docker-compose run  \
                --rm freqtrade backtesting  \
                --strategy-list ${STRATEGIES}  \
                --timerange ${TIMERANGE}  \
                --config ${CONFIG_FILE}  \
                --max-open-trades ${MOT}  \
                --export trades  \
                --timeframe 5m  \
                --dry-run-wallet 1000  \
                --export-filename user_data/backtest_results/${TIMERANGE}_${MOT}MOT_${CONFIG_FILE_NAME}_${1}.json
        done
    done
done
