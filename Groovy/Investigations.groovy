new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Output").get("Investigations").each{
    anno ->
      def f = anno.getFeatures()
      String[] id = \
       doc.getFeatures().get("gate.SourceURL").split("/")

      out.writeLine(/${id[-1]},${anno.start()},${anno.end()},/+
      /${f.get('CUI')},${f.get('CT_Performed')},${f.get('CT_Results')},/+
      /${f.get('MRI_Performed')},${f.get('MRI_Results')},${f.get('EEG_Performed')},${f.get('EEG_Type')},/+
      /${f.get('EEG_Results')},${f.get('Certainty')},${f.get('Negation')},${f.get('rule')}/)
     }
}

   //Only kept "" for phrases which are likly to contain "," ; if "" are used for other features then the output is given in "" too 