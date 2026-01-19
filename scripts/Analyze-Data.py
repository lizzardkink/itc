#!/usr/bin/env python3
"""
Statistical Analysis of IDS Performance Impact Data
Removes outliers using IQR method, calculates statistics with proper methods
"""

import pandas as pd
import numpy as np
from pathlib import Path
import json
from scipy import stats

# Configuration
DATA_DIR = Path(r"C:\Users\lizzardkink\OneDrive\Documents\Dev\itc\data")
CONFIGS = ['baseline', 'antivirus', 'firewall', 'both']
CONFIG_LABELS = {
    'baseline': 'Baseline (No IDS)',
    'antivirus': 'TotalAV Only',
    'firewall': 'Fort Firewall Only',
    'both': 'TotalAV + Fort Firewall'
}

def remove_outliers_iqr(data, column):
    """Remove outliers using Interquartile Range (IQR) method"""
    Q1 = data[column].quantile(0.25)
    Q3 = data[column].quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    
    original_count = len(data)
    filtered = data[(data[column] >= lower_bound) & (data[column] <= upper_bound)]
    removed_count = original_count - len(filtered)
    
    return filtered, removed_count, lower_bound, upper_bound

def calculate_statistics(data, column):
    """Calculate comprehensive statistics for a column"""
    return {
        'mean': data[column].mean(),
        'median': data[column].median(),
        'std': data[column].std(),
        'min': data[column].min(),
        'max': data[column].max(),
        'count': len(data),
        'cv': (data[column].std() / data[column].mean() * 100) if data[column].mean() != 0 else 0  # Coefficient of variation
    }

def analyze_boot_time():
    """Analyze boot time data"""
    print("\n" + "="*80)
    print("BOOT TIME ANALYSIS (Criterion A)")
    print("="*80)
    
    results = {}
    for config in CONFIGS:
        file = DATA_DIR / config / f"boot-time-{config}.csv"
        df = pd.read_csv(file)
        
        # Remove outliers
        df_clean, removed, lb, ub = remove_outliers_iqr(df, 'TotalBootTime')
        
        stats = calculate_statistics(df_clean, 'TotalBootTime')
        results[config] = stats
        
        print(f"\n{CONFIG_LABELS[config]}:")
        print(f"  Original samples: {len(df)}, Outliers removed: {removed}")
        print(f"  Mean: {stats['mean']:.2f}s, Median: {stats['median']:.2f}s")
        print(f"  Std Dev: {stats['std']:.2f}s, CV: {stats['cv']:.2f}%")
        print(f"  Range: [{stats['min']:.2f}s - {stats['max']:.2f}s]")
    
    # Calculate overhead
    baseline_mean = results['baseline']['mean']
    print(f"\nOVERHEAD vs BASELINE ({baseline_mean:.2f}s):")
    for config in ['antivirus', 'firewall', 'both']:
        overhead = ((results[config]['mean'] - baseline_mean) / baseline_mean) * 100
        print(f"  {CONFIG_LABELS[config]}: +{overhead:.2f}% ({results[config]['mean']:.2f}s)")
    
    return results

def analyze_ram_usage():
    """Analyze RAM consumption at startup"""
    print("\n" + "="*80)
    print("RAM USAGE ANALYSIS (Criterion B)")
    print("="*80)
    
    results = {}
    for config in CONFIGS:
        file = DATA_DIR / config / f"ram-startup-{config}.csv"
        df = pd.read_csv(file)
        
        # Remove outliers
        df_clean, removed, lb, ub = remove_outliers_iqr(df, 'UsedMemoryMB')
        
        stats = calculate_statistics(df_clean, 'UsedMemoryMB')
        results[config] = stats
        
        print(f"\n{CONFIG_LABELS[config]}:")
        print(f"  Original samples: {len(df)}, Outliers removed: {removed}")
        print(f"  Mean: {stats['mean']:.2f} MB, Median: {stats['median']:.2f} MB")
        print(f"  Std Dev: {stats['std']:.2f} MB, CV: {stats['cv']:.2f}%")
        print(f"  Range: [{stats['min']:.2f} - {stats['max']:.2f}] MB")
    
    # Calculate overhead
    baseline_mean = results['baseline']['mean']
    print(f"\nOVERHEAD vs BASELINE ({baseline_mean:.2f} MB):")
    for config in ['antivirus', 'firewall', 'both']:
        overhead = ((results[config]['mean'] - baseline_mean) / baseline_mean) * 100
        abs_overhead = results[config]['mean'] - baseline_mean
        print(f"  {CONFIG_LABELS[config]}: +{overhead:.2f}% (+{abs_overhead:.2f} MB)")
    
    return results

