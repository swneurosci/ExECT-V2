new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("Diagnosis").each{
    anno ->
      def f = anno.getFeatures()
      //def (A,B,C,D) =  doc.getFeatures().get("gate.SourceURL").split("_|\\.")
      //String[] id = D.split("/")
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()}, ${f.get('CUI')},"${f.get('PREF')}",/+
      /${f.get('Negation')},${f.get('DiagCategory')},${f.get('Certainty')},${f.get('rule')},/)
    }
  } 

  //This extracts annotations and features in a csv format (.csv has to be specified in
  // scriptParams when the PR is run). Based on the script in GATE documentation,
  // commenting out the middle line makes it more universal (I think)