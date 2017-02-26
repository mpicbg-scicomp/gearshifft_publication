#!/bin/bash
#SBATCH -J gearshifft_K80_Verify
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=8:00:00
#SBATCH --mem=20000M
#SBATCH --partition=gpu2
#SBATCH --exclusive
#SBATCH --array 0-1
#SBATCH -o slurmgpu2_array-%A_%a.out
#SBATCH -e slurmgpu2_array-%A_%a.err

k=$SLURM_ARRAY_TASK_ID

RESULTS=../results/K80/cuda-8.0.44

cd release

# gearshifft
if [ $k -eq 0 ]; then
    FCONFIG="../config/cufft_validate.conf"

    >$FCONFIG
    for r in `seq 1 250`; do
        # 1<<26
        echo 16777216 >> $FCONFIG
    done

    srun --gpufreq=2505:823 ./gearshifft_cufft -f ../config/cufft_validate.conf -r */float/*/Inplace_Real -o $RESULTS/validate_cufft_r2c_inplace.csv
#    srun --gpufreq=2505:823 ./gearshifft_cufft -f ../config/cufft_validate.conf -r */float/*/Inplace_Real -o $RESULTS/validate_cufft_r2c_5runs_inplace.csv

    >$FCONFIG
    for r in `seq 1 250`; do
        echo 1024 >> $FCONFIG
    done

    srun --gpufreq=2505:823 ./gearshifft_cufft -f ../config/cufft_validate.conf -r */float/*/Inplace_Real -o $RESULTS/validate_cufft_r2c_inplace_small.csv
#    srun --gpufreq=2505:823 ./gearshifft_cufft -f ../config/cufft_validate.conf -r */float/*/Inplace_Real -o $RESULTS/validate_cufft_r2c_5runs_inplace_small.csv
fi

# cufft standalone
if [ $k -eq 1 ]; then
    DCUFFT_STANDALONE="../validation/cufft_standalone"
    iterations=250
    runs=5
    FCUFFT="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_inplace.csv"
    FCUFFT_SMALL="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_inplace_small.csv"
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 16777216 $iterations $FCUFFT $runs 1
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 1024 $iterations $FCUFFT_SMALL $runs 1

    FCUFFT="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_tts_inplace.csv"
    FCUFFT_SMALL="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_tts_inplace_small.csv"
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 16777216 $iterations $FCUFFT $runs 0
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 1024 $iterations $FCUFFT_SMALL $runs 0


    runs=20
    FCUFFT="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_inplace.csv"
    FCUFFT_SMALL="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_inplace_small.csv"
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 16777216 $iterations $FCUFFT $runs 1
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 1024 $iterations $FCUFFT_SMALL $runs 1

    FCUFFT="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_tts_inplace.csv"
    FCUFFT_SMALL="$RESULTS/validate_cufft_standalone_r2c_${runs}runs_tts_inplace_small.csv"
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 16777216 $iterations $FCUFFT $runs 0
    srun --gpufreq=2505:823 $DCUFFT_STANDALONE/cufft_time_r2c 1024 $iterations $FCUFFT_SMALL $runs 0
fi
