// package codecheck;

import java.util.*;
import java.util.function.*;

class Util {
  // 2 つのリストの各要素に対して処理を行って生成したリストを返す
  // (関数型言語で用いられるものと同じようなもの)
  // c.f. http://hackage.haskell.org/package/base-4.10.1.0/docs/Prelude.html#v:zipWith
  public static <S, T, U> List<U> zipWith(List<S> list1, List<T> list2, BiFunction<S, T, U> zipper) {
    final int size = Math.min(list1.size(), list2.size());

    List<U> result = new ArrayList<>();
    for ( int i = 0; i < size; i++ ) {
      result.add( zipper.apply(list1.get(i), list2.get(i)) );
    }
    return result;
  }
}


public class App {

  public static <T> void warn(T msg)  { System.err.println(msg); }

  public static void usage() {
    warn("usage:");
    warn("  java App 1 [0-9]+");
    warn("  java App 2 [01]+");
    warn("  java App 3 [A-Za-z]+");
  }


  // コマンドライン引数のチェック
  public static boolean validateArgs(String args[]) {
    final String strProblem = args[0];
    final String strInput   = args[1];

    if ( !strProblem.matches("^[0-9]+$") ) { return false; }
    final int problem = Integer.parseInt(strProblem);

    if      ( problem == 1 ) { return strInput.matches("^[0-9]+$");    }
    else if ( problem == 2 ) { return strInput.matches("^[01]+$");     }
    else if ( problem == 3 ) { return strInput.matches("^[A-Za-z]+$"); }
    else                     { return false; }  // 存在しない問題
  }


  // 引数  : 入力文字列, 部分列の切れ目の判定用のコールバック
  // 戻り値: 各種部分列の最初の文字のインデックスのリスト
  public static List<Integer> getBeginningIndexesOfParts(
    String input,
    BiFunction<Integer, Integer, Boolean> separateChecker
  ) {
    List<Integer> posBegin = new ArrayList<>( Arrays.asList(0) );
    for ( int i = 1; i < input.length(); i++ ) {
      final int prev    = input.charAt(i - 1);
      final int current = input.charAt(i);
      if ( separateChecker.apply(prev, current) ) { posBegin.add( i ); }
    }

    return posBegin;
  }


  public static void main(String args[]) {
    // 引数チェック
    try {
      if      ( args.length == 0 ) { throw new Exception(); }
      else if ( args.length == 1 ) { return; }
      else if ( args.length >  2 ) { warn("warn: Too many arguments (ignore 3rd and following ones)"); }

      if ( args[1].equals("") )  { return; }
      if ( !validateArgs(args) ) { throw new Exception(); }
    }
    catch(Exception e) {
      usage();
      System.exit(1);
    }

    final int    problem = Integer.parseInt(args[0]);
    final String input   = args[1];

    // 部分列の境界判定用コールバックの選択
    BiFunction<Integer, Integer, Boolean> separateChecker = null;
    if      ( problem == 1 ) { separateChecker = (p, c)->(p >= c); }
    else if ( problem == 2 ) { separateChecker = (p, c)->(p != c); }
    else if ( problem == 3 ) { separateChecker = (p, c)->(p != c); }
    else                     { System.exit(1); } // validate しているためこの実行パスには来ないはず

    // 部分列の先頭インデックスの配列を取得
    List<Integer> posBegin = getBeginningIndexesOfParts(input, separateChecker);

    // 次の部分列のインデックスの配列 (最後の部分列は疑似的に '最後のインデックス+1' とする)
    List<Integer> posNextBegin = new ArrayList<>( posBegin );
    posNextBegin.remove(0);
    posNextBegin.add(input.length());

    // 一番長い部分列を判定
    List<Integer> lengths = Util.zipWith( posBegin, posNextBegin, (begin, end) -> (end - begin) );
    int maxLength = Collections.max(lengths);

    // 長さが最大値と一致した部分列のみ表示
    for ( int i = 0; i < posBegin.size(); i++ ) {
      if ( lengths.get(i) == maxLength ) {
        System.out.println( input.substring(posBegin.get(i), posNextBegin.get(i)) );
      }
    }
  }
}
