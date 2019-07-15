function [prob, lbw, ubw, lbg, ubg] = GenerateNLP(model,data, variables, constraints)
%variables and constraints used through GUI
%variables : Xk values to be constrained
%constraints : col1 = low, col2 = up

%orientates towards the NLP generator corresponding to the method wanted

% Optimize through direct collocation
if strcmpi(data.NLPMethod, 'Collocation')
    if strcmpi(data.collocMethod,'legendre')
        if nargin > 2, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Legendre(model, data, variables, constraints);
        else, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Legendre(model, data);
        end
    elseif strcmpi(data.collocMethod,'hermite')
        if nargin > 2, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Hermite(model, data, variables, constraints);
        else, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Hermite(model, data);
        end
    elseif strcmpi(data.collocMethod,'trapezoidal')
        if nargin > 2, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Trapezoidal(model, data, variables, constraints);
        else, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_Collocation_Trapezoidal(model, data);
        end
    end
% Use direct multiple shooting
else
    if nargin > 2, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_DMS(model, data, variables, constraints);
    else, [prob, lbw, ubw, lbg, ubg] = GenerateNLP_DMS(model, data);
    end
end
end

