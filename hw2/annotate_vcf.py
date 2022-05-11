import os
import json
import base64
 
from google.cloud import bigquery
from google.cloud import storage
 
STORAGE_BUCKET = 'jm-gene222-hw2-q3-annotated'
 
def main(event, context):
   """Triggered from a message on a Cloud Pub/Sub topic.
   Args:
        event (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
   """
  
   print(f"This Function was triggered by messageId {context.event_id} published at {context.timestamp}.")
 
   #if 'data' in event:
   data = base64.b64decode(event['data']).decode('utf-8')
   print(f"> Pubsub data: {data}.")
   print(f"> Context: {context}.")
 
   data = json.loads(data)
 
   # Example: "projects/gbsc-gcp-class-gene222-spr22/datasets/1000g/tables/1000g_APC_PBR"
   resource_name = data["protoPayload"]["resourceName"]
   elements = resource_name.split("/")
   project_id = elements[1]
   dataset_id = elements[3]
   table_name = elements[5]
 
   table_id = f"{project_id}.{dataset_id}.{table_name}"
 
   client = bigquery.Client()
   # Perform a query.


   ANNOTATION_QUERY = (f"""
     SELECT
 A.chrm,
 A.start_position,
 A.end_position,
 A.reference_bases,
 A.alternate_bases,
 rsID,
 qual,
 FILTER,
 info,
 Ensembl_geneid,
 MutPred_AAchange
FROM (
 SELECT
   chrm,
   start_position,
   end_position,
   reference_bases,
   alternate_bases,
   rsID,
   qual,
   FILTER,
   info
 FROM
   `{table_id}`) AS A
JOIN (
 SELECT
   reference_name,
   start_position,
   end_position,
   reference_bases,
   alternate_bases,
   Ensembl_geneid,
   MutPred_AAchange
 FROM
   `gbsc-gcp-class-gene222-spr22.hw2.hg38_dbNSFP_35a`) AS B
ON
 A.chrm=B.reference_name
 AND A.start_position=B.start_position
 AND A.end_position=B.end_position
 AND A.alternate_bases=B.alternate_bases""")
 
 
   query_job = client.query(ANNOTATION_QUERY)  # API request
   rows = query_job.result()  # Waits for query to finish
  
   rows_string = ""
   for row in rows:
     rows_string += f"{row['chrm']},{row['start_position']},{row['end_position']},{row['rsID']},{row['Ensembl_geneid']}" + "\n"
 
   storage_client = storage.Client()
   bucket = storage_client.get_bucket(STORAGE_BUCKET)
   composed_blob = bucket.blob( table_name + "-apc-gene-annotations.vcf")
   composed_blob.upload_from_string(rows_string)

