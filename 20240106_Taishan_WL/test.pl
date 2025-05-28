#!/usr/bin/perl

use strict;
use warnings;

# 检查命令行参数数量
unless (@ARGV == 1) {
    die "Usage: $0 <filename>\n";
}

# 打开文件
my $filename = $ARGV[0];
open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";

# 初始化计数器
my ($lines, $words, $chars) = (0, 0, 0);

# 读取文件并计数
while (my $line = <$fh>) {
    $lines++;
    $chars += length($line);
    $words += scalar(split(/\s+/, $line));
}

# 打印结果
print "Lines: $lines\n";
print "Words: $words\n";
print "Chars: $chars\n";

# 关闭文件
close $fh;
