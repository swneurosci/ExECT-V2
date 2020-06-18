new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Original markups").get("BirthHistory").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()},${f.get('CUI')},/+
      /"${f.get('CUIPhrase')}","${f.get('string')}",${f.get('Negation')},${f.get('Certainty')}/)
    }
  } 
  //Extracting markup annotations brought into GATE, when features are a string use "" around it.