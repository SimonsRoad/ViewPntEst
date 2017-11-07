function info = get_metadata(data,info,fileno)
global METADATA;

if isempty(METADATA) || ~strcmp(METADATA.name,data)
  fprintf('Loading metadata %s\n',data);
  global CONF;
  load([CONF.exp_dir data]);
  METADATA.name = data;
end

switch info
  case 'file_names'
    info = METADATA.file_names;
    if exist('fileno','var')
      info = info{fileno};
    end
    
  case 'train_frame_count'
    info = METADATA.train_frame_count;
    if exist('fileno','var')
      info = info(fileno);
    end
  
  case 'num_files'
    info = length(METADATA.file_names);
  
  case 'valtrain_indx'
    if ~isfield(METADATA, 'val_indx')
      info = []; return;
    end
    info = [];
    count = 1;
    for i = 1: length(METADATA.file_names)
      fileind = count:count + METADATA.train_frame_count(i)-1;
      fileind(METADATA.val_indx{i}) = [];
      info = [info fileind];
      count = count + METADATA.train_frame_count(i);
    end
    
  case 'valtest_indx'
    if ~isfield(METADATA, 'val_indx')
      info = []; return;
    end
    info = [];
    count = 1;
    for i = 1: length(METADATA.file_names)
      info = [info METADATA.val_indx{i}+count-1];
      count = count + METADATA.train_frame_count(i);
    end
    
  case 'val_indx'
    if isfield(METADATA,'val_indx')
      info = METADATA.val_indx;
      if exist('fileno','var')
        info = info{fileno};
      else
        info = cell2mat(info);
      end
    else
      info = [];
    end
    
  case 'val_frame_count'
    if ~isfield(METADATA,'val_frame_count')
      METADATA.val_frame_count = zeros(length(METADATA.file_names),1);
    end
    
    info = METADATA.val_frame_count;
    if exist('fileno','var')
      info = info(fileno);
    end
    
  case 'test_frame_count'
    info = METADATA.test_frame_count;
    if exist('fileno','var')
      info = info(fileno);
    end
    
  otherwise
    error('Unknown info!');
end
end