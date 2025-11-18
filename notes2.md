Week 2
What is a game?
Multiple agents
Numerical outcomes ’ each player receives a pay off, which are given by real numbers
Clearly defined rules

Game Trees
Idea: Games can be represented as trees
Nodes are decision points
Edges are possible moves/actions from that decision
Root is the starting point
Leaves are the final outcomes with pay-offs

Each node encodes the complete history of the game so far.

Missing features in game tree
Chance. Dice/cards
Imperfect information
Simultaneous moves

Chance
Introduce nature as a special player.
Nature controls all chance moves
Nature is not assigned a pay off.
Branches from natures tree are labelled with probabilities 
In the game tree: add nodes where it is nobodies turn, labelled with probabilities of given events.

Imperfect Information
Players may not know exactly where they are in the game tree. Introduce information sets.
Group the nodes the player cannot distinguish between
Draw these nodes in the same bubble
Players must choose the same action for all nodes in an information set.

Nodes in the same information set:
Must belong to the same player
Must have identical available actions
