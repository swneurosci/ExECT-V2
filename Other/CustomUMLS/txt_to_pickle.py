from simstring.feature_extractor.character_ngram import CharacterNgramFeatureExtractor
from simstring.database.dict import DictDatabase
import pickle

# Create database and term_to_cui pickle files
def simstring_database(umls, nchar_val):
    db = DictDatabase(CharacterNgramFeatureExtractor(nchar_val))
    term_to_cui = dict()

    for value in umls:
        try:
            data = value.split('\t')
            cui = data[0]
            term = data[1].lower()
            db.add(term)
            term_to_cui[term] = cui
        except:
            continue

    pickle.dump(db, open('db.pickle', 'wb'))
    pickle.dump(term_to_cui, open('term_to_cui.pickle', 'wb'))

umls = open('custom_umls.txt', encoding='utf8').read().split('\n')
simstring_database(umls, 2)

