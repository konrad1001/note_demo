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

tf.idf = tf  idf

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
