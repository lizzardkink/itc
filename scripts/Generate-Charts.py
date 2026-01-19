#!/usr/bin/env python3
"""
Generate publication-quality charts for IDS Performance Impact Study
Creates professional visualizations suitable for LNCS format papers
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from pathlib import Path
import json

# Configuration
DATA_DIR = Path(r"C:\Users\lizzardkink\OneDrive\Documents\Dev\itc\data")
OUTPUT_DIR = Path(r"C:\Users\lizzardkink\OneDrive\Documents\Dev\itc\figures")
OUTPUT_DIR.mkdir(exist_ok=True)

# Professional color scheme (colorblind-friendly)
COLORS = {
    'baseline': '#2E86AB',      # Blue
    'antivirus': '#A23B72',     # Purple
    'firewall': '#F18F01',      # Orange
    'both': '#C73E1D'           # Red
}

CONFIG_LABELS = {
    'baseline': 'Baseline\n(No IDS)',
    'antivirus': 'TotalAV\nOnly',
    'firewall': 'Fort Firewall\nOnly',
    'both': 'TotalAV +\nFort Firewall'
}

# Chart style settings
plt.style.use('seaborn-v0_8-paper')
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif']
plt.rcParams['font.size'] = 10
plt.rcParams['axes.labelsize'] = 11
plt.rcParams['axes.titlesize'] = 12
plt.rcParams['xtick.labelsize'] = 9
plt.rcParams['ytick.labelsize'] = 9
plt.rcParams['legend.fontsize'] = 9
plt.rcParams['figure.titlesize'] = 13

def load_data():
    """Load statistical analysis results"""
    stats_file = DATA_DIR / 'statistical_analysis.json'
    if stats_file.exists():
        with open(stats_file, 'r') as f:
            return json.load(f)
    return None

def create_boot_time_chart(data):
    """Chart 1: Boot Time Comparison"""
    configs = ['baseline', 'antivirus', 'firewall', 'both']
    means = [data['boot_time'][c]['mean'] for c in configs]
    stds = [data['boot_time'][c]['std'] for c in configs]
    
    fig, ax = plt.subplots(figsize=(7, 4.5))
    
    x = np.arange(len(configs))
    bars = ax.bar(x, means, yerr=stds, capsize=5,
                   color=[COLORS[c] for c in configs],
                   edgecolor='black', linewidth=1.2, alpha=0.85)
    
    # Add value labels on bars
    for i, (bar, mean, std) in enumerate(zip(bars, means, stds)):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + std + 2,
                f'{mean:.1f}s',
                ha='center', va='bottom', fontweight='bold', fontsize=9)
    
    # Add percentage change annotations
    baseline_mean = means[0]
    for i, (config, mean) in enumerate(zip(configs[1:], means[1:]), 1):
        change = ((mean - baseline_mean) / baseline_mean) * 100
        color = 'darkgreen' if change < 0 else 'darkred'
        sign = '' if change < 0 else '+'
        ax.text(i, 5, f'{sign}{change:.1f}%',
                ha='center', va='bottom', fontweight='bold',
                color=color, fontsize=8,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', 
                         edgecolor=color, alpha=0.8))
    
    ax.set_ylabel('Boot Time (seconds)', fontweight='bold')
    ax.set_xlabel('System Configuration', fontweight='bold')
    ax.set_title('Criterion A: Operating System Boot Time', fontweight='bold', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels([CONFIG_LABELS[c] for c in configs])
    ax.set_ylim(0, max(means) + max(stds) + 15)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'chart1_boot_time.png', dpi=300, bbox_inches='tight')
    plt.savefig(OUTPUT_DIR / 'chart1_boot_time.pdf', bbox_inches='tight')
    print("✓ Chart 1: Boot Time saved")
    plt.close()

def create_ram_chart(data):
    """Chart 2: RAM Usage Comparison"""
    configs = ['baseline', 'antivirus', 'firewall', 'both']
    means = [data['ram_usage'][c]['mean'] for c in configs]
    stds = [data['ram_usage'][c]['std'] for c in configs]
    
    fig, ax = plt.subplots(figsize=(7, 4.5))
    
    x = np.arange(len(configs))
    bars = ax.bar(x, means, yerr=stds, capsize=5,
                   color=[COLORS[c] for c in configs],
                   edgecolor='black', linewidth=1.2, alpha=0.85)
    
    # Add value labels
    for bar, mean, std in zip(bars, means, stds):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + std + 30,
                f'{mean:.0f} MB',
                ha='center', va='bottom', fontweight='bold', fontsize=9)
    
    # Add overhead annotations
    baseline_mean = means[0]
    for i, (config, mean) in enumerate(zip(configs[1:], means[1:]), 1):
        overhead = mean - baseline_mean
        change_pct = (overhead / baseline_mean) * 100
        ax.text(i, 200, f'+{overhead:.0f} MB\n(+{change_pct:.1f}%)',
                ha='center', va='bottom', fontweight='bold',
                color='darkred', fontsize=7,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor='darkred', alpha=0.8))
    
    ax.set_ylabel('Memory Usage (MB)', fontweight='bold')
    ax.set_xlabel('System Configuration', fontweight='bold')
    ax.set_title('Criterion B: RAM Consumption at Startup', fontweight='bold', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels([CONFIG_LABELS[c] for c in configs])
    ax.set_ylim(0, max(means) + max(stds) + 300)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'chart2_ram_usage.png', dpi=300, bbox_inches='tight')
    plt.savefig(OUTPUT_DIR / 'chart2_ram_usage.pdf', bbox_inches='tight')
    print("✓ Chart 2: RAM Usage saved")
    plt.close()

def create_app_launch_chart(data):
    """Chart 3: Application Launch Performance"""
    configs = ['baseline', 'antivirus', 'firewall', 'both']
    means = [data['app_launch'][c]['mean'] for c in configs]
    stds = [data['app_launch'][c]['std'] for c in configs]
    
    fig, ax = plt.subplots(figsize=(7, 4.5))
    
    x = np.arange(len(configs))
    bars = ax.bar(x, means, yerr=stds, capsize=5,
                   color=[COLORS[c] for c in configs],
                   edgecolor='black', linewidth=1.2, alpha=0.85)
    
    # Add value labels
    for bar, mean, std in zip(bars, means, stds):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + std + 0.5,
                f'{mean:.1f}s',
                ha='center', va='bottom', fontweight='bold', fontsize=9)
    
    # Add percentage change annotations
    baseline_mean = means[0]
    for i, (config, mean) in enumerate(zip(configs[1:], means[1:]), 1):
        change = ((mean - baseline_mean) / baseline_mean) * 100
        color = 'darkgreen' if change < 0 else 'darkred'
        sign = '' if change < 0 else '+'
        ax.text(i, 2, f'{sign}{change:.1f}%',
                ha='center', va='bottom', fontweight='bold',
                color=color, fontsize=8,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor=color, alpha=0.8))
    
    ax.set_ylabel('Launch Time (seconds)', fontweight='bold')
    ax.set_xlabel('System Configuration', fontweight='bold')
    ax.set_title('Criterion D: Application Launch Performance (30 apps)', fontweight='bold', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels([CONFIG_LABELS[c] for c in configs])
    ax.set_ylim(0, max(means) + max(stds) + 3)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'chart3_app_launch.png', dpi=300, bbox_inches='tight')
    plt.savefig(OUTPUT_DIR / 'chart3_app_launch.pdf', bbox_inches='tight')
    print("✓ Chart 3: Application Launch saved")
    plt.close()

def create_network_performance_chart(data):
    """Chart 4: Network Performance Comparison (SMB + FTP)"""
    configs = ['baseline', 'antivirus', 'firewall', 'both']
    smb_means = [data['smb_copy'][c]['mean'] for c in configs]
    ftp_means = [data['ftp_download'][c]['mean'] for c in configs]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))
    
    x = np.arange(len(configs))
    width = 0.6
    
    # SMB Chart
    bars1 = ax1.bar(x, smb_means, width,
                    color=[COLORS[c] for c in configs],
                    edgecolor='black', linewidth=1.2, alpha=0.85)
    
    for bar, mean in zip(bars1, smb_means):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height + 1,
                f'{mean:.1f}',
                ha='center', va='bottom', fontweight='bold', fontsize=9)
    
    baseline_smb = smb_means[0]
    for i, mean in enumerate(smb_means[1:], 1):
        change = ((mean - baseline_smb) / baseline_smb) * 100
        color = 'darkgreen' if change > 0 else 'darkred'
        sign = '+' if change > 0 else ''
        ax1.text(i, 5, f'{sign}{change:.1f}%',
                ha='center', va='bottom', fontweight='bold',
                color=color, fontsize=7,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor=color, alpha=0.8))
    
    ax1.set_ylabel('Transfer Speed (MB/s)', fontweight='bold')
    ax1.set_xlabel('System Configuration', fontweight='bold')
    ax1.set_title('Criterion E: SMB Local Network Transfer', fontweight='bold', pad=10)
    ax1.set_xticks(x)
    ax1.set_xticklabels([CONFIG_LABELS[c] for c in configs], fontsize=8)
    ax1.set_ylim(0, max(smb_means) + 8)
    ax1.grid(axis='y', alpha=0.3, linestyle='--')
    
    # FTP Chart
    bars2 = ax2.bar(x, ftp_means, width,
                    color=[COLORS[c] for c in configs],
                    edgecolor='black', linewidth=1.2, alpha=0.85)
    
    for bar, mean in zip(bars2, ftp_means):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height + 0.3,
                f'{mean:.1f}',
                ha='center', va='bottom', fontweight='bold', fontsize=9)
    
    baseline_ftp = ftp_means[0]
    for i, mean in enumerate(ftp_means[1:], 1):
        change = ((mean - baseline_ftp) / baseline_ftp) * 100
        color = 'darkgreen' if change > 0 else 'darkred'
        sign = '+' if change > 0 else ''
        ax2.text(i, 1.5, f'{sign}{change:.1f}%',
                ha='center', va='bottom', fontweight='bold',
                color=color, fontsize=7,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor=color, alpha=0.8))
    
    ax2.set_ylabel('Download Speed (MB/s)', fontweight='bold')
    ax2.set_xlabel('System Configuration', fontweight='bold')
    ax2.set_title('Criterion F: FTP Remote Download', fontweight='bold', pad=10)
    ax2.set_xticks(x)
    ax2.set_xticklabels([CONFIG_LABELS[c] for c in configs], fontsize=8)
    ax2.set_ylim(0, max(ftp_means) + 2)
    ax2.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'chart4_network_performance.png', dpi=300, bbox_inches='tight')
    plt.savefig(OUTPUT_DIR / 'chart4_network_performance.pdf', bbox_inches='tight')
    print("✓ Chart 4: Network Performance saved")
    plt.close()

def create_comprehensive_overhead_chart(data):
    """Chart 5: Comprehensive Overhead Heatmap"""
    configs = ['TotalAV\nOnly', 'Fort Firewall\nOnly', 'TotalAV +\nFort Firewall']
    metrics = ['Boot Time', 'RAM Usage', 'App Launch', 'SMB Speed', 'FTP Speed']
    
    # Calculate overhead percentages
    overheads = []
    
    # Boot time
    baseline_boot = data['boot_time']['baseline']['mean']
    overheads.append([
        ((data['boot_time']['antivirus']['mean'] - baseline_boot) / baseline_boot) * 100,
        ((data['boot_time']['firewall']['mean'] - baseline_boot) / baseline_boot) * 100,
        ((data['boot_time']['both']['mean'] - baseline_boot) / baseline_boot) * 100
    ])
    
    # RAM
    baseline_ram = data['ram_usage']['baseline']['mean']
    overheads.append([
        ((data['ram_usage']['antivirus']['mean'] - baseline_ram) / baseline_ram) * 100,
        ((data['ram_usage']['firewall']['mean'] - baseline_ram) / baseline_ram) * 100,
        ((data['ram_usage']['both']['mean'] - baseline_ram) / baseline_ram) * 100
    ])
    
    # App Launch
    baseline_app = data['app_launch']['baseline']['mean']
    overheads.append([
        ((data['app_launch']['antivirus']['mean'] - baseline_app) / baseline_app) * 100,
        ((data['app_launch']['firewall']['mean'] - baseline_app) / baseline_app) * 100,
        ((data['app_launch']['both']['mean'] - baseline_app) / baseline_app) * 100
    ])
    
    # SMB (negative = slower)
    baseline_smb = data['smb_copy']['baseline']['mean']
    overheads.append([
        ((data['smb_copy']['antivirus']['mean'] - baseline_smb) / baseline_smb) * 100,
        ((data['smb_copy']['firewall']['mean'] - baseline_smb) / baseline_smb) * 100,
        ((data['smb_copy']['both']['mean'] - baseline_smb) / baseline_smb) * 100
    ])
    
    # FTP (negative = slower)
    baseline_ftp = data['ftp_download']['baseline']['mean']
    overheads.append([
        ((data['ftp_download']['antivirus']['mean'] - baseline_ftp) / baseline_ftp) * 100,
        ((data['ftp_download']['firewall']['mean'] - baseline_ftp) / baseline_ftp) * 100,
        ((data['ftp_download']['both']['mean'] - baseline_ftp) / baseline_ftp) * 100
    ])
    
    overheads = np.array(overheads)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Create custom colormap (green for improvements, red for degradation)
    from matplotlib.colors import LinearSegmentedColormap
    colors_map = ['#2d7f2e', '#ffffff', '#c73e1d']
    n_bins = 100
    cmap = LinearSegmentedColormap.from_list('custom', colors_map, N=n_bins)
    
    im = ax.imshow(overheads, cmap=cmap, aspect='auto', vmin=-20, vmax=55)
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax, pad=0.02)
    cbar.set_label('Performance Change (%)', fontweight='bold', rotation=270, labelpad=20)
    
    # Set ticks
    ax.set_xticks(np.arange(len(configs)))
    ax.set_yticks(np.arange(len(metrics)))
    ax.set_xticklabels(configs, fontsize=10)
    ax.set_yticklabels(metrics, fontsize=10)
    
    # Add text annotations
    for i in range(len(metrics)):
        for j in range(len(configs)):
            value = overheads[i, j]
            sign = '+' if value > 0 else ''
            color = 'white' if abs(value) > 20 else 'black'
            text = ax.text(j, i, f'{sign}{value:.1f}%',
                          ha="center", va="center", color=color,
                          fontweight='bold', fontsize=11)
    
    ax.set_title('Comprehensive Performance Impact Overview\n(vs. Baseline Configuration)',
                 fontweight='bold', pad=15, fontsize=13)
    ax.set_xlabel('IDS Configuration', fontweight='bold', fontsize=11)
    ax.set_ylabel('Performance Metric', fontweight='bold', fontsize=11)
    
    # Add grid
    ax.set_xticks(np.arange(len(configs))+0.5, minor=True)
    ax.set_yticks(np.arange(len(metrics))+0.5, minor=True)
    ax.grid(which="minor", color="gray", linestyle='-', linewidth=1.5)
    ax.tick_params(which="minor", size=0)
    
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'chart5_comprehensive_overhead.png', dpi=300, bbox_inches='tight')
    plt.savefig(OUTPUT_DIR / 'chart5_comprehensive_overhead.pdf', bbox_inches='tight')
    print("✓ Chart 5: Comprehensive Overhead Heatmap saved")
    plt.close()

def create_process_count_chart(data):
    """Chart 6: Process Count Comparison"""
    configs = ['baseline', 'antivirus', 'firewall', 'both']
    means = [data['process_count'][c]['mean'] for c in configs]
    stds = [data['process_count'][c]['std'] for c in configs]
    
    fig, ax = plt.subplots(figsize=(7, 4.5))
    
    x = np.arange(len(configs))
    bars = ax.bar(x, means, yerr=stds, capsize=5,
                   color=[COLORS[c] for c in configs],
                   edgecolor='black', linewidth=1.2, alpha=0.85)
    
    # Add value labels
    for bar, mean in zip(bars, means):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.5,
                f'{mean:.0f}',
                ha='center', va='bottom', fontweight='bold', fontsize=9)
    
    ax.set_ylabel('Number of Running Processes', fontweight='bold')
    ax.set_xlabel('System Configuration', fontweight='bold')
    ax.set_title('Criterion C: Process Count at Startup', fontweight='bold', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels([CONFIG_LABELS[c] for c in configs])
    ax.set_ylim(140, 158)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'chart6_process_count.png', dpi=300, bbox_inches='tight')
    plt.savefig(OUTPUT_DIR / 'chart6_process_count.pdf', bbox_inches='tight')
    print("✓ Chart 6: Process Count saved")
    plt.close()

def main():
    """Generate all charts"""
    print("\n" + "="*60)
    print("GENERATING PUBLICATION-QUALITY CHARTS")
    print("="*60 + "\n")
    
    # Load data
    data = load_data()
    if not data:
        print("ERROR: Could not load statistical analysis data!")
        return
    
    print(f"Output directory: {OUTPUT_DIR}\n")
    
    # Generate all charts
    create_boot_time_chart(data)
    create_ram_chart(data)
    create_app_launch_chart(data)
    create_network_performance_chart(data)
    create_comprehensive_overhead_chart(data)
    create_process_count_chart(data)
    
    print("\n" + "="*60)
    print("✓ ALL CHARTS GENERATED SUCCESSFULLY!")
    print("="*60)
    print(f"\nGenerated 6 charts in both PNG (300 DPI) and PDF formats:")
    print(f"  • chart1_boot_time.*")
    print(f"  • chart2_ram_usage.*")
    print(f"  • chart3_app_launch.*")
    print(f"  • chart4_network_performance.*")
    print(f"  • chart5_comprehensive_overhead.*")
    print(f"  • chart6_process_count.*")
    print(f"\nLocation: {OUTPUT_DIR}")
    print("\nReady for inclusion in LaTeX paper!")

if __name__ == '__main__':
    main()
