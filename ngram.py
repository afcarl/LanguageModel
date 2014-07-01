import numpy as np
from nltk.corpus import stopwords
from nltk.tokenize import sent_tokenize
from random import choice

class NGramModel:

    TAG_START = '__BEGIN__SENTENCE__'
    TAG_STOP  = '__END__SENTENCE__'

    def __init__(self, N, corpus=[]):
        """Initialize a NGramModel

        Args:
            corpus: list of string documents, should already be cleaned
            N: value of N for N-grams, must be between 1 and 5
        """
        if not isinstance(N, int):
            raise TypeError("N must be an integer")
        if N < 1 or N > 5:
            raise ValueError("N must be between 1 and 5")
        self.N = N
        self.corpus = corpus
        self.ngrams = {}
        self.starts = []


    def addDocument(self, doc):
        sents = sent_tokenize(doc)
        for sent in sents:
            tokens = sent.split() + [self.TAG_STOP]

            if len(tokens) < self.N:
                next

            self.starts.append( tuple(tokens[:self.N]) )

            for i in range(len(tokens) - self.N):
                
                first = tuple(tokens[i:i+self.N])
                last  = tokens[i+self.N]

                if first in self.ngrams:
                    self.ngrams[first].append(last)
                else:
                    self.ngrams[first] = [last]


    def train(self, corpus=None):
        """Train the N-gram model on the documents
        """
        if corpus is None:
            # Use current corpus
            corpus = self.corpus
        else:
            # Replace current corpus with new one
            self.corpus = corpus

        # Purge n-gram stats
        self.ngrams = {}
        for doc in corpus:
            self.addDocument(doc)

        return self


    def generate(self, n_sents=3):
        """Generate random sentences.

        Sentences end when a period ('.') is encountered during generation.

        Args:
            n_sents: number of sentences/phrases to generate

        Returns:
            List of sentence strings
        """
        sents = []
        for i in range(n_sents):
            curr = choice(self.starts)
            sent = list(curr)
            while sent[-1] != self.TAG_STOP:
                if curr in self.ngrams:
                    sent.append( choice(self.ngrams[curr]) )
                    curr = tuple(sent[-self.N:])
                else:
                    break
            sents.append(sent[:-1]) # don't include stop tag
        return sents


class BigramModel(NGramModel):
    def __init__(self, corpus=[]):
        NGramModel.__init__(self, 2, corpus=corpus)

class TrigramModel(NGramModel):
    def __init__(self, corpus=[]):
        NGramModel.__init__(self, 3, corpus=corpus)
