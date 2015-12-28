use Test::Most;
use Test::DBIx::Class {
    schema_class => 'DBIC::Example::Schema',
    traits => [qw/Testpostgresql/],
    fail_on_schema_break => 0,
    connect_opts => {
        name_sep => '.',
        quote_char => '"',
        pg_enable_utf8 => 1,
        on_connect_do  => [ 'SET client_min_messages=WARNING' ],
    },
}, 'Order', 'OrderItem';

ok my $order = Order->create({
    name => 'O0001',
    type => 'basic',
    items => [
        {
            amount => 10,
            type => 'simple',
            name => 'Pencil',
        },
        {
            amount => 40,
            type => 'simple',
            name => 'Pen',
        }
    ],
});
ok my $order = Order->create({
    name => 'O0002',
    type => 'basic',
    items => [
        {
            amount => 1,
            name => 'Cabbages',
            type => 'simple',
        },
        {
            amount => 1,
            name => 'Lettuce',
            type => 'simple',
        },
        {
            amount => 1,
            name => 'Kohlrabi',
            type => 'simple',
        },
        {
            amount => 4,
            name => 'Carrots',
            type => 'simple',
        }
    ],
});

subtest correlate => sub {

    my @query_json = map { { %{$_->TO_JSON}, items => $_->get_column('items') } } Order->item_count->all;
    explain \@query_json;
    eq_or_diff \@query_json, [
        {
            'id' => 1,
            'items' => '2',
            'name' => 'O0001'
        },
        {
            'id' => 2,
            'items' => '4',
            'name' => 'O0002'
        }
    ];

    done_testing;
};

subtest subselect => sub {

    my @orders = Order->totals->as_subselect_rs->search({
            total => { '>' => 10 }
        },
        {
            '+columns' => ['total', 'lines']
        }
    )->all;
    my @json = map { { %{$_->TO_JSON},
        total => $_->get_column('total'),
        lines => $_->get_column('lines'),
    } } @orders;
    eq_or_diff \@json, [
        {
            'name' => 'O0001',
            'id' => 1,
            'lines' => '2',
            'total' => '50',
        }
    ];

    done_testing;
};

subtest prefetch => sub {

    my @orders = Order->prefetch_items->all;
    eq_or_diff [map {$_->TO_JSON} @orders], [
        {id => 1, name => 'O0001'},
        {id => 2, name => 'O0002'},
    ];
    my @lines;
    for my $o (@orders)
    {
        push @lines, $o->items->all;
    }
    eq_or_diff [map {$_->TO_JSON} @lines],
    [
        {
            amount => '10',
            id => 1,
            name => 'Pencil',
            order_id => 1
        },
        {
            amount => '40',
            id => 2,
            name => 'Pen',
            order_id => 1
        },
        {
            amount => '1',
            id => 3,
            name => 'Cabbages',
            order_id => 2
        },
        {
            amount => '1',
            id => 4,
            name => 'Lettuce',
            order_id => 2
        },
        {
            amount => '1',
            id => 5,
            name => 'Kohlrabi',
            order_id => 2
        },
        {
            amount => '4',
            id => 6,
            name => 'Carrots',
            order_id => 2
        }
    ];

    done_testing;
};

done_testing;
