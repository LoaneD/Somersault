function setNLP(src, event)

obj = getOBJ(true, false);

if src == obj.fig.nlp
    if src.Value ~= 1
        obj.fig.colloc.Visible = 'on';
        obj.fig.collocC.Visible = 'on';
    else
        obj.fig.colloc.Visible = 'off';
        obj.fig.collocC.Visible = 'off';
        obj.fig.collocDegree.Visible = 'off';
        obj.fig.collocDegreeC.Visible = 'off';
    end
else
    if src.Value == 3
        obj.fig.collocDegree.Visible = 'on';
        obj.fig.collocDegreeC.Visible = 'on';
    else
        obj.fig.collocDegree.Visible = 'off';
        obj.fig.collocDegreeC.Visible = 'off';
    end
end

setOBJ(obj);

end