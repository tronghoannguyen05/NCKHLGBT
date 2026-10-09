# Figure 1: simplified causal diagram used to select covariates.
# Run: python3 docs/bai_nckh/figures/fig1_causal_diagram.py
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

GREY, BLUE, RED = '#4d4d4d', '#2b6cb0', '#a8323a'
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fig1_causal_diagram.png')

fig, ax = plt.subplots(figsize=(10, 5.6))
ax.set_xlim(0, 100)
ax.set_ylim(0, 56)
ax.axis('off')


def box(x, y, w, h, text, edge=GREY, face='white', dashed=False):
    ax.add_patch(FancyBboxPatch((x - w / 2, y - h / 2), w, h, boxstyle='round,pad=0.4,rounding_size=1.2',
                                linewidth=1.6, edgecolor=edge, facecolor=face,
                                linestyle=(0, (4, 3)) if dashed else '-'))
    ax.text(x, y, text, ha='center', va='center', fontsize=9.5, linespacing=1.35)


def arrow(p, q, color=GREY, rad=0.0, dashed=False, lw=1.6):
    ax.add_patch(FancyArrowPatch(p, q, arrowstyle='-|>', mutation_scale=14, color=color, lw=lw,
                                 connectionstyle=f'arc3,rad={rad}', linestyle=(0, (4, 3)) if dashed else '-',
                                 shrinkA=0, shrinkB=0))


box(50, 49, 62, 8, 'Pre-exposure characteristics ($X^D$)\nage, sex assigned at birth, education, relationship status, region of work')
box(15, 28, 25, 8, 'Workplace stigma ($S$)\nself-reported, previous 12 months')
box(50, 28, 28, 8, 'Job characteristics ($X^J$)\nindustry, position, organization size,\nsocial insurance, working hours')
box(85, 28, 23, 8, 'PHQ-4\nself-reported, previous 2 weeks', edge=BLUE, face='#eaf2fb')
box(50, 6, 40, 7, '$U$: unobserved factors\nstress outside work, personality', dashed=True)

arrow((34, 44.6), (20, 32.4))
arrow((50, 44.6), (50, 32.4))
arrow((66, 44.6), (80, 32.4))
arrow((27.9, 29.5), (35.6, 29.5))
arrow((35.6, 26.5), (27.9, 26.5))
arrow((64.4, 28), (73.1, 28))
arrow((22, 23.6), (78, 23.6), color=BLUE, rad=0.32, lw=2.4)
arrow((80, 32.4), (22, 32.4), color=RED, rad=0.22, dashed=True)
arrow((40, 10.4), (17, 23.4), dashed=True)
arrow((60, 10.4), (83, 23.4), dashed=True)

ax.text(50, 13.6, 'η: estimand', ha='center', va='center', fontsize=10, color=BLUE)
ax.text(86, 40.5, 'recall bias,\nreverse causation', ha='center', va='center', fontsize=9.5, color=RED)

fig.tight_layout()
fig.savefig(OUT, dpi=220)
print(OUT)
