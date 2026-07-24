/// Reason codes required when marking a report as Fabricated.
/// Prevents officers from tagging "fabricated" on a whim — see design notes.
const List<String> fabricatedReasonCodes = [
  'Reporter admitted report was invented',
  'Evidence reused/unrelated to claimed event',
  'Metadata contradicts reported time/location',
  'Description contains self-contradictory details',
  'Pattern of fictitious reports from same reporter',
];
