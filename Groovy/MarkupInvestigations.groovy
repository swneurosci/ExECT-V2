new File(scriptParams.outputFile).withWriterAppend{ out ->
  doc.getAnnotations("Original markups").get("Investigations").each{
    anno ->
      def f = anno.getFeatures()
      String[] id = \
       doc.getFeatures().get("gate.SourceURL").split("/")

      out.writeLine(/${id[-1]},${anno.start()},${anno.end()},/+
      /${f.get('CUI')},"${f.get('CUIPhrase')}","${f.get('string')}",/+
      / ${f.get('CT_Performed')},${f.get('CT_Results')},${f.get('MRI_Performed')},/+
      /${f.get('MRI_Results')},${f.get('EEG_Performed')},${f.get('EEG_Type')},/+
      /${f.get('EEG_Results')},${f.get('Certainty')},${f.get('Negation')}/)
     }
}
//when a string/phrase may have "," one needs "" around the feature ectracted