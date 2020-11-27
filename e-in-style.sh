#!/bin/bash
#
#SBATCH --job-name=e-in-style
#SBATCH --output=e-in-style.log
#SBATCH --time=1:00:00
#SBATCH --mail-user=andrew.selvia@sjsu.edu
#SBATCH --mail-type=END
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
python main.py --dataset fashion-mnist --gan_type $GAN_TYPE --gpu_mode
