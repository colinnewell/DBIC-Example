package DBIC::Example::Schema::ResultSet::Order;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(Helper::ResultSet::CorrelateRelationship));


sub item_count
{
    my $self = shift;
    return $self->search(undef,
        {
            '+columns' => {
                'items' => $self->correlate('items')->count_rs->as_query,
            },
        }
    );
}

sub totals
{
    my $self = shift;
    my @columns = $self->result_source->columns;
    return $self->search(undef, {
        join => ['items'],
        '+columns' => [
            # NOTE: fully qualified name
            # even though they are not ambiguous.
            { items => { sum => 'items.quantity', -as => 'items' }},
            { lines => { count => 'items.quantity', -as => 'lines' }},
            { total => \'sum(items.quantity*items.per_item*(1+items.vat)) as total' },
            { total_exvat => \'sum(items.quantity*items.per_item) as total_exvat' },
        ],
        group_by => $self->_qualify_names(@columns),
    });
}

sub prefetch_items
{
    my $self = shift;
    return $self->search(undef, {
        prefetch => 'items',
    });
}

sub total_columns
{
    my $self = shift;
    return $self->search(undef,
        {
            '+columns' => ['total', 'lines', 'items', 'total_exvat']
        }
    );
}

sub _qualify_names
{
    my $self = shift;
    my @columns = shift;
    my $me = $self->current_source_alias;
    return [map {"$me.$_"} @columns];
}

sub name_order
{
    my $self = shift;
    my $me = $self->current_source_alias;
    return $self->search(undef,
        {
            order_by => [
                { -asc => $self->_qualify_names(qw/name id/) }
            ],
        });
}

1;
