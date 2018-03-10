use strict;
use Test2::V0;
use Test2::Plugin::UTF8;

use FindBin;
use lib "$FindBin::Bin/lib/perl5";

use JSON::XS;
use Path::Tiny;

use DDP;

use constant COMPILE => 'cd java && javac App.java';
use constant EXEC    => 'cd java && java App';

my %test_files = (
  1 => [ 't/test_1-1.json', 't/test_closed_1-1.json' ],
  2 => [ 't/test_1-2.json', 't/test_closed_1-2.json' ],
  3 => [ 't/test_1-3.json', 't/test_closed_1-3.json' ],
);

# main
sub {
  chdir "$FindBin::Bin/..";

  while( my ($problem, $files) = each %test_files ) {
    for my $file ( @$files ) {
      my $patterns = decode_json( path($file)->slurp );
      test($problem, $patterns);
    }
  }
}->();


sub test {
  my ($problem, $patterns) = @_;

  system COMPILE;
  for my $pattern ( @$patterns ) {
    subtest $pattern->{title} => sub {
      my $input = $pattern->{input};
      if ($input eq '') { $input = q/''/ }
      my $command = EXEC . ' ' . $problem . ' ' . $input . ' 2> /dev/null';

      # say STDERR $command;
      my $output = qx|$command|;
      my $rc = $?;
      $rc = $rc >> 8 unless ($rc == -1);

      is $rc, $pattern->{code}, 'return code';

      my $output_exp = join "", map { "$_\n" } @{$pattern->{output}};
      is $output, $output_exp, 'output';
    };
  }
}

done_testing;
