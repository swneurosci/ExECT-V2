# ExECT-V2
This application uses the General Architecture for Text Engineering (GATE) framework. This is available at https://gate.ac.uk/. A guide for GATE is available here https://gate.ac.uk/sale/tao/index.html.

ExECTv2 builds on ExECTv1 (https://pubmed.ncbi.nlm.nih.gov/30940752/) extracting a wider range of variables,  including epilepsy onset, cause, age of diagnosis, comorbidities and unclassified seizures or seizure-like events (as patient history). Epilepsy terms have been expanded and updated to include the latest ILAE classifications. 


To run the application in GATE developer after downloading 

•	Open GATE

•	Select FILE (Restore application from file) and open epilepsy.exgapp

•	In language resources create document corpus and populate with text files (using the directory URL  - GATE User Guide section 3.3)

We recommend that the groovy outputs remain off in the pipeline. If you wish to produce annotation outputs in CSV format, turn them on and edit the outputFile value in the scriptParams variable to your Path/Folder (Guide section 7.16).

When running on 1000s of documents, we recommend using The GATE Cloud Paralleliser (GCP). This is available at https://github.com/GateNLP/gcp. A guide for GCP is available here https://gate.ac.uk/gcp/doc/gcp-guide.pdf. An example of batch.xml file is provided in the Other folder.

We have provided a sample of 200 synthetic documents with gold standard annotations here https://zenodo.org/records/8381080.
A validation script is provided in the Validation folder. The CSVs used can be downloaded from https://zenodo.org/records/12520180.
