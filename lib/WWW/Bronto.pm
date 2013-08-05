package WWW::Bronto;

use strict;
use warnings;
#use SOAP::Lite +trace => 'all';
use SOAP::Lite;
use XML::Writer;

use vars qw/$errstr/;
sub errstr { $errstr }

sub new {
	my ($class, $api_token) = @_;

	my $args = { api_token => $api_token };
	my $self = bless $args, $class;

	# Init SOAP
	$SOAP::Constants::PREFIX_ENV = 'SOAP-ENV';
	my $soap = SOAP::Lite
	    #->readable(1)
	    ->ns("http://api.bronto.com/v4", 'ns1')
	    ->proxy('https://api.bronto.com/v4');
	# $soap->outputxml('true'); # XML
	$soap->on_action( sub { '' } );

	$self->{__soap} = $soap;
	return $self;
}

sub login {
	my ($self) = @_;

	my $som = $self->{__soap}->call( 'login', SOAP::Data->name('apiToken')->value($self->{api_token}) );
	if ($som->fault) {
		$errstr = $som->faultstring;
		return 0;
	}

	$self->{__session} = $som->result;

	return 1;
}

sub addOrUpdateOrders {
	my ($self, $orderObject) = @_;

	# SOAP header
	my $header = SOAP::Header->name('sessionHeader')->value( {
	    sessionId => $self->{__session}
	} )->prefix('ns1');

	my $xml;
    my $writer = XML::Writer->new(OUTPUT => \$xml);
    $writer->startTag('orders');

    foreach my $k ('id', 'email', 'contactId') {
    	next unless exists $orderObject->{$k};
    	$writer->dataElement($k, $orderObject->{$k});
    }

    foreach my $product (@{$orderObject->{products}}) {
    	$writer->startTag('products');
    	foreach my $k ('id', 'sku', 'name', 'description', 'category', 'image', 'url', 'quantity', 'price') {
    		next unless exists $product->{$k};
    		$writer->dataElement($k, $product->{$k});
    	}
    	$writer->endTag('products');
    }

    foreach my $k ('orderDate', 'tid') {
    	next unless exists $orderObject->{$k};
    	$writer->dataElement($k, $orderObject->{$k});
    }

    $writer->endTag('orders');

	my $som = $self->{__soap}->call( 'addOrUpdateOrders', $header, SOAP::Data->type('xml' => $xml) );
	if ($som->fault) {
		$errstr = $som->faultstring;
		return 0;
	}

	return $som->result;
}

1;