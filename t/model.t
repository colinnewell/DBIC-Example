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
            per_item => 10,
            quantity => 1,
            vat => 0.2,
            type => 'simple',
            name => 'Pencil',
        },
        {
            per_item => 40,
            quantity => 1,
            vat => 0.2,
            type => 'simple',
            name => 'Pen',
        }
    ],
});
ok my $order2 = Order->create({
    name => 'O0002',
    type => 'basic',
    items => [
        {
            per_item => 1,
            name => 'Cabbages',
            quantity => 1,
            vat => 0,
            type => 'simple',
        },
        {
            per_item => 1,
            name => 'Lettuce',
            quantity => 1,
            vat => 0,
            type => 'simple',
        },
        {
            per_item => 1,
            name => 'Kohlrabi',
            type => 'simple',
            quantity => 1,
            vat => 0.2,
        },
        {
            per_item => 4,
            name => 'Carrots',
            type => 'simple',
            quantity => 1,
            vat => 0,
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
    )->total_columns->all;
    my @json = map { { %{$_->TO_JSON},
        total => $_->get_column('total'),
        total_exvat => $_->get_column('total_exvat'),
        lines => $_->get_column('lines'),
        items => $_->get_column('items'),
    } } @orders;
    eq_or_diff \@json, [
        {
            'name' => 'O0001',
            'id' => 1,
            'lines' => '2',
            'total' => '60.0',
            'total_exvat' => 50,
            items => 2,
        }
    ];

    done_testing;
};

subtest prefetch => sub {

    my @orders = Order->prefetch_items->name_order->all;
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
            per_item => '10',
            id => 1,
            name => 'Pencil',
            order_id => 1,
            vat => 0.2,
            quantity => 1,
        },
        {
            per_item => '40',
            id => 2,
            name => 'Pen',
            order_id => 1,
            vat => 0.2,
            quantity => 1,
        },
        {
            per_item => '1',
            id => 3,
            name => 'Cabbages',
            order_id => 2,
            quantity => 1,
            vat => 0,
        },
        {
            per_item => '1',
            id => 4,
            name => 'Lettuce',
            order_id => 2,
            quantity => 1,
            vat => 0,
        },
        {
            per_item => '1',
            id => 5,
            name => 'Kohlrabi',
            order_id => 2,
            quantity => 1,
            vat => 0.2,
        },
        {
            per_item => '4',
            id => 6,
            name => 'Carrots',
            order_id => 2,
            quantity => 1,
            vat => 0,
        }
    ];

    done_testing;
};

subtest bug => sub {
    my $orders = Order;
    my @columns = $orders->result_source->columns;
    my $me = $orders->current_source_alias;
    my @o = $orders->search(undef, {
        join => ['items'],
        '+columns' => [
            { total => \'sum(items.quantity*items.per_item*(1+items.vat)) as total' },
            #{ total => \'sum(quantity*per_item*(1+vat)) as total' },
        ],
        group_by => [map {"$me.$_"} @columns],
    });
    is scalar @o, 2;
};

done_testing;
