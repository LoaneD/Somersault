Lancer interface graphique : somersaultGUI() --> penser à changer les chemins d'accès des dossiers.
[si folders casadi et scripts déjà intégrés dans la path, possibilité de juste lancer loadGUI() pour pas clean tout].

Avant de lancer l'optimisation plusieurs paramètres peuvent être choisis (et les unités peuvent être changées) :
	- durée de la simulation (part défaut 1 sec)
***Paramètres au décollage :
	- la hauteur initiale (défaut 0 m)
	- le nombre de salto (défaut 0 révolution)
	- le nombre de twist (défaut 0 révolution)
	- vitesse horizontale (défaut 0 m/s)
	- vitesse verticale (défaut 4,9 m/s : pour atterir à une altitude de 0 m selon la dynamique du modèle)
	- vitesse de rotation de salto (défaut 6,3 rad/s) : case à cocher si on souhaite la laisser libre et optimisable.
	- vitesse de rotation de twist (défaut 0 rad/s)
***Paramètres à l'arrivée (une valeur et un range acceptable) :
	- hauteur finale (par défaut pas de contrainte dessus)
	- nombre de salto (par défaut pas de contrainte dessus)
	- nombre de vrille (par défaut pas de contrainte dessus)
	- valeur du tilt (par défaut pas de contrainte dessus)
***Options d'optimisation :
	- nombre d'intervalles utilisés (défaut 30 : si on choisit un modèle à 10 DoF avec moins de 75 intervalles message pour conseiller d'augmenter)
	- nombre de simulations lancées (défaut 10)
	- temps maximal (défaut Inf) : à chaque nouvelle répétition lanée, vérifie que ce temps n'a pas été dépassé
	- fonction objective : maximiser le twist, maximiser le twist en minimisant le torque, minimiser la trajectoire des bras, minimiser le torque
	- méthode NLP utilisée : direct multiple shooting ou direct collocation
	- méthode de collocation (si collocation sélectionnée comme NLP) : trapézoïdale, hermite ou legendre
	- nombre de degré polynomial (si collocation de legendre est choisie)
	- degrés de liberté du modèle : élévation des bras (ne peut pas être enlevé), rotation des bras (à cocher)

Une fois que l'optimisation est finie un message s'affiche avec les sorties du solveur : combien de solutions optimales ont été trouvées
Pour afficher les résultats (case à cocher si on veut afficher également les résultats non optimaux, s'affichent alors en rouge) :
	- liste déroulante pour choisir si on veut n'afficher que la meilleure solution (BEST), celles au dessus de 95% de la meilleure ou toutes (ALL)
	- liste déroulante avec les numéros de simulations (de la meilleure à la moins bonne)
	- champs avec la valeur de l'objective (ou du twist si c'est optimisation du twist avec pondération du torque choisi)
	- champs avec la valeur correspondant à quel pourcentage de la meilleure solution la solution sélectionnée correspond
	- choix d'afficher juste les mouvement de bras ou les mouvements de la racine aussi
	- choix d'afficher la cinématique ou juste les courbes trajectoires des degrés de liberté