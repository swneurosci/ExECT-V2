new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Epilepsy").get("SeizureFrequency").each{
    anno ->
      def f = anno.getFeatures()
      def (A,B,C) =  doc.getFeatures().get("gate.SourceURL").split("_|\\.")
      String[] id = C.split("/")
      out.writeLine(/"${id[-1]}","${f.get('string')}","${f.get('CUI')}","${f.get('NumberOfTimePeriods')}","${f.get('LowerNumberOfTimePeriods')}","${f.get('UpperNumberOfTimePeriods')}","${f.get('TimePeriod')}","${f.get('FrequencyChange')}","${f.get('NumberOfSeizures')}","${f.get('LowerNumberOfSeizures')}","${f.get('UpperNumberOfSeizures')}","${f.get('DayDate')}","${f.get('MonthDate')}","${f.get('YearDate')}","${f.get('PointInTime')}","${f.get('Age')}","${f.get('AgeUnit')}","${f.get('AgeLower')}","${f.get('AgeUpper')}","${f.get('rule')}",/)
    }
  }