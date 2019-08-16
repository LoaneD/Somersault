README 
######

**Pour utiliser une fonction externe par mex file pour l'optimisation : utiliser le script GenerateODE_mex au lieu de GenerateODE

**Pour changer la méthode de NLP il faut changer les champs de la variable data (NLPMethod, collocMethod, degree) : si la méthode choisie est bien définie dans les champs de data, le script GenerateNLP se débrouille pour définir la bonne

**Pour ajouter des contraintes de non transpersion au modèle il faut utiliser le script model = GenerateTranspersionConstraints(model) lors de la création du model (juste pour 10 DoF ou plus : il suffit de définir dans GenerateModel différentes variables : model.markers.name, model.markers.collisionP (paires de segments entre lesquels il y a risque de collision), model.markers.dmin (distance min au delà de laquelle il y a transpersion entre les paires), model.markers.parents, model.markers.coordinates, model.markers.param (les segments sont des ellipsoïdes donc ça correspond aux longueurs des 3 axes))

**Pour lancer une optimisation il faut utiliser la fonction optim : dernier input peut être variable (si on rentre QVU, model, data ça utilise les solutions optimales passées en paramètres pour la répétition voulue, si w0 rentré utilise les même solutions initiales)

*****Champs possible de la variable data :
- duration : int (si pas de champs mentionné, la durée est laissée libre et optimisable dans un range 0.85-1.15 sec, modifiable dans les scripts de génération NLP et GenerateW0)
- Nint : int, nombre d'intervalles voulus
- odeMethod : rk4 si classique, rk4_dt pour changer la façon dont sont créés les intervalles, sundials (pas étudié)
- si rk4_dt : champs dt pour indiauer soit log (décroissance logarithmique des durées d'intervalles), soit a (décroissance affine)
- obj : fonction objective (twist, twistPond : controle Ry*0.01 + controle Rz*10 modifiable dans GenerateODE, trajectory, torque)
- NLPMethod : MultipleShooting ou Collocation
- si Collocation : collocMethod (legendre, hermite, trapezoidal)
- si legendre : degree (int)
- freeSomerSpeed : si ce champs existe la vitesse initiale du salto est laissée optimisable. Si une valeur numérique est associée à ce champs la fonction objective devient pondérée par cette valeur initiale par un coefficient égal à la valeur mise pour le champs freeSomerSpeed