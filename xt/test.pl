#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use WWW::Bronto;
use Data::Dumper;

my $bronto = WWW::Bronto->new('API TOKEN HERE');

$bronto->login() or die "Can't login: " . $bronto->errstr;

my $product1 = {
    'id' => '78923',
    'sku' => '23424',
    'name' => 'Soccer Ball',
    'description' => 'Blue Soccer Ball',
    'category' => 'Sporting Goods',
    'quantity' => 3,
    'price' => 45.95
};
my $product2 = {
    'id' => '56735',
    'sku' => '6544',
    'name' => 'Guards',
    'description' => 'Shin guards',
    'category' => 'Sporting Goods',
    'quantity' => 1,
    'price' => 25.95
};

my $orderObject = {
    'id' => '2341234',
    'email' => 'test@example.com',
    'products' => [$product1, $product2],
    # 'tid' => $tid,
    'orderDate' => '2013-08-05T21:44:04+08:00',
};

my $status = $bronto->addOrUpdateOrders($orderObject) or die "Failed to addOrUpdateOrders: " . $bronto->errstr;
print Dumper(\$status);

# $VAR1 = \{
#             'errors' => '0',
#             'results' => {
#                          'isError' => 'true',
#                          'errorCode' => '915',
#                          'errorString' => 'Must include valid contact ID, email, or cookie. Please try again.'
#                        }
#           };

# $VAR1 = \{
#             'results' => {
#                          'isError' => 'false',
#                          'errorCode' => '0',
#                          'id' => '2341234',
#                          'isNew' => 'true'
#                        }
#           };

1;
