function msgOutput(obj)

text = '';

if obj.repDone == 0
    text = 'No simulation completed.';
else
    outputs{1} = obj.opt.stat.returnStat{1};
    outputsNum(1) = 1;
    for i=2:obj.repDone
        if ismember(obj.opt.stat.returnStat{i},outputs(:,1))
            index = find(contains(outputs,obj.opt.stat.returnStat{i}));
            outputsNum(index) = outputsNum(index) + 1;
        else
            outputs{size(outputs,1)+1} = obj.opt.stat.returnStat{i};
            outputsNum(size(outputsNum,1)+1) = 1;
        end
    end
    for i=1:size(outputs,2) 
        text = [text;strcat(outputs{i}, {': '}, num2str(outputsNum(i)))];
    end 
end

uiwait(msgbox(cellstr(text), 'Optimisation results', 'modal'));

end