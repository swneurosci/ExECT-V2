List<Annotation> annList = new ArrayList<Annotation>(inputAS.get("PatientHistory"));
Collections.sort(annList, new OffsetComparator());

for (int i=0 ; i < annList.size() - 1 ; i++) {
  Annotation annI = annList.get(i);
  
  for (int j=i+1 ; j < annList.size() ; j++) {
    Annotation annJ = annList.get(j);
    
    if (annJ.getStartNode().getOffset().equals(annI.getStartNode().getOffset())
     && annJ.getEndNode().getOffset().equals(annI.getEndNode().getOffset()) ) {
        FeatureMap annJFM = annJ.getFeatures();
        FeatureMap annIFM = annI.getFeatures();
        String ruleNameannJFM = annJFM.get("rule");
        String ruleNameannIFM = annIFM.get("rule");
        annJFM.remove("rule");
        annIFM.remove("rule");
        if (annJFM.equals(annIFM)) {
            inputAS.remove(annI);
            annJFM.put("rule", ruleNameannJFM);
            annIFM.put("rule", ruleNameannIFM);
            gate.Utils.addAnn(doc.getAnnotations("Bio"), annJ.getStartNode().getOffset(), annJ.getEndNode().getOffset(), "PatientHistoryDupe", annIFM);
          } else {
            annJFM.put("rule", ruleNameannJFM);
            annIFM.put("rule", ruleNameannIFM);}
      break;
    }
  }
}