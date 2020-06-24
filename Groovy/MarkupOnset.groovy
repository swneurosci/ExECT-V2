new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Original markups").get("Onset").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()}, ${f.get('CUI')},/+
      /"${f.get('CUIPhrase')}","${f.get('string')}",${f.get('TimePeriod')}, ${f.get('NumberOfTimePeriods')},/+
      /${f.get('LowerNumberOfTimePeriods')},${f.get('UpperNumberOfTimePeriods')},/+
      / ${f.get('YearDate')},${f.get('MonthDate')},${f.get('DayDate')},${f.get('PointInTime')},/+
      /${f.get('Age')},${f.get('AgeLower')},${f.get('AgeUpper')},${f.get('AgeUnit')},/+
      /${f.get('Certainty')},${f.get('Negation')},${f.get('Experiencer')},${f.get('rule')}/)
    }
  }
  //Extracting Markup Onset annotations, csv format