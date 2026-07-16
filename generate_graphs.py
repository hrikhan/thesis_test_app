import matplotlib.pyplot as plt
import numpy as np

# Use a clean style
plt.style.use('seaborn-v0_8-darkgrid')

# ==========================================
# 1. Figure 3.39: Response Time Line Graph
# ==========================================
# API endpoints relevant to a Rural Medical App
endpoints = ['Login', 'List Doctors', 'Patient Profile', 'Medical History', 'Book Appt']
rest_times = [120, 280, 340, 480, 200]
graphql_times = [115, 190, 210, 240, 180]

fig1, ax1 = plt.subplots(figsize=(9, 5))
ax1.plot(endpoints, rest_times, marker='o', label='REST API', linewidth=2, color='#e74c3c')
ax1.plot(endpoints, graphql_times, marker='s', label='GraphQL', linewidth=2, color='#2ecc71')

ax1.set_title('Figure 3.39: Response Times (REST vs GraphQL)', fontsize=14, fontweight='bold')
ax1.set_xlabel('Medical API Operations', fontsize=12)
ax1.set_ylabel('Response Time (ms)', fontsize=12)
ax1.legend(fontsize=11)
plt.tight_layout()
fig1.savefig('figure_3_39_response_times.png', dpi=300, bbox_inches='tight')


# ==========================================
# 2. Figure 3.40: CPU/Memory Bar Chart
# ==========================================
labels = ['REST API', 'GraphQL']
# Simulated data for mobile client parsing the data
memory_usage = [42.5, 34.2] # Memory in MB
cpu_usage = [15.1, 12.8]    # CPU usage in %

x = np.arange(len(labels))
width = 0.35

fig2, ax2 = plt.subplots(figsize=(8, 5))
rects1 = ax2.bar(x - width/2, memory_usage, width, label='Memory (MB)', color='#3498db')
rects2 = ax2.bar(x + width/2, cpu_usage, width, label='CPU Usage (%)', color='#f39c12')

ax2.set_ylabel('Resource Consumption', fontsize=12)
ax2.set_title('Figure 3.40: Client App Resource Consumption', fontsize=14, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels(labels, fontsize=11)
ax2.legend(fontsize=11)

# Add values on top of bars
def autolabel(rects):
    for rect in rects:
        height = rect.get_height()
        ax2.annotate(f'{height}',
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3), 
                    textcoords="offset points",
                    ha='center', va='bottom', fontweight='bold')

autolabel(rects1)
autolabel(rects2)

plt.tight_layout()
fig2.savefig('figure_3_40_resource_usage.png', dpi=300, bbox_inches='tight')


# ==========================================
# 3. Figure 3.41: Payload Distribution (Pie)
# ==========================================
# Comparing the data payload for a complex query like "Get Patient Full Profile"
rest_payload = [40, 60] # 40% Required Data, 60% Overfetched/Redundant Data
graphql_payload = [100] # 100% Required Data, no overfetching

fig3, (ax3a, ax3b) = plt.subplots(1, 2, figsize=(10, 5))
fig3.suptitle('Figure 3.41: Payload Data Distribution (Efficiency)', fontsize=15, fontweight='bold')

labels_pie = ['Required Data', 'Overfetched Data']
colors = ['#2ecc71', '#e74c3c']

ax3a.pie(rest_payload, labels=labels_pie, autopct='%1.1f%%', startangle=140, colors=colors, explode=(0, 0.05), shadow=True)
ax3a.set_title('REST API Payload (Patient Profile)', fontsize=12)

ax3b.pie(graphql_payload, labels=['Required Data'], autopct='%1.1f%%', startangle=90, colors=['#2ecc71'], shadow=True)
ax3b.set_title('GraphQL Payload (Patient Profile)', fontsize=12)

plt.tight_layout()
fig3.savefig('figure_3_41_payload_distribution.png', dpi=300, bbox_inches='tight')

print("Success! Created 3 images.")
