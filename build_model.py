from ngram import NGramModel
from pickle import dump
from sys import argv, exit

if len(argv) < 3:
    print 'usage: python2 %s num_grams docs_file' % argv[0]
    exit()

n          = int(argv[1])
docs_file  = argv[2]
corpus     = [ line.strip().decode('utf8') for line in open(docs_file, 'r') ]
model_file = docs_file.replace('.txt', '') + '_%dgram.pkl' % n
model      = NGramModel(n, corpus=corpus)

model.train()
model.save(model_file)
