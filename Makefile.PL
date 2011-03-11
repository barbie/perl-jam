use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'perl-jam',
    'VERSION'		=> '0.03',
    'PREREQ_PM'		=> {},
    'dist'=> {COMPRESS=>'gzip -f9', SUFFIX=>'gz'},
);
