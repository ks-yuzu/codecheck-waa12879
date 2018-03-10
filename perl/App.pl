#!/usr/bin/env perl
use v5.12;
use warnings;
use diagnostics;

use utf8;
use open IO => qw/:encoding(UTF-8) :std/;

use FindBin;
use lib "$FindBin::Bin/lib/perl5";

use List::Util qw/max/;
use List::MoreUtils qw/pairwise/;
use Clone qw/clone/;

use constant TRUE  => 1;
use constant FALSE => 0;


sub usage {
  warn("usage:");
  warn("  java App 1 [0-9]+");
  warn("  java App 2 [01]+");
  warn("  java App 3 [A-Za-z]+");
}

# コマンドライン引数のチェック
sub validate_args {
  my ($problem, $input) = @_;

  if ( $problem =~ /[^0-9]+/ ) { return FALSE }

  if    ( $problem == 1 ) { return $input =~ /^[0-9]+$/    ? TRUE : FALSE }
  elsif ( $problem == 2 ) { return $input =~ /^[01]+$/     ? TRUE : FALSE }
  elsif ( $problem == 3 ) { return $input =~ /^[A-Za-z]+$/ ? TRUE : FALSE }
  else                    { return FALSE }  # 存在しない問題
}


# 引数  : 入力文字列, 部分列の切れ目の判定用のコールバック
# 戻り値: 各種部分列の最初の文字のインデックスのリスト
sub get_beginning_indexes_of_parts {
  my ($input, $separate_checker) = @_;

  my $pos_begin = [0];
  for my $i ( 1 .. length($input) - 1 ) {
    my $prev    = substr($input, $i - 1, 1);
    my $current = substr($input, $i    , 1);
    push @$pos_begin, $i if $separate_checker->($prev, $current);
  }
  return $pos_begin;
}


sub usage_and_exit {
  usage();
  exit(1);
}


sub main {
  # 引数チェック
  if    ( scalar(@_) < 2 ) { usage_and_exit() }
  elsif ( scalar(@_) > 2 ) { warn("warn: Too many arguments (ignore 3rd and following ones)"); }

  my ($problem, $input) = @_;
  if ( $input eq "" )       { return 0; }
  if ( !validate_args(@_) ) { usage_and_exit() }

  # 部分列の境界判定用コールバックの選択
  my $separate_checker;
  if    ( $problem == 1 ) { $separate_checker = sub { $_[0] >= $_[1] } }
  elsif ( $problem == 2 ) { $separate_checker = sub { $_[0] != $_[1] } }
  elsif ( $problem == 3 ) { $separate_checker = sub { $_[0] ne $_[1] } }
  else                    { exit(1) } # validate しているためこの実行パスには来ないはず

  # 部分列の先頭インデックスの配列を取得
  my $pos_begin = get_beginning_indexes_of_parts($input, $separate_checker);

  # 次の部分列のインデックスの配列 (最後の部分列は疑似的に '最後のインデックス+1' とする)
  my $pos_next_begin = clone $pos_begin;
  shift @$pos_next_begin;
  push  @$pos_next_begin, length($input);

  # 一番長い部分列を判定
  my @lengths = pairwise { $b - $a } @$pos_begin, @$pos_next_begin;
  my $max_length = max(@lengths);

  # 長さが最大値と一致した部分列のみ表示
  for my $i ( 0 .. $#$pos_begin ) {
    if ( $lengths[$i] == $max_length ) {
      say substr $input, $pos_begin->[$i], $lengths[$i];
    }
  }

  return 0;
}
main(@ARGV);
