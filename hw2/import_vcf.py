import os
from google.cloud import storage
from google.cloud import bigquery
from google.cloud.bigquery import SchemaField
 
# TODO(developer): Set dataset_id to the ID of the dataset.
dataset_id = 'jm_gene222_hw2_q3'
 
# TODO(developer): Set project_id to the ID of the GCP project.
project_id = 'gene222-hw2-349119'
 
def main(event, context):
   """Triggered by a change to a Cloud Storage bucket.
   Args:
        event (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
   """
 
   print('Event ID: {}'.format(context.event_id))
   print('Event type: {}'.format(context.event_type))
   print('Bucket: {}'.format(event['bucket']))
   print('File: {}'.format(event['name']))
 
   try:
       client = bigquery.Client()
 
       table_id = '{}.{}.{}'.format(project_id,dataset_id,os.path.splitext(event['name'])[0])
 
       #uri = "gs://gene222_datasets/sample.csv"
       uri = 'gs://{}/{}'.format(event['bucket'],event['name'])
 
       job_config = bigquery.LoadJobConfig()
       job_config.schema = [
               bigquery.SchemaField("chrm", "STRING"),
               bigquery.SchemaField("start_position", "INTEGER"),
               bigquery.SchemaField("end_position", "INTEGER"),
               bigquery.SchemaField("reference_bases", "STRING"),
               bigquery.SchemaField("alternate_bases", "STRING"),
               bigquery.SchemaField("rsID", "STRING"),
               bigquery.SchemaField("qual", "STRING"),
               bigquery.SchemaField("filter", "STRING"),
               bigquery.SchemaField("info", "STRING"),                   
           ]
       job_config.skip_leading_rows=1
       load_job = client.load_table_from_uri(
           uri, table_id, job_config=job_config
       )  # Make an API request.
 
       # Check whether table exists and create if not
       try:
           table = client.get_table(table_id)
       except:
           table = bigquery.Table(table_id)
 
       load_job.result()  # Wait for the job to complete.
 
       table = client.get_table(table_id)
       print("Loaded {} rows to table {}".format(table.num_rows, table_id))
      
       return f"OK"
   except Exception as e:
       print(e)
       return (e, 500) 
