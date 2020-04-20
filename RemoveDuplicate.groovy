List<Annotation> annList = new ArrayList<Annotation>(inputAS.get("PatientHistory"));
Collections.sort(annList, new OffsetComparator());

for (int i=0 ; i < annList.size() - 1 ; i++) {
  Annotation annI = annList.get(i);
  
  for (int j=i+1 ; j < annList.size() ; j++) {
    Annotation annJ = annList.get(j);
    
    if (annJ.getStartNode().getOffset().equals(annI.getStartNode().getOffset())
        && annJ.getEndNode().getOffset().equals(annI.getEndNode().getOffset()) ) {
      inputAS.remove(annI);
      break;
    }
  }
}
