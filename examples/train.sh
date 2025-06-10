#!/bin/bash

# tmux new -s train
# bash train.sh | while read line; do echo "$(date +"%Y-%m-%d %H:%M:%S") $line"; done | tee ./runtime/train_$(date +%Y%m%d_%H%M%S).log

# eval_interval: 保存并评估模型的间隔
# Default
# HAPPO: 25
# HASAC: 100000
# HASAC: --auto_alpha False/True

# use_render: 是否使用渲染
# render_episodes: 渲染回合数，Default: 10
# 可在HARL/harl/envs/lag/JSBSim/configs中修改：
# max_steps（max_steps=1000对应200s）
# sim_freq: 60
# agent_interaction_steps: 12 # step 0.2s

python -u train.py --algo happo --env lag --exp_name ImproveNoWeaponHappo --task 2v2/NoWeapon/vsBaseline 2>&1 | while read line; do echo "$(date +"%Y-%m-%d %H:%M:%S") $line"; done | tee ./runtime/train_$(date +%Y%m%d_%H%M%S).log

# --task 默认2v2/ShootMissile/HierarchyVsBaseline
# 2v2/NoWeapon/vsBaseline, 2v2/ShootMissile/HierarchyVsBaseline

# --use_render True --render_episodes 1

# if set, load models from this directory; otherwise, randomly initialise the models
# model_dir: ~

# 使用tensorboard --logdir ....../logs查看tensorboard记录



# torch_threads 4 -> 8 控制PyTorch在CPU上的并行计算线程数

# --actor_num_mini_batch 1 -> 2
# --critic_num_mini_batch 1 -> 2
# 增大：训练速度变慢，但内存占用减少，更适合显存有限的设备，梯度估计有更高方差，可能带来更多探索行为，但稳定性降低；可能需要同时降低lr
# 减小：训练速度加快，但内存占用增加，需要更大的GPU显存支持，梯度估计更稳定，学习过程更平滑，但可能陷入局部最优

# --clip_param 0.2 -> 0.05
# 小：更新更保守，学习更慢，适合不稳定环境
# clip_param增大时应考虑减小学习率，更多ppo_epoch，调整max_grad_norm从而有更严格梯度裁剪
# --entropy_coef 0.01 -> 0
# 控制策略探索行为，越大越探索
# 较大时减小lr，小gamma（折扣因子），理论上应随训练进度逐步降低
# --hidden_sizes 128*128 -> 256*256
# 更大的网络需更小学习率，更小mini_batch，更大weight_decay，调整初始化（ini_method，gain）

# --episode_length 200 -> 1000
# 增大：轮数减少，单轮时长增加
# 过短：LAG环境中可能导致战斗未完成就结束收集，体验不完整
# 过长：延迟策略更新频率，可能浪费计算在已经结束的回合上
# 更大时可能需要更大的gae_lambda、gamma；如果是递归策略，需确保是data_chunk_length的倍数

# --num_env_steps 1e8 -> 1e7
# --noweapon