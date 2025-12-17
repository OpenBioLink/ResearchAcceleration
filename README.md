<h3><big><big><big>What are the limits to biomedical research acceleration through general-purpose AI?</big></big></big></h3>
<sub>Hebenstreit, K., Convalexius, C., Reichl, S., Huber, S., Bock, C., & Samwald, M. (2025)</sub>

---

General-purpose artificial intelligence (GPAI) is widely expected to transform scientific discovery, but in biomedicine its real-world impact remains uncertain. This study provides a systematic analysis of how much current biomedical research could realistically be accelerated by GPAI, and where fundamental limits remain.

<table>
<tr>
<td width="50%" valign="top">
<div style="height: 300px; display: flex; align-items: center; justify-content: center;">
<img src="results/manually_created_plots/Fig2-major_research_tasks.png" width="100%" style="max-height: 100%; width: auto;">
</div>
<div style="padding-right: 30px;">
<h3 align="center">Research Tasks</h3>
<p>We mapped the biomedical research lifecycle into <b>nine major tasks</b>:</p>
<p><b>Cognitive</b> (blue): information processing, analysis, decision-making<br>
<b>Physical</b> (red): lab procedures, experiment execution</p>
</div>
</td>
<td width="50%" valign="top">
<div style="height: 300px; display: flex; align-items: center; justify-content: center;">
<img src="results/plots/accelerations_plot.png" width="80%" style="max-height: 100%; width: auto;">
</div>
<div style="padding-left: 30px;">
<h3 align="center">Acceleration Estimates</h3>
<p>Scoping review of 16 publications reveals a bimodal distribution:</p>
<p><b>Next-level:</b> ~2x (current, partial automation)<br>
<b>Maximum-level:</b> ~100x cognitive, ~25x physical</p>
</div>
</td>
</tr>
</table>

## Biological Time Constants

Large task-level speed-ups do not translate into equivalent reductions in overall project duration. Many biomedical projects are constrained by biological processes that cannot be compressed (cell growth, organism development, disease progression).

**Modeling a hypothetical 3-year project** with 3 months of incompressible biological time:

| Project duration | Physical: No GPAI | Physical: Next-level (2x) | Physical: Max-level (25x) |
|---|:---:|:---:|:---:|
| **Cognitive: No GPAI** | 36 months | 32 months | 27 months |
| **Cognitive: Next-level (2x)** | 24 months | 20 months | 15 months |
| **Cognitive: Max-level (100x)** | 12 months | 7.7 months | **3.6 months** |

Even with maximum acceleration, the lower bound is **~3.6 months** (10x overall), with biological time dominating.

## Expert Elicitation

Eight senior biomedical researchers evaluated our maximum-level acceleration estimates:

<p align="center">
  <img src="results/plots/project_times_plot.png" width="70%">
</p>

Experts reported average project durations of **~6 years** for high-impact publications. While they considered strong acceleration plausible for **manuscript preparation** and **publication processes**, they were skeptical about dramatic speed-ups in **hypothesis generation**, **experiment design**, and **execution**.

<p align="center">
  <img src="results/plots/plausibility_estimates_plot.png" width="48%">
  <img src="results/plots/limitation_estimates_plot.png" width="48%">
</p>

**Key bottleneck:** All experts identified **scientific community assimilation** as a moderate to crucial limit.

Realizing the full potential of GPAI-driven research acceleration will require coordinated investments in automation infrastructure, improved data accessibility, and reforms in research organization and publication practices.

## Citation

If you find our work useful in your research, please cite:

**Scientific Reports (2025)**

> Hebenstreit, K.†, Convalexius, C.†, Reichl, S.†, Huber, S., Bock, C., & Samwald, M. (2025).
> **What are the limits to biomedical research acceleration through general-purpose AI?**
> *Scientific Reports* (in publication).

**ArXiv Preprint (2025)**

> Hebenstreit, K.†, Convalexius, C.†, Reichl, S.†, Huber, S., Bock, C., & Samwald, M. (2025).
> **What are the limits to biomedical research acceleration through general-purpose AI?**
> doi: [10.48550/arXiv.2508.16613](https://doi.org/10.48550/arXiv.2508.16613)

† Equal contribution

## Code & Data

This repository contains the data and R scripts used to generate the figures:

| Figure | Description | Data | Script |
|:---:|---|---|---|
| 1 | GPAI Capability Framework | — | [`plot_capability_model.R`](src/plot_capability_model.R) |
| 2 | Major Research Tasks | — | *(graphical software)* |
| 3 | Acceleration Factors | [`Acceleration_Factors_...csv`](data/Acceleration_Factors_with_Ranges_and_Midpoints_clean.csv) | [`plot_accelerations.R`](src/plot_accelerations.R) |
| 4 | Project Time Durations | [`anonymized_data_project_times.csv`](data/anonymized_data_project_times.csv) | [`plot_project_times.R`](src/plot_project_times.R) |
| 5 | Plausibility Estimates | [`anonymized_data_plausibility_estimates.csv`](data/anonymized_data_plausibility_estimates.csv) | [`plot_plausibility_estimates.R`](src/plot_plausibility_estimates.R) |
| 6 | Limiting Factors | [`anonymized_data_limiting_factors.csv`](data/anonymized_data_limiting_factors.csv) | [`plot_limitation_estimates.R`](src/plot_limitation_estimates.R) |
