function H80KSubmit(featname)
% H80KSubmit generates the result files that are accepted by our server.
small_4000;

ofilename = [CONF.exp_dir 'GlobalFeatures/' featname '/' featname '__trial_0001.results'];
hf = fopen( ofilename,'w+');

% experiment name
fwrite(hf,4,'uint8');
fwrite(hf,'H80K','char');

% feature type
predfeatname = 'D3_Positions_mono';
fwrite(hf,length(predfeatname),'uint8');
fwrite(hf,predfeatname,'char');
fwrite(hf,1,'uint8');
fwrite(hf,0,'uint8'); % no parts

filenames = get_metadata('human36m_big','file_names');

fwrite(hf,uint16(length(filenames)),'uint16');
fprintf(1,'Sequences: %03d | %03d\n',0,length(filenames)); 
for s = 1: length(filenames)
	fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bSequences: %03d | %03d\n',s,15); 
  
  load([CONF.exp_dir 'GlobalFeatures/' featname '/' filenames{s}],'Ftest');
  Ftest = Ftest - repmat(Ftest(:,1:3),1,32);% center the predictions just in case
  
	% name of sequence
	fwrite(hf,length(filenames{s}),'uint8'); 
  fwrite(hf, filenames{s},'char');
	[N, D] = size(Ftest);
	fwrite(hf,N,'uint16'); fwrite(hf,D,'uint16');
	for i = 1: N
		fwrite(hf,single(Ftest(i,:)),'float');
	end
end
fclose(hf);

disp(['Saved results to file ' ofilename]);

end