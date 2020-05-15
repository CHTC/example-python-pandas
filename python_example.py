import pandas as pd
import sys

# Read the first argument 
fruit = pd.read_csv(sys.argv[1])
# Read the second argument
vege = pd.read_csv(sys.argv[2])

# Merge to a new dataset
total = pd.merge(fruit, vege, on='name')

# Save to the csv file
total.to_csv('result.csv', index = None)