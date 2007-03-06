C=1;
order=20;
order_com=5;
mismatch=0;
len=200;
shift=100;
num=100;
num_test=5000;
cache=10;

acgt='ACGT';
rand('state',1);
traindat1=acgt(ceil(4*rand(len,num)));
traindat2=acgt(ceil(4*rand(len,num)));
traindat3=rand(len,num);
traindat4=rand(len,num);
trainlab=[-ones(1,num/2),ones(1,num/2)];

testdat1=acgt(ceil(4*rand(len,num_test)));
testdat2=acgt(ceil(4*rand(len,num_test)));
testdat3=rand(len,num_test);
testdat4=rand(len,num_test);
testlab=[-ones(1,num/2),ones(1,num_test/2)];
x=ceil(linspace(1,shift,len));
shifts = sprintf( '%i ', x(end:-1:1) );

sg('send_command', 'loglevel ALL');
sg('send_command','clean_features TRAIN');
sg('send_command','clean_features TEST');
sg('send_command','clean_kernels');
sg('send_command', 'use_linadd 1' );
sg('send_command', 'use_batch_computation 1');

sg('add_features', 'TRAIN', traindat1, 'DNA');
sg('add_features', 'TRAIN', traindat2, 'DNA');
sg('send_command', sprintf('convert TRAIN SIMPLE CHAR SIMPLE WORD DNA %i %i', order_com, order_com-1 ) );
sg('send_command', 'clean_preproc' );
sg('send_command', 'add_preproc SORTWORD');
sg('send_command', 'attach_preproc TRAIN');
sg('add_features', 'TRAIN', traindat3);
sg('send_command', 'add_preproc LOGPLUSONE');
sg('send_command', 'add_preproc LOGPLUSONE');
sg('send_command', 'add_preproc PRUNEVARSUBMEAN');
sg('send_command', 'attach_preproc TRAIN');
sg('add_features', 'TRAIN', traindat4);
sg('set_labels', 'TRAIN', trainlab);

sg('add_features', 'TEST', testdat1, 'DNA');
sg('add_features', 'TEST', testdat2, 'DNA');
sg('send_command', sprintf('convert TEST SIMPLE CHAR SIMPLE WORD DNA %i %i', order_com, order_com-1 ) );
sg('add_features', 'TEST', testdat3);
sg('add_features', 'TEST', testdat4);
sg('set_labels', 'TEST', testlab);
sg('send_command', 'attach_preproc TEST');
%
sg('send_command', sprintf( 'set_kernel COMBINED %i', cache) );
sg('send_command', sprintf( 'add_kernel 1.0 WEIGHTEDDEGREEPOS3 CHAR 10 %i %i %i 1 %s', order, mismatch, len, shifts ) );
sg('send_command', sprintf( 'add_kernel 1.0 COMM WORD 10 0' ) );
sg('send_command', sprintf( 'add_kernel 1.0 LINEAR REAL 10 1.0' ) );
sg('send_command', sprintf( 'add_kernel 4.0 GAUSSIAN REAL 10 1.0' ) );
sg('send_command', 'set_kernel_optimization_type FASTBUTMEMHUNGRY' );
%sg('send_command', 'set_kernel_optimization_type SLOWBUTMEMEFFICIENT' );
sg('send_command', 'init_kernel TRAIN');
%kt=sg('get_kernel_matrix');
sg('send_command', 'new_svm LIGHT');
sg('send_command', sprintf('c %f',C));
tic; sg('send_command', 'svm_train'); t=toc
[b, alphas]=sg('get_svm');

tic;
sg('send_command', 'init_kernel TEST');
outopt=sg('svm_classify');
tout=toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sg('send_command', 'loglevel ALL');
sg('send_command','clean_features TRAIN');
sg('send_command','clean_features TEST');
sg('send_command','clean_kernels');
sg('send_command', 'use_linadd 1' );
sg('send_command', 'use_batch_computation 0');

sg('add_features', 'TRAIN', traindat1, 'DNA');
sg('add_features', 'TRAIN', traindat2, 'DNA');
sg('send_command', sprintf('convert TRAIN SIMPLE CHAR SIMPLE WORD DNA %i %i', order_com, order_com-1 ) );
sg('send_command', 'clean_preproc' );
sg('send_command', 'add_preproc SORTWORD');
sg('send_command', 'attach_preproc TRAIN');
sg('add_features', 'TRAIN', traindat3);
sg('send_command', 'add_preproc LOGPLUSONE');
sg('send_command', 'add_preproc LOGPLUSONE');
sg('send_command', 'add_preproc PRUNEVARSUBMEAN');
sg('send_command', 'attach_preproc TRAIN');
sg('add_features', 'TRAIN', traindat4);
sg('set_labels', 'TRAIN', trainlab);
%
sg('add_features', 'TEST', testdat1, 'DNA');
sg('add_features', 'TEST', testdat2, 'DNA');
sg('send_command', sprintf('convert TEST SIMPLE CHAR SIMPLE WORD DNA %i %i', order_com, order_com-1 ) );
sg('add_features', 'TEST', testdat3);
sg('add_features', 'TEST', testdat4);
sg('set_labels', 'TEST', testlab);
sg('send_command', 'attach_preproc TEST');
%
sg('send_command', sprintf( 'set_kernel COMBINED %i', cache) );
sg('send_command', sprintf( 'add_kernel 1.0 WEIGHTEDDEGREEPOS3 CHAR 10 %i %i %i 1 %s', order, mismatch, len, shifts ) );
sg('send_command', sprintf( 'add_kernel 1.0 COMM WORD 10 0' ) );
sg('send_command', sprintf( 'add_kernel 1.0 LINEAR REAL 10 1.0' ) );
sg('send_command', sprintf( 'add_kernel 4.0 GAUSSIAN REAL 10 1.0' ) );
%sg('send_command', 'set_kernel_optimization_type FASTBUTMEMHUNGRY' );
sg('send_command', 'set_kernel_optimization_type SLOWBUTMEMEFFICIENT' );
sg('send_command', 'init_kernel TRAIN');
%ktref=sg('get_kernel_matrix');
sg('send_command', 'new_svm LIGHT');
sg('send_command', sprintf('c %f',C));
tic; sg('send_command', 'svm_train'); tref=toc
[bref, alphasref]=sg('get_svm');
tic;
sg('send_command', 'init_kernel_optimization');
sg('send_command', 'init_kernel TEST');
outoptref=sg('svm_classify');
toutref=toc

outopt(1:10)
outoptref(1:10)
max(abs(outopt-outoptref))

t
tref
tout
toutref
