new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("Prescription").each{
    anno ->
       def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()},/+
      /${f.get('CUI')},"${f.get('DrugName')}",${f.get('DrugDose')},${f.get('DoseUnit')},/+
      /${f.get('Frequency')},"${f.get('string')}",${f.get('rule')}/)
  }
}

//Only kept "" for phrases which are likly to contain "," ; if "" are used for other features then the output is given in "" too
 