# Figure 2: specification curve, drawn from the Stata output (Table S5).
# Run: python3 docs/bai_nckh/figures/fig2_specification_curve.py
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, '..', '..', '..', 'output', 'tables', 'stata', 'table_s5.csv')
OUT = os.path.join(HERE, 'fig2_specification_curve.png')
INK, MUTED, GRID = '#1a1a1a', '#8c8c8c', '#e3e3e3'
plt.rcParams.update({'font.family': 'Liberation Serif', 'font.size': 10})

d = pd.read_csv(SRC).sort_values('b_sd').reset_index(drop=True)
d['rank'] = d.index + 1
parts = d.spec.str.split('|', expand=True)
d['index'], d['ctl'], d['lgbt'], d['tg'] = parts[0], parts[1], parts[2], parts[3]
main = d.spec == 'S|XD|self|keep'

rows = [('Index: 8-situation mean (main)', d['index'] == 'S'),
        ('Index: 7-situation mean', d['index'] == 'S7'),
        ('Index: count of situations', d['index'] == 'S_count8'),
        ('Index: complete 8 only', d['index'] == 'S_complete8'),
        ('Covariates: X$^D$ + X$^J$', d.ctl == 'XDXJ'),
        ('LGBT: self-identification + SOGI', d.lgbt == 'consistent'),
        ('Transgender and nonbinary excluded', d.tg == 'drop')]

fig, (top, bot) = plt.subplots(2, 1, figsize=(9, 6.2), sharex=True, gridspec_kw={'height_ratios': [3, 2]})
fig.subplots_adjust(left=0.30, right=0.98, top=0.97, bottom=0.09, hspace=0.08)
top.axhline(0, color=MUTED, lw=0.9, ls=(0, (4, 3)))
top.vlines(d['rank'], d.lb_sd, d.ub_sd, color=MUTED, lw=1.1)
top.scatter(d.loc[~main, 'rank'], d.loc[~main, 'b_sd'], s=22, color=INK, zorder=3, label='Other specifications')
top.scatter(d.loc[main, 'rank'], d.loc[main, 'b_sd'], s=46, marker='D', facecolor='white', edgecolor=INK,
            linewidth=1.4, zorder=4, label='Main specification')
top.set_ylabel('PHQ-4 difference per SD\nof the stigma index (95% CI)')
top.grid(axis='y', color=GRID, lw=0.6)
top.set_axisbelow(True)
top.legend(frameon=False, loc='upper left')
for s in ('top', 'right'):
    top.spines[s].set_visible(False)

for i, (lab, on) in enumerate(rows):
    y = len(rows) - i
    bot.scatter(d['rank'], [y] * len(d), s=14, marker='s', color=GRID, zorder=1)
    bot.scatter(d.loc[on, 'rank'], [y] * int(on.sum()), s=14, marker='s', color=INK, zorder=2)
bot.set_yticks(range(len(rows), 0, -1))
bot.set_yticklabels([r[0] for r in rows])
bot.set_ylim(0.4, len(rows) + 0.6)
bot.set_xlabel('Specification (ranked by estimate)')
bot.set_xticks([1, 8, 16, 24, 32])
bot.set_xlim(0.3, len(d) + 0.7)
bot.tick_params(axis='y', length=0)
for s in ('top', 'right', 'left'):
    bot.spines[s].set_visible(False)

fig.savefig(OUT, dpi=300)
print(OUT)
