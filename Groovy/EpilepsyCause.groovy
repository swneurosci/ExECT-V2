new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("EpilepsyCause").each{
    anno ->
      def f = anno.getFeatures()
      String[] id =  doc.getFeatures().get("gate.SourceURL").split("/")
      out.writeLine(/${id[-1]},${anno.start()},${anno.end()}, ${f.get('CUI')},"${f.get('PREF')}",/+
      /${f.get('Negation')},${f.get('Experiencer')},${f.get('Certainty')},${f.get('rule')},/)
    }
  } 
//Produces output of annotations and features for Epilepsy Cause - for the whole corpus
  //Only kept "" for phrases which are likly to contain "," ; if "" are used for other features then the output is given in "" too