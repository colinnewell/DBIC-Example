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
#my $item = OrderItem->create({
#    order_item => $order->id,
#    amount => 10,
#});

done_testing;
