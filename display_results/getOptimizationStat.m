function optStat = getOptimizationStat(str)

model = str.model;
QVU = str.QVU;
stat = str.stat;

optRep = [];
repnb = size(QVU,3);
coefTwist = -model.Unitcoef(model.dof.Twist);

for i=1:repnb
   if strcmpi(stat.returnStat{i}, 'Solve_Succeeded') || ...
           strcmpi(stat.returnStat{i}, 'Solved_To_Acceptable_Level') 
       optRep = [optRep i];
   end
end

opt = size(optRep,2)*100/repnb;
meanV.opt = mean(QVU(model.dof.Twist, end, optRep)*coefTwist); 
meanV.nonOpt = mean(QVU(model.dof.Twist, end, :)*coefTwist); 
minV.opt = min(QVU(model.dof.Twist, end, optRep)*coefTwist); 
minV.nonOpt = min(QVU(model.dof.Twist, end, :)*coefTwist); 
maxV.opt = max(QVU(model.dof.Twist, end, optRep)*coefTwist); 
maxV.nonOpt = max(QVU(model.dof.Twist, end, :)*coefTwist);
med.opt = median(QVU(model.dof.Twist, end, optRep)*coefTwist); 
med.nonOpt = median(QVU(model.dof.Twist, end, :)*coefTwist);  
stdev.opt = std(QVU(model.dof.Twist, end, optRep)*coefTwist); 
stdev.nonOpt = std(QVU(model.dof.Twist, end, :)*coefTwist);  

optStat.mean = meanV;
optStat.min = minV;
optStat.max = maxV;
optStat.med = med;
optStat.stdev = stdev;
optStat.nbOpt = opt;


end