def analyze_process_count():
    """Analyze process count at startup"""
    print("\n" + "="*80)
    print("PROCESS COUNT ANALYSIS (Criterion C)")
    print("="*80)
    
    results = {}
    for config in CONFIGS:
        file = DATA_DIR / config / f"process-count-{config}.csv"
        df = pd.read_csv(file)
        
        # Remove outliers
        df_clean, removed, lb, ub = remove_outliers_iqr(df, 'ProcessCount')
        
        stats = calculate_statistics(df_clean, 'ProcessCount')
        results[config] = stats
        
        print(f"\n{CONFIG_LABELS[config]}:")
        print(f"  Original samples: {len(df)}, Outliers removed: {removed}")
        print(f"  Mean: {stats['mean']:.2f}, Median: {stats['median']:.2f}")
        print(f"  Std Dev: {stats['std']:.2f}, CV: {stats['cv']:.2f}%")
        print(f"  Range: [{stats['min']:.0f} - {stats['max']:.0f}]")
    
    # Calculate overhead
    baseline_mean = results['baseline']['mean']
    print(f"\nOVERHEAD vs BASELINE ({baseline_mean:.2f} processes):")
    for config in ['antivirus', 'firewall', 'both']:
        overhead = ((results[config]['mean'] - baseline_mean) / baseline_mean) * 100
        abs_overhead = results[config]['mean'] - baseline_mean
        print(f"  {CONFIG_LABELS[config]}: +{overhead:.2f}% (+{abs_overhead:.2f} processes)")
    
    return results

def analyze_app_launch():
    """Analyze application launch performance"""
    print("\n" + "="*80)
    print("APPLICATION LAUNCH ANALYSIS (Criterion D)")
    print("="*80)
    
    results = {}
    for config in CONFIGS:
        file = DATA_DIR / config / f"app-launch-{config}.csv"
        df = pd.read_csv(file)
        
        # Remove outliers
        df_clean, removed, lb, ub = remove_outliers_iqr(df, 'TimeSeconds')
        
        stats = calculate_statistics(df_clean, 'TimeSeconds')
        results[config] = stats
        
        print(f"\n{CONFIG_LABELS[config]}:")
        print(f"  Original samples: {len(df)}, Outliers removed: {removed}")
        print(f"  Mean: {stats['mean']:.2f}s, Median: {stats['median']:.2f}s")
        print(f"  Std Dev: {stats['std']:.2f}s, CV: {stats['cv']:.2f}%")
        print(f"  Range: [{stats['min']:.2f}s - {stats['max']:.2f}s]")
    
    # Calculate overhead
    baseline_mean = results['baseline']['mean']
    print(f"\nOVERHEAD vs BASELINE ({baseline_mean:.2f}s):")
    for config in ['antivirus', 'firewall', 'both']:
        overhead = ((results[config]['mean'] - baseline_mean) / baseline_mean) * 100
        print(f"  {CONFIG_LABELS[config]}: +{overhead:.2f}% ({results[config]['mean']:.2f}s)")
    
    return results

