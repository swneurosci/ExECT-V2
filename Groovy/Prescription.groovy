new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Bio").get("PrescriptionCSV").each{
    anno ->
      def f = anno.getFeatures()
      def (A,B,C) =  doc.getFeatures().get("gate.SourceURL").split("_|\\.")
      String[] id = C.split("/")
      out.writeLine(/"${id[-1]}","${f.get('String1')}","CUI","${f.get('CUI')}","DrugDose","${f.get('DrugDose')}","DoseUnit","${f.get('DoseUnit')}","Frequency","${f.get('Frequency')}",/)
  }
}