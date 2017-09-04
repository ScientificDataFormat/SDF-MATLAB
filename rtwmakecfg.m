function makeInfo = rtwmakecfg()
%RTWMAKECFG adds include and source directories to the generated makefiles.

makeInfo.includePath = { fullfile(pwd, 'C', 'NDTable', 'include') };
makeInfo.sourcePath  = { fullfile(pwd, 'C', 'NDTable', 'src') };

end
