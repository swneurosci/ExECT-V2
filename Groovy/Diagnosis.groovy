new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Epilepsy").get("Diagnosis").each{
    anno ->
      def f = anno.getFeatures()
      def (A,B,C) =  doc.getFeatures().get("gate.SourceURL").split("_|\\.")
      String[] id = C.split("/")
      out.writeLine(/"${id[-1]}","${f.get('CUI')}","${f.get('Negation')}","${f.get('Certainty')}","${f.get('rule')}",/)
    }
  }