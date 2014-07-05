from pickle import load
from sys import argv, exit

if len(argv) < 2:
    print 'usage: python2 %s num_sents model_pickle' % argv[0]
    exit()

n_sents = int(argv[1])
model   = load(open(argv[2], 'r'))

for s in model.generate(n_sents):
    print s
