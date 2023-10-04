function model = new_tsmodel
%function model = new_tsmodel

n     = struct( 'nper', 0, 'ndisp', 0, 'ndeltav', 0, 'nlogs', 0, 'nexp', 0, 'ntanhs', 0);

t     = struct( 'td', [], 'tdeltav', [], 'tl', [], 'te', [], 'tth', []);

tau   = struct( 'ltau', [], 'etau', [], 'thtau', []);

model = struct( 'periodics', [], 'disp', [], 'deltav', [], 'logs', [], ...
                'exponentials', [], 'tanhs', [], ...
                'np', [], 't_ep', []', 'n', n, 't', t, 'tau', tau, ...
                'parlist', [], 'parval', [], 'parcov', []);
                
return