def analyze_smb_copy():
    """Analyze SMB file copy performance"""
    print("\n" + "="*80)
    print("SMB COPY PERFORMANCE ANALYSIS (Criterion E)")
    print("="*80)
    
    results = {}
    for config in CONFIGS:
        file = DATA_DIR / config / f"smb-copy-{config}.csv"
        df = pd.read_csv(file)
        
        # Remove outliers from speed
        df_clean, removed, lb, ub = remove_outliers_iqr(df, 'SpeedMBps')
        
        stats = calculate_statistics(df_clean, 'SpeedMBps')
        results[config] = stats
        
        print(f"\n{CONFIG_LABELS[config]}:")
        print(f"  Original samples: {len(df)}, Outliers removed: {removed}")
        print(f"  Mean: {stats['mean']:.2f} MB/s, Median: {stats['median']:.2f} MB/s")
        print(f"  Std Dev: {stats['std']:.2f} MB/s, CV: {stats['cv']:.2f}%")
        print(f"  Range: [{stats['min']:.2f} - {stats['max']:.2f}] MB/s")
    
    # Calculate overhead (negative = slower)
    baseline_mean = results['baseline']['mean']
    print(f"\nPERFORMANCE vs BASELINE ({baseline_mean:.2f} MB/s):")
    for config in ['antivirus', 'firewall', 'both']:
        change = ((results[config]['mean'] - baseline_mean) / baseline_mean) * 100
        sign = '+' if change >= 0 else ''
        print(f"  {CONFIG_LABELS[config]}: {sign}{change:.2f}% ({results[config]['mean']:.2f} MB/s)")
    
    return results

def analyze_ftp_download():
    """Analyze FTP download performance"""
    print("\n" + "="*80)
    print("FTP DOWNLOAD PERFORMANCE ANALYSIS (Criterion F)")
    print("="*80)
    
    results = {}
    for config in CONFIGS:
        file = DATA_DIR / config / f"ftp-download-{config}.csv"
        df = pd.read_csv(file)
        
        # Remove outliers from speed
        df_clean, removed, lb, ub = remove_outliers_iqr(df, 'SpeedMBps')
        
        stats = calculate_statistics(df_clean, 'SpeedMBps')
        results[config] = stats
        
        print(f"\n{CONFIG_LABELS[config]}:")
        print(f"  Original samples: {len(df)}, Outliers removed: {removed}")
        print(f"  Mean: {stats['mean']:.2f} MB/s, Median: {stats['median']:.2f} MB/s")
        print(f"  Std Dev: {stats['std']:.2f} MB/s, CV: {stats['cv']:.2f}%")
        print(f"  Range: [{stats['min']:.2f} - {stats['max']:.2f}] MB/s")
    
    # Calculate overhead (negative = slower)
    baseline_mean = results['baseline']['mean']
    print(f"\nPERFORMANCE vs BASELINE ({baseline_mean:.2f} MB/s):")
    for config in ['antivirus', 'firewall', 'both']:
        change = ((results[config]['mean'] - baseline_mean) / baseline_mean) * 100
        sign = '+' if change >= 0 else ''
        print(f"  {CONFIG_LABELS[config]}: {sign}{change:.2f}% ({results[config]['mean']:.2f} MB/s)")
    
    return results

def main():
    """Run all analyses and save results"""
    print("\n" + "="*80)
    print("IDS PERFORMANCE IMPACT ANALYSIS")
    print("Statistical Analysis with Outlier Removal (IQR Method)")
    print("="*80)
    
    all_results = {
        'boot_time': analyze_boot_time(),
        'ram_usage': analyze_ram_usage(),
        'process_count': analyze_process_count(),
        'app_launch': analyze_app_launch(),
        'smb_copy': analyze_smb_copy(),
        'ftp_download': analyze_ftp_download()
    }
    
    # Save results to JSON
    output_file = DATA_DIR / 'statistical_analysis.json'
    with open(output_file, 'w') as f:
        json.dump(all_results, f, indent=2)
    
    print("\n" + "="*80)
    print(f"Analysis complete! Results saved to: {output_file}")
    print("="*80 + "\n")
    
    return all_results

if __name__ == '__main__':
    results = main()
