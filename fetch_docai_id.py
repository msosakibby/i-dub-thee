import os, sys
from google.cloud import documentai

client = documentai.DocumentProcessorServiceClient()
parent = client.common_location_path("i-dub-thee", "us")

for p in client.list_processors(parent=parent):
    if p.display_name == "forensic-form-parser":
        print(p.name.split('/')[-1])
        sys.exit(0)
