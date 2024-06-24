# ExECT-V2
This application uses the General Architecture for Text Engineering (GATE) framework. This is available at https://gate.ac.uk/. A guide for GATE is available here https://gate.ac.uk/sale/tao/index.html.

Text files are populated to a corpus using the directory URL (Guide section 3.3). 
We recommend switching the groovy outputs off in the pipeline. If you wish to use them, please edit the outputFile value in the scriptParams variable to your Path/Folder (Guide section 7.16). 

When running on 1000s of documents, we recommend using The GATE Cloud Paralleliser (GCP). This is available at https://github.com/GateNLP/gcp. A guide for GCP is available here https://gate.ac.uk/gcp/doc/gcp-guide.pdf. An example of batch.xml file is provided in the Other folder.

We have provided a sample of 200 synthetic documents with gold standard annotations here https://zenodo.org/records/8381080.

A validation script is provided in the Validation folder. The CSVs used can be downloaded here LINKforCSVsFROMExECT and here https://zenodo.org/records/12520180. 


