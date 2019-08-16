######################
## README RESULTATS ##
######################
Voir google sheet pour résultats

DMS : Direct Multiple Shooting
DC : Direct Collocation
DL : Degré de Liberté
CnT = Contraintes de non Transpersion

-- Param 2 :
Contraintes : tilt [-15 ; 15]°, bras en haut, 1 salto ± 5°, non transpersion
Bornes U : [-10;-100;10;100]
Bornes Rz bras : [-pi/4;3*pi/4] droit [-3*pi/4;pi/4] gauche
Maximum itérations : 3000


Affichage des résultats : README script ResultsDisplay.m
#########################################################
--ResultsDisplay.m : script à utiliser pour afficher différents résultats :
Créer une structure avec tous les modèles voulus (3 champs : model, data, stat + rajouter vecteur de temps + QVU)

	**getIntegratedSolution : pour les modèles où la collocation est utilisée, permet de calculer les trajectoires obtenues par intégration seule (propagée ou sur chaque intervalle) ainsi que les erreurs entre cette intégration et la collocation.

	**checkCollocationErrors : pour chaque répétition de chaque modèle avec collocation permet d'afficher les comparaisons entre intégration et collocation : 
		- une figure traçant la trajectoire optimale par collocation, la trajectoire obtenue en intégrant sur chaque intervalle et celle obtenue en propageant l'intégration (à chaque début d'intervalle on utilise en point de départ l'arrivée de l'intégration précédente).
		- une figure traçant la trajectoire optimale par collocation et l'intégrale de l'état au début sur tout l'intervalle.
		- une figure traçant les erreurs calculées à chaque instant du temps (début et fin des intervalles).

	**compareCollocationErrors : global sur toutes les répétitions d'un modèle avec collocation, affiche la moyenne des erreurs (à chaque instant la moyenne des erreurs calculées pour chaque répétition). Plusieurs modèles peuvent être tracés sur la même figure pour les comparer.

	**displayAllResults : affiche pour chaque modèle, pour chaque répétition les trajectoires et vitesses de chaque degré de liberté.

	**results (ArmMovement, Twisting, TwistNumber, SomerNumber) : pour chaque modèle affiche les résultats pour chaque simulation sur un même graphique (soit les 2 ou 4 DL des bras, soit le twist, soit les nombres de twist et saltos). Possibilité de choisir de n'afficher que les solutions optimales ou de tout afficher.

	**comparaisonModels (SolStats, ComparaisonArm, ComparaisonTwist) : affiche pour tous les modèles entrés ou les sorties du solveur ou les moyennes des mouvements de bras ou les moyennes de trajectoire de twist.

	**generateKinematics2 : affiche la visualisation de la cinématique.

	**getOptimizationStat : retourne les valeurs max/min de la fonction objective, la moyenne, la médiane, l'écart type ainsi que le taux de convergence pour chaque modèle. Valeurs pour toutes les simulations ou ne prenant en compte que les solutions optimales.