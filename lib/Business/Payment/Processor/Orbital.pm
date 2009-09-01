package Business::Payment::Processor::Orbital;
use Moose;

our $VERSION = '0.01';

use Paymentech::SDK;
use Paymentech::eCommerce::RequestBuilder 'requestBuilder';
use Paymentech::eCommerce::RequestTypes qw(CC_AUTHORIZE_REQUEST MOTO_AUTHORIZE_REQUEST CC_MARK_FOR_CAPTURE_REQUEST ECOMMERCE_REFUND_REQUEST MOTO_REFUND_REQUEST);
use Paymentech::eCommerce::TransactionProcessor ':alias';

with 'Business::Payment::Processor',
     'Business::Payment::SSL';

1;

has '_ptech_request' => (
    is => 'rw'
);

sub prepare_data {
    my ($self, $charge) = @_;

    my $req;
    if($charge->type eq 'AUTH_ONLY') {
        if(lc($content{industry}) eq 'ecommerce') {
            $req = requestBuilder()->make(CC_AUTHORIZE_REQUEST());
            if(defined($content{'cvn'})) {
                $req->CardSecVal($content{'cvn'});
            }

        } else {
            $req = requestBuilder()->make(MOTO_AUTHORIZE_REQUEST());
        }
        $self->_addBillTo($req);
        # Authorize
        $req->MessageType('A');
        $req->CurrencyCode('840');

        $req->Exp($content{'exp_date'});
        $req->AccountNum($content{'card_number'});

    } elsif($content{'action'} eq 'Capture') {

        $req = requestBuilder()->make(CC_MARK_FOR_CAPTURE_REQUEST());
        $req->TxRefNum($content{'tx_ref_num'});

    } elsif($content{'action'} eq 'Force Authorization Only') {
        # ?
    } elsif($content{'action'} eq 'Authorization and Capture') {
        if(lc($content{industry}) eq 'ecommerce') {
            $req = requestBuilder()->make(CC_AUTHORIZE_REQUEST());
            if(defined($content{'cvn'})) {
                $req->CardSecVal($content{'cvn'});
            }

        } else {
            $req = requestBuilder()->make(MOTO_AUTHORIZE_REQUEST());
        }
        $self->_addBillTo($req);
        # Authorize and Capture
        $req->MessageType('AC');
        $req->CurrencyCode('840');

        $req->Exp($content{'exp_date'});
        $req->AccountNum($content{'card_number'});

    } elsif($content{'action'} eq 'Credit') {
        if(lc($content{industry}) eq 'ecommerce') {
            $req = requestBuilder()->make(ECOMMERCE_REFUND_REQUEST());
        } else {
            $req = requestBuilder()->make(MOTO_REFUND_REQUEST());
        }
        $req->CurrencyCode($content{'currency_code'} || '840');
        $req->AccountNum($content{'card_number'});

    } else {
        die('Unknown Action: '.$content{'action'}."\n");
    }

    $req->BIN($content{'BIN'} || '000001');
    $req->MerchantID($self->{'merchantid'});
    if(exists($content{'trace_number'}) && $content{'trace_number'} =~ /^\d+$/) {
        $req->traceNumber($content{'trace_number'});
    }
    $req->OrderID($content{'invoice_number'});

    $req->Amount(sprintf("%012d", $content{'amount'}));
    $req->TzCode($content{'TzCode'} || '706');
    if(exists($content{'comments'})) {
        $req->Comments($content{'comments'} || '');
    }

    $self->{'request'} = $req;
}

sub request {
    my ($self, $headers, $data) = @_;

    
}

__END__

=head1 NAME

Business::Payment::Processor::Orbital - Payment processor for Chase/Paymentech Orbital Gateway

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Business::Payment::Processor::Orbital;

    my $foo = Business::Payment::Processor::Orbital->new();
    ...

=head1 AUTHOR

Cory G Watson, C<< <gphat at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Cory G Watson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
