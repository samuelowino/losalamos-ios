# Los Alamos: Performance and Concurrency Labs

This series of labs focuses on evaluating performance issues and concurrency in iOS applications. The goal is to investigate UI freezes, data processing times, and persistence overhead. 

## Zero-Optimization Benchmark Data
<img width="1102" alt="Screenshot 2024-12-21 at 08 01 24" src="https://github.com/user-attachments/assets/92e0428d-7d49-4291-a3f0-08f5f2c1b452" />

The benchmark involves loading **2 million rows of data** and rendering them using `LazyVGrid`.

### Execution Time

The execution time across 10 runs was recorded as follows:

| EXECUTION | Duration                     |
|-----------|------------------------------|
| 1         | 37 seconds : 73 milliseconds |
| 2         | 37 seconds : 66 milliseconds |
| 3         | 36 seconds : 83 milliseconds |
| 4         | 37 seconds : 72 milliseconds |
| 5         | 36 seconds : 52 milliseconds |
| 6         | 37 seconds : 31 milliseconds |
| 7         | 36 seconds : 38 milliseconds |
| 8         | 36 seconds : 03 milliseconds |
| 9         | 36 seconds : 46 milliseconds |
| 10        | 36 seconds : 61 milliseconds |

---

Execution Time (in seconds) - X-Y Line Graph

```
Time (seconds)
38 ┤                                       
37 ┤ ⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️
36 ┤ ⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️
35 ┤ ⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️⏱️
21 ┤
20 ┤
    └────────────────────────────────────────────
     1  2  3  4  5  6  7  8  9  10
                Execution Number

```


#### **Key Insights**
- **Average Execution Time**: Approximately **36.77 seconds**.
- **Variation**: Minimal, indicating consistent execution.
- Optimizations may improve the rendering pipeline or data handling.

---

### Memory Usage

Memory usage during 5 executions is summarized below:

| EXECUTION | Result RAM | Peak RAM |
|-----------|------------|----------|
| 1         | 37.1 MB    | 1.24 GB  |
| 2         | 37.2 MB    | 1.22 GB  |
| 3         | 37.2 MB    | 1.26 GB  |
| 4         | 37.2 MB    | 1.22 GB  |
| 5         | 37.1 MB    | 1.22 GB  |

#### **Key Insights**
- **Result RAM**: Consistent at ~37.1–37.2 MB.
- **Peak RAM Usage**: High, ranging from **1.22 GB to 1.26 GB**.
- Potential areas for optimization include memory allocation during peak data rendering and garbage collection.

---

### CPU Usage

- **Rest CPU**: Below 0%, indicating negligible background activity.
- **Execution CPU**: Sustained at **98%**, reflecting heavy computation during data processing.

#### **Key Insights**
- CPU resources are being fully utilized during execution, which may lead to contention with other processes.
- Parallelization strategies could alleviate high CPU usage and improve performance.

---

## Recommendations

1. **Execution Time Optimization**:
   - Implement lazy-loading techniques to optimize row handling.

2. **Memory Management**:
   - Investigate memory spikes during peak usage and implement pooling or caching strategies.
   - Analyze potential memory leaks or inefficient allocation patterns.

3. **CPU Utilization**:
   - Explore multithreading or concurrent processing to distribute CPU load.
   - Profile the code to identify bottlenecks in data processing and rendering pipelines.

---

This benchmark serves as a baseline to track performance improvements as optimization techniques are applied.
 
