new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Original markups").get("EpilepsyCause").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()}, ${f.get('CUI')},"${f.get('CUIPhrase')}",/+
      /"${f.get('string')}",${f.get('Negation')},${f.get('Certainty')}/)
    }
  } 