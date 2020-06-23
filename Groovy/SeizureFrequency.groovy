new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("SeizureFrequency").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()}, ${f.get('CUI')},/+
      /"${f.get('string')}",${f.get('FrequencyChange')},${f.get('NumberOfSeizures')},/+
      /${f.get('LowerNumberOfSeizures')},${f.get('UpperNumberOfSeizures')},${f.get('TimePeriod')},/+
      /${f.get('NumberOfTimePeriods')},${f.get('LowerNumberOfTimePeriods')},/+
      /${f.get('UpperNumberOfTimePeriods')},${f.get('TimeSince_or_TimeOfEvent')},/+
      /${f.get('YearDate')},${f.get('MonthDate')},${f.get('DayDate')},${f.get('PointInTime')},/+
      /${f.get('Age')},${f.get('AgeLower')},${f.get('AgeUpper')},${f.get('AgeUnit')},/+
      /${f.get('Certainty')},${f.get('Negation')},${f.get('rule')}/)
    }
  }
  //extracting seizure frequency into a csv format output