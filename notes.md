Week 1
Intro
How do we get computers to perform tasks that relate to human language?

The majority of data is unstructured (video, audio, documents), about 10-20% is structured (databases, tables).

Why is this important?

A lot of information needs to be in some way processed by machines, for moderation, translation etc.

Week 2
A model is an abstract representation of something, often in a computational form
E.g tossing a coin

How do we represent a piece of text?

One approach is bag of words, unstructured

Stop words: high frequency occurring words with low distinguishing power for determining a documents meaning (and, the etc.)

Inverse Document Frequency
Document frequency is the number of documents that contain the term t.

tf.idf = tf idf

tf = 1+ log(tf)
idf = log(N/df)

Increases when the number of occurrences is high in a document, and the term is rare amongst other documents.

Week 3. Preprocessing
Before we can start

Document conversion, pdf images etc.
Language identification
What genre? What domain? Might need specific resources

Tokenisation
Goal: break input into basic units of text. Tokens.
These are not necessarily simple whitespace delimited sequences.
This can be tricky! Depending on how sentences are parsed.

Week 3. Preprocessing
Before we can start

Document conversion, pdf images etc.
Language identification
What genre? What domain? Might need specific resources

Tokenisation
Goal: break input into basic units of text. Tokens.
These are not necessarily simple whitespace delimited sequences.
This can be tricky! Depending on how sentences are parsed.

The main goal is to split, not to combine. Avoid over segmentation.

Could we go lower than words?
Character level tokenisation. Character n-grams
Subword tokenisation. Tokens can be parts of words as well as whole words

Normalisation
Next step is to normalise the text without removing its meaning.
Map tokens into normalised forms. {walks, walked, walking} walk
Lemmatisation
Reduction to the dictionary head word
{am, are, is} be
{life, lives} life
Could use dictionary look up, though this could be slow.
Stemming
Take an axe to it, no messing around
Simply remove the suffixes.
Result may yield non words
Much quicker
Danger of under/over stemming
Case folding, convert everything to lowercase
Good for collecting stats and behaviours of words
Good for search engine
Can lose a lot of data. Proper nouns for names etc.
