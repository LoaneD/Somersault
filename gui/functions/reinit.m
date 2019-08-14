function reinit(~, ~)

obj = getOBJ(true, false);
obj.fig.heightTO.String = '0';
obj.fig.somerTO.String = '0';
obj.fig.twistTO.String = '0';
obj.fig.vhTO.String = '0';
obj.fig.vvTO.String = '4.9';
obj.fig.wsomerTO.String = '6.3';
obj.fig.wtwistTO.String = '0';

obj.fig.heightL.String = '0';obj.fig.heightRL.Value = 1;
obj.fig.somerL.String = '1';obj.fig.somerRL.Value = 1;
obj.fig.tiltL.String = '0';obj.fig.tiltRL.Value = 1;
obj.fig.twistL.String = '0';obj.fig.twistRL.Value = 1;

obj.fig.obj.Value = 1;
obj.fig.nlp.Value = 1;
obj.fig.rep.String = '10';
obj.fig.time.String = '60';
obj.fig.int.String = '30';

obj.fig.armE.Value = 1;
obj.fig.armR.Value = 0;
obj.fig.wsomerTO_u.Value = 1;
obj.fig.wtwistTO_u.Value = 1;
obj.fig.somerTO_u.Value = 1;
obj.fig.twistTO_u.Value = 1;

set(obj.fig.vvTOfree, 'Visible', 'off');
set(obj.fig.durfree, 'Visible', 'off');
set(obj.fig.vvTO, 'ForegroundColor', 'k');

obj.fig.colloc.Visible = 'off';
obj.fig.collocC.Visible = 'off';
obj.fig.collocDegree.Visible = 'off';
obj.fig.collocDegreeC.Visible = 'off';

setOBJ(obj);

end