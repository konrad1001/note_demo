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
Week 4. Word Meaning
Transformation Based Learning
Start with a simple solution to the problem
Apply transformations to get best results, eg correcting mistakes
Repeat until no more improvement

Two phases, learning phase then application phase. 
Use a rule based approach to decide when to change tag x to y. 

Initially, give words their most likely tag. This wont be fully right
Learn transformations (rules) that correct errors from tagged data.

Word Senses
Word sense refers to one of the meanings of a word
(WSD) Word sense disambiguation is the task of selecting the correct sense for a given word
Useful for machine translation

Approaches could be knowledge based, like using an external lexical resource such as a dictionary, or supervised machine learning approaches, using labelled training examples

The simplified lesk algorithm examines overlap between sense definition of a word and its current context. 
Retrieve from the dictionary all sense definitions of a word to be analysed
Calculate the overlap (words in common) between sense definition and words in its surrounding context

Week 5. Deep Learning
DL mostly refers to NN based techniques for building end to end systems, and are able to take raw objects as the input. 
No manual preprocessing 
State of the art in NLP tasks

Recurrent Neural Network
An RNN is any network that contains a cycle within its network connections, the value of some unit is directly, or indirectly dependent on its own earlier outputs as an input. 

Lend themselves greatly to the sequential nature of language. The hidden layer from the previous time step provides a form of memory/context that encodes earlier processing and informs decision making in later points in time. 

Well introduce a new set of weights U that connect the hidden layer from the previous time step to the current hidden layer. 

