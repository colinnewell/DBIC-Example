package DBIC::Example::Schema::Result::Order;

use DBIx::Class::Candy  -autotable => v1,
                        -components =>
                            [qw/
                                Helper::Row::ToJSON
                                InflateColumn::DateTime
                                TimeStamp
                            /];

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column name => {
    data_type => 'varchar',
    size => 25,
    is_nullable => 0,
};

column type => {
    data_type => 'text',
    is_nullable => 0,
};

has_many items => 'DBIC::Example::Schema::Result::OrderItem' => 'order_id';

1;
