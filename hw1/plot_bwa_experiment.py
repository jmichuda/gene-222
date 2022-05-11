import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
df = pd.DataFrame({
    "threads":[1,2,4,8,16],
    "execution time":[86.291,62.018,23.221,12.558,8.781],
    "efficiency":[1,0.6957,0.9290,0.8589,0.6141],
})
sns.lineplot(x ="threads", y = "execution time", data=df, color="g")
ax2 = plt.twinx()
sns.lineplot(x ="threads", y = "efficiency", data = df, color="b", ax=ax2)